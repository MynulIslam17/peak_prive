import 'dart:async';

import 'package:get/get.dart';

import '../../../core/widgets/booking_details_parts.dart' show euro;
import '../../../data/api/peak_api.dart';
import '../../../data/services/socket/live_events.dart';
import '../services/payment_sheet.dart';

/// Result of a button on the booking screen, for the view to show.
class ActionOutcome {
  const ActionOutcome(this.ok, this.message, {this.silent = false});
  const ActionOutcome.ignored() : this(false, '', silent: true);

  final bool ok;
  final String message;

  /// Nothing to show (double tap, sheet closed by the user).
  final bool silent;
}

/// One booking, for the customer or the provider. Buttons come only from the
/// server's `actions`; every action replaces the booking with the response.
class BookingDetailController extends GetxController {
  BookingDetailController({
    required this.bookingId,
    Booking? initial,
    PeakApi? api,
    PaymentSheet? paymentSheet,
    this.viewerIsProviderHint = false,
    this.enableTimers = true,
    DateTime Function()? clock,
  })  : _api = api,
        _sheet = paymentSheet ?? stripePaymentSheet,
        _clock = clock ?? DateTime.now,
        booking = initial;

  final String bookingId;

  /// From the app role; used only until the booking says who is looking.
  final bool viewerIsProviderHint;
  final bool enableTimers;

  PeakApi? _api;
  PeakApi get api => _api ??= Get.find<PeakApi>();
  final PaymentSheet _sheet;
  final DateTime Function() _clock;

  Booking? booking;
  bool isLoading = false;
  String? errorMessage;

  /// The action running now (spinner on that button; others disabled).
  BookingAction? busyAction;
  bool get isBusy => busyAction != null;

  /// Set once a review was saved or the server says one exists.
  bool reviewDone = false;

  StreamSubscription<BookingUpdate>? _liveSub;
  Timer? _tick;
  Timer? _poll;
  int _loadSeq = 0;

