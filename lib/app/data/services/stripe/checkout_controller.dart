import 'package:get/get.dart';

import '../../api/peak_api.dart';
import 'payment_sheet.dart';

/// Where the checkout is.
enum CheckoutPhase {
  idle,

  /// `POST /booking/intent`.
  preparing,

  /// Stripe sheet on screen.
  paying,

  /// `POST /booking/create` after payment.
  confirming,

  /// Booked; see [CheckoutController.booking].
  done,
}

/// What went wrong, so the screen can pick wording and buttons.
enum CheckoutProblemKind {
  /// Form or 400 from the server. Fix the input.
  invalid,

  /// 409 before payment: sold out / slot taken. Refresh availability.
  unavailable,

  /// 402: an unpaid late fee blocks new bookings. Offer "My bookings".
  lateFeeDue,

  /// The server's price differs from the one on screen; it now shows the
  /// server's price. Tap Pay again to continue.
  priceChanged,

  /// No usable publishable key / malformed intent.
  paymentSetup,

  /// The card was declined or Stripe failed. Nothing booked.
  paymentFailed,

  /// Stripe is still processing; the booking appears when it completes.
  paymentProcessing,

  /// Paid, but `/booking/create` failed for a temporary reason. Retry with
  /// the same payment (never charges again).
  confirmRetry,

  /// Paid, but the server refused the booking (it refunds automatically).
  rejectedAfterPayment,

  /// No connection / server down before payment. Try again.
  offline,
}

class CheckoutProblem {
  const CheckoutProblem(this.kind, this.title, this.message, {this.bookingId});
  final CheckoutProblemKind kind;
  final String title;
  final String message;

  /// The booking to open (the one with the unpaid late fee), when known.
  final String? bookingId;

  @override
  String toString() => 'CheckoutProblem($kind, $message)';
}

/// What a [CheckoutController.pay] call ended with.
enum CheckoutOutcome { booked, canceled, problem }

/// The booking flow shared by every checkout screen:
///
/// `validate → /booking/intent → Stripe sheet → /booking/create`.
///
/// - The intent is reused while the request is unchanged, so a second tap
///   after a price change or a cancelled sheet doesn't create a new one.
/// - Once paid, the paid intent and request are kept until the booking is
///   created; [pay] then only retries `/booking/create` (idempotent per
///   paymentIntentId) and never opens the sheet again.
class CheckoutController extends GetxController {
  CheckoutController({PaymentSheet? sheet, String Function(String serverKey)? keyResolver})
      : _sheet = sheet ?? const StripePaymentSheet(),
        _resolveKey = keyResolver ?? resolvePublishableKey;

  final PaymentSheet _sheet;
  final String Function(String serverKey) _resolveKey;

  BookingApi get _api => Get.find<PeakApi>().bookings;

  CheckoutPhase phase = CheckoutPhase.idle;
  CheckoutProblem? problem;
  Booking? booking;

  /// Server-priced intent for [_quotedJson] (unpaid).
  PaymentIntentData? quote;
  String? _quotedJson;

  /// Set from payment success until the booking exists.
  String? paidIntentId;
  BookingRequest? _paidRequest;

  bool get isBusy =>
      phase == CheckoutPhase.preparing || phase == CheckoutPhase.paying || phase == CheckoutPhase.confirming;

  /// Paid but not booked yet: the form must stay locked.
  bool get needsConfirmRetry => paidIntentId != null;

  bool get isLocked => isBusy || needsConfirmRetry || phase == CheckoutPhase.done;

  /// Server amount when [request] matches the last quote, else null.
  num? quotedAmountFor(BookingRequest request) =>
      _quotedJson == _key(request) ? quote?.amount : null;

  /// Clears a problem shown on screen (e.g. after the user edits the form).
  void clearProblem() {
    if (problem == null) return;
    problem = null;
    update();
  }