  // ───────────────────────────── lifecycle ─────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _liveSub = LiveEvents.bookingUpdates.listen((u) {
      if (u.concerns(bookingId)) refreshQuietly();
    });
    if (enableTimers) {
      // Countdown text, every minute; a fresh copy every 3 minutes while open.
      // When a countdown (pick-up / return) runs out, the server's state
      // changes (e.g. return_in → overdue): reload instead of waiting for the
      // 3-minute poll.
      _tick = Timer.periodic(const Duration(seconds: 30), (_) {
        if (booking?.timer?.hasRunOut() == true) {
          refreshQuietly();
        } else {
          update();
        }
      });
      _poll = Timer.periodic(const Duration(minutes: 3), (_) {
        if (booking?.status.isFinished != true) refreshQuietly();
      });
    }
    load();
  }

  @override
  void onClose() {
    _liveSub?.cancel();
    _tick?.cancel();
    _poll?.cancel();
    super.onClose();
  }

  // ───────────────────────────── loading ─────────────────────────────

  /// Full load (spinner only when nothing is shown yet).
  Future<void> load() => _fetch(showSpinner: booking == null);

  /// Background refresh: keeps the screen as it is on failure.
  Future<void> refreshQuietly() => _fetch(showSpinner: false, quiet: true);

  Future<void> _fetch({required bool showSpinner, bool quiet = false}) async {
    if (bookingId.isEmpty) {
      errorMessage = 'Booking not found.';
      update();
      return;
    }
    final seq = ++_loadSeq;
    if (showSpinner) {
      isLoading = true;
      errorMessage = null;
      update();
    }
    final r = await api.bookings.detail(bookingId);
    if (seq != _loadSeq) return; // a newer load won
    isLoading = false;
    if (r.isSuccess) {
      booking = r.data;
      errorMessage = null;
    } else if (!quiet || booking == null) {
      errorMessage = r.errorMessage;
    }
    update();
  }

  // ───────────────────────────── who / what ─────────────────────────────

  /// Provider responses carry `customer`; customer responses carry `provider`.
  bool get isProviderView {
    final b = booking;
    if (b == null) return viewerIsProviderHint;
    if (b.customer != null) return true;
    if (b.provider != null) return false;
    return viewerIsProviderHint || b.earning != null;
  }

  List<BookingAction> get _actions {
    final b = booking;
    if (b == null) return const [];
    return b.actions.where((a) => !(a == BookingAction.review && reviewDone)).toList();
  }

  /// Main buttons, most important first.
  List<BookingAction> get primaryActions {
    const order = [
      BookingAction.payLateFee,
      BookingAction.approve,
      BookingAction.handOver,
      BookingAction.markReturned,
      BookingAction.complete,
      BookingAction.review,
    ];
    final a = _actions;
    return [for (final x in order) if (a.contains(x)) x];
  }

  /// Destructive buttons (reject, cancel), shown less prominently.
  List<BookingAction> get secondaryActions {
    final a = _actions;
    return [for (final x in const [BookingAction.reject, BookingAction.cancel]) if (a.contains(x)) x];
  }

  bool shows(BookingAction a) => _actions.contains(a);

  DateTime now() => _clock();

  // ───────────────────────────── actions ─────────────────────────────

  /// approve, reject, hand over, return, complete, cancel.
  Future<ActionOutcome> run(BookingAction action, {String? reason}) async {
    if (isBusy || booking == null) return const ActionOutcome.ignored();
    if (action.pathSegment == null) return const ActionOutcome.ignored();
    busyAction = action;
    update();
    try {
      final r = await api.bookings.act(bookingId, action, reason: reason);
      if (r.isSuccess) {
        booking = r.data;
        return ActionOutcome(true, _successText(action, r.data!, r.message));
      }
      final f = r.failure!;
      if (f.isConflict || f.isNotFound) {
        // Changed meanwhile (other device or an automatic rule).
        unawaited(refreshQuietly());
      } else if (f.isServerError || f.isOffline || f.statusCode == -2) {
        // The server may have done it before failing to answer (seen with a
        // gateway 502 on cancel): check again so the screen shows the truth.
        _recheckAfterUncertainFailure();
        return const ActionOutcome(
          false,
          "The server didn't answer. We're checking the booking again — please don't repeat it yet.",
        );
      }
      return ActionOutcome(false, f.message);
    } finally {
      busyAction = null;
      update();
    }
  }

  String _successText(BookingAction a, Booking b, String? serverMessage) {
    switch (a) {
      case BookingAction.approve:
        return 'Booking accepted. The guest has been notified.';
      case BookingAction.reject:
        return 'Booking declined. The guest gets a full refund to their card.';
      case BookingAction.handOver:
        return 'Marked as handed over.';
      case BookingAction.markReturned:
        final fee = b.lateFee;
        if (fee != null && fee.amount > 0) {
          return 'Marked as returned. Late fee: ${euro(fee.amount)} (${fee.hours} h).';
        }
        return 'Marked as returned. No late fee.';
      case BookingAction.complete:
        return 'Marked as done.';
      case BookingAction.cancel:
        final refund = b.refund;
        if (refund != null) {
          if (refund.amount <= 0) return 'Booking cancelled.';
          final pct = refund.percent == null ? '' : ' (${refund.percent}%)';
          return refund.isDone
              ? 'Booking cancelled. ${euro(refund.amount)}$pct has been refunded to your card.'
              : 'Booking cancelled. ${euro(refund.amount)}$pct will be refunded to your card within a few minutes.';
        }
        final c = b.cancellation?.refundAmount;
        return c != null
            ? 'Booking cancelled. ${euro(c)} will be refunded to your card.'
            : (serverMessage ?? 'Booking cancelled.');
      case BookingAction.payLateFee:
      case BookingAction.review:
        return serverMessage ?? 'Done.';
    }
  }

  /// Re-reads the booking a few times after an action whose result is unknown.
  void _recheckAfterUncertainFailure() {
    for (final d in const [Duration(seconds: 3), Duration(seconds: 15), Duration(seconds: 45)]) {
      Future.delayed(d, () {
        if (!isClosed) unawaited(refreshQuietly());
      });
    }
  }

  /// Late fee: intent → payment sheet → confirm.
  Future<ActionOutcome> payLateFee() async {
    if (isBusy || booking == null) return const ActionOutcome.ignored();
    busyAction = BookingAction.payLateFee;
    update();
    try {
      final intent = await api.bookings.lateFeeIntent(bookingId);
      if (!intent.isSuccess) {
        if (intent.failure!.isConflict) unawaited(refreshQuietly());
        return ActionOutcome(false, intent.errorMessage);
      }
      final data = intent.data!;
      if (!data.isComplete) {
        return const ActionOutcome(false, 'Payment is not available right now. Please try again later.');
      }
      final sheet = await _sheet(data);
      switch (sheet.status) {
        case SheetStatus.canceled:
          return const ActionOutcome(false, 'Payment cancelled. Nothing was charged.', silent: true);
        case SheetStatus.failed:
          return ActionOutcome(false, sheet.message ?? 'Payment failed. Please try again.');
        case SheetStatus.paid:
          break;
      }
      final confirmed = await api.bookings.lateFeeConfirm(bookingId, data.paymentIntentId);
      if (confirmed.isSuccess) {
        booking = confirmed.data;
        return ActionOutcome(true, 'Late fee of ${euro(data.amount)} paid. Thank you!');
      }
      // Paid but not confirmed yet: the webhook will record it.
      unawaited(refreshQuietly());
      return const ActionOutcome(true, 'Payment received. It can take a minute to show on the booking.');
    } finally {
      busyAction = null;
      update();
    }
  }

  /// Review after completion. A 409 means one already exists.
  Future<ActionOutcome> submitReview(int rating, String comment) async {
    final b = booking;
    if (isBusy || b == null) return const ActionOutcome.ignored();
    if (b.listing.id.isEmpty) {
      return const ActionOutcome(false, 'This service is no longer available to review.');
    }
    busyAction = BookingAction.review;
    update();
    try {
      final r = await api.listings.addReview(b.kind, b.listing.id, rating: rating, comment: comment);
      if (r.isSuccess) {
        reviewDone = true;
        return const ActionOutcome(true, 'Thanks for your review!');
      }
      if (r.failure!.isConflict) {
        reviewDone = true;
        return const ActionOutcome(false, "You've already reviewed this service.");
      }
      return ActionOutcome(false, r.errorMessage);
    } finally {
      busyAction = null;
      update();
    }
  }
}