  /// Runs the flow. [shownAmount] is the total on screen; when the server's
  /// amount differs, nothing is charged and [CheckoutProblemKind.priceChanged]
  /// is returned with [quote] holding the server price.
  Future<CheckoutOutcome> pay(BookingRequest request, {num? shownAmount}) async {
    if (isBusy || phase == CheckoutPhase.done) return CheckoutOutcome.problem;
    if (paidIntentId != null) return _confirm();

    problem = null;
    final invalid = request.validate();
    if (invalid != null) return _fail(CheckoutProblemKind.invalid, 'Check your booking', invalid);

    // 1. Intent (reuse the quote for an unchanged request).
    var intent = _quotedJson == _key(request) ? quote : null;
    if (intent == null) {
      _set(CheckoutPhase.preparing);
      final r = await _api.intent(request);
      if (!r.isSuccess) return _intentFailed(r.failure!);
      intent = r.data!;
      quote = intent;
      _quotedJson = _key(request);
    }

    if (shownAmount != null && (shownAmount - intent.amount).abs() > 0.009) {
      return _fail(
        CheckoutProblemKind.priceChanged,
        'Price updated',
        'The price for this booking is ${_money(intent.amount, intent.currency)}. '
            'Check the details and tap Pay to continue.',
      );
    }

    final key = _resolveKey(intent.publishableKey);
    if (!intent.isComplete || !intent.paymentIntentId.startsWith('pi_') || !key.startsWith('pk_')) {
      _forgetQuote();
      return _fail(CheckoutProblemKind.paymentSetup, 'Payment unavailable',
          'We could not start the payment. Please try again later.');
    }

    // 2. Stripe sheet.
    _set(CheckoutPhase.paying);
    final sheet = await _sheet.present(publishableKey: key, clientSecret: intent.clientSecret);
    switch (sheet.status) {
      case SheetStatus.canceled:
        _set(CheckoutPhase.idle);
        return CheckoutOutcome.canceled;
      case SheetStatus.failed:
        return _fail(CheckoutProblemKind.paymentFailed, 'Payment failed',
            sheet.message ?? 'The payment could not be completed. Please try again.');
      case SheetStatus.processing:
        // The webhook books it when the payment clears; don't pay twice.
        _forgetQuote();
        return _fail(CheckoutProblemKind.paymentProcessing, 'Payment processing',
            'Your payment is still processing. The booking will appear in My bookings once it completes.');
      case SheetStatus.succeeded:
        break;
    }

    // 3. Create the booking.
    paidIntentId = intent.paymentIntentId;
    _paidRequest = request;
    _forgetQuote();
    return _confirm();
  }

  Future<CheckoutOutcome> _confirm() async {
    _set(CheckoutPhase.confirming);
    final r = await _api.create(paidIntentId!, _paidRequest!);
    if (r.isSuccess) {
      booking = r.data;
      paidIntentId = null;
      _paidRequest = null;
      problem = null;
      _set(CheckoutPhase.done);
      return CheckoutOutcome.booked;
    }
    final f = r.failure!;
    final temporary = f.isOffline || f.isServerError || f.statusCode == -2 || f.statusCode == 408 || f.statusCode == 429;
    if (temporary) {
      return _fail(
        CheckoutProblemKind.confirmRetry,
        'Payment received — booking not confirmed yet',
        'You will not be charged again. Tap "Retry booking" to finish.\n'
            'Payment reference: $paidIntentId',
      );
    }
    // Refused after payment: the server refunds it automatically.
    paidIntentId = null;
    _paidRequest = null;
    final refunded = f.message.toLowerCase().contains('refund');
    return _fail(
      CheckoutProblemKind.rejectedAfterPayment,
      'Booking not possible',
      refunded ? f.message : '${f.message}\nIf you were charged, the payment is refunded automatically.',
    );
  }

  CheckoutOutcome _intentFailed(ApiFailure f) {
    if (f.isPaymentRequired) {
      final due = parseLateFeeBlock(f.message);
      final amount = due.amount == null ? '' : ' of €${due.amount!.toStringAsFixed(2)}';
      return _fail(
        CheckoutProblemKind.lateFeeDue,
        'Late fee to pay',
        'You have an unpaid late fee$amount from an earlier rental. Pay it to book again.',
        bookingId: due.bookingId,
      );
    }
    if (f.isConflict) return _fail(CheckoutProblemKind.unavailable, 'Not available', f.message);
    if (f.isOffline || f.isServerError || f.statusCode == -2) {
      return _fail(CheckoutProblemKind.offline, 'Could not start the payment', f.message);
    }
    if (f.isUnauthorized) {
      return _fail(CheckoutProblemKind.invalid, 'Session expired', 'Please log in again to continue.');
    }
    final field = f.fieldErrors.isEmpty ? '' : '\n${f.fieldErrors.map((e) => e.message).where((m) => m.isNotEmpty).join('\n')}';
    return _fail(CheckoutProblemKind.invalid, 'Check your booking', '${f.message}$field'.trim());
  }

  CheckoutOutcome _fail(CheckoutProblemKind kind, String title, String message, {String? bookingId}) {
    problem = CheckoutProblem(kind, title, message, bookingId: bookingId);
    _set(CheckoutPhase.idle);
    return CheckoutOutcome.problem;
  }

  void _forgetQuote() {
    quote = null;
    _quotedJson = null;
  }

  void _set(CheckoutPhase p) {
    phase = p;
    update();
  }

  static String _key(BookingRequest r) => r.toJson().toString();

  static String _money(num amount, String currency) => currency.toLowerCase() == 'eur'
      ? '€${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2)}'
      : '${amount.toStringAsFixed(2)} ${currency.toUpperCase()}';
}

/// The 402 text is "Please pay your outstanding late fee of 10 first
/// (booking 6afb…35c)."; pull out the amount and booking id for a friendlier
/// message and a direct link. Both are null when the wording changes.
({num? amount, String? bookingId}) parseLateFeeBlock(String message) {
  final amount = RegExp(r'late fee of\s*€?\s*(\d+(?:\.\d+)?)', caseSensitive: false).firstMatch(message);
  final id = RegExp(r'\b([0-9a-f]{24})\b').firstMatch(message);
  return (amount: amount == null ? null : num.tryParse(amount.group(1)!), bookingId: id?.group(1));
}
