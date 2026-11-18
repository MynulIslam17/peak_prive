import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../data/api/peak_api.dart';
import '../../data/services/stripe/checkout_controller.dart';
import '../../routes/app_routes.dart';
import '../constants/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../controllers/nav_controller.dart';
import '../utils/app_toast.dart';
import 'checkout_parts.dart';
import 'shimmer/skeleton.dart';

/// Resolves a checkout's listing from `Get.arguments`
/// (`{'id': listingId, 'listing': ListingDetail}`): uses `listing` when it is
/// a [T], otherwise loads it by `id`.
class CheckoutListingGate<T extends ListingDetail> extends StatefulWidget {
  const CheckoutListingGate({
    super.key,
    required this.kind,
    required this.noun,
    required this.builder,
  });

  final ServiceKind kind;

  /// "ski pass", "restaurant"… for messages.
  final String noun;
  final Widget Function(BuildContext context, T listing) builder;

  @override
  State<CheckoutListingGate<T>> createState() => _CheckoutListingGateState<T>();
}

class _CheckoutListingGateState<T extends ListingDetail> extends State<CheckoutListingGate<T>> {
  T? _listing;
  String? _id;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map) {
      final l = args['listing'];
      if (l is T) _listing = l;
      final id = args['id'];
      _id = (id is String && id.isNotEmpty) ? id : _listing?.id;
    }
    if (_listing == null && _id != null) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final r = await Get.find<PeakApi>().listings.detail(widget.kind, _id!);
    if (!mounted) return;
    setState(() {
      _loading = false;
      final d = r.data;
      if (d is T) {
        _listing = d;
      } else {
        _error = r.isSuccess ? 'This is not a ${widget.noun}.' : r.errorMessage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final listing = _listing;
    if (listing != null) return widget.builder(context, listing);
    if (_id == null) {
      return CheckoutStateView(
        icon: Icons.link_off_rounded,
        title: 'Listing not found',
        message: 'This booking link is invalid.',
        actionLabel: 'Go back',
        onAction: Get.back,
      );
    }
    if (_loading || _error == null) {
      return const CheckoutSkeleton();
    }
    return CheckoutStateView(
      icon: Icons.wifi_off_rounded,
      title: 'Could not load this ${widget.noun}',
      message: _error!,
      actionLabel: 'Try again',
      onAction: _load,
    );
  }
}

/// Phone + address state for a checkout, pre-filled from the profile.
class CheckoutContact {
  CheckoutContact() {
    final auth = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
    final saved = (auth?.userModel?.phone ?? '').replaceAll(RegExp(r'[\s-]'), '');
    Country? savedCountry;
    if (saved.startsWith('+')) {
      for (final c in countries) {
        if (saved.substring(1).startsWith(c.fullCountryCode) &&
            (savedCountry == null || c.fullCountryCode.length > savedCountry.fullCountryCode.length)) {
          savedCountry = c; // longest matching code wins ("+1 684" before "+1")
        }
      }
    }
    if (savedCountry != null) {
      initialPhone = saved;
      initialCountry = null;
      dialCode = savedCountry.fullCountryCode;
      national = saved.substring(1 + dialCode.length);
    } else {
      initialPhone = '';
      final region = WidgetsBinding.instance.platformDispatcher.locale.countryCode;
      final country = countries.firstWhere(
        (c) => c.code == region,
        orElse: () => countries.firstWhere((c) => c.code == 'FR'),
      );
      initialCountry = country.code;
      dialCode = country.fullCountryCode;
    }
    final a = (auth?.userModel?.address ?? '').trim();
    if (a.isNotEmpty && a.toUpperCase() != 'N/A') address.text = a;
  }

  late final String initialPhone;
  late final String? initialCountry;
  String dialCode = '';
  String national = '';
  final address = TextEditingController();
  final destination = TextEditingController();

  /// "+33612345678", or '' when empty.
  String get phone => national.isEmpty ? '' : '+$dialCode$national';

  /// [required]: an empty number is an error; otherwise only a bad one.
  String? phoneError({bool required = true}) {
    final digits = national.replaceAll(RegExp(r'\D'), '').length;
    if (digits == 0 && !required) return null;
    if (digits < 6 || digits + dialCode.length > 15) return 'Please enter a valid phone number';
    return null;
  }

  String? addressError({String message = 'Please enter your address'}) =>
      address.text.trim().length < 3 ? message : null;

  void dispose() {
    address.dispose();
    destination.dispose();
  }
}

/// Phone field (+ optional address / destination fields) in a card.
class CheckoutContactCard extends StatelessWidget {
  const CheckoutContactCard({
    super.key,
    required this.contact,
    required this.enabled,
    required this.onChanged,
    this.phoneError,
    this.showAddress = false,
    this.addressLabel = 'Address',
    this.addressHint = 'Hotel, chalet or street address',
    this.addressError,
    this.showDestination = false,
  });

  final CheckoutContact contact;
  final bool enabled;
  final VoidCallback onChanged;
  final String? phoneError;
  final bool showAddress;
  final String addressLabel;
  final String addressHint;
  final String? addressError;
  final bool showDestination;

  @override
  Widget build(BuildContext context) {
    return CheckoutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntlPhoneField(
            initialValue: contact.initialPhone,
            initialCountryCode: contact.initialCountry,
            enabled: enabled,
            disableLengthCheck: true,
            invalidNumberMessage: null,
            autovalidateMode: AutovalidateMode.disabled,
            decoration: checkoutInputDecoration(label: 'Phone number', error: phoneError),
            onChanged: (p) {
              contact.national = p.number.replaceAll(RegExp(r'\D'), '');
              contact.dialCode = p.countryCode.replaceAll('+', '');
              onChanged();
            },
            onCountryChanged: (c) {
              contact.dialCode = c.fullCountryCode;
              onChanged();
            },
          ),
          if (showAddress) ...[
            // The phone field reserves no space under it; keep its error clear
            // of the address label.
            SizedBox(height: phoneError != null ? 12 : 6),
            TextField(
              controller: contact.address,
              enabled: enabled,
              textCapitalization: TextCapitalization.words,
              minLines: 1,
              maxLines: 3,
              onChanged: (_) => onChanged(),
              decoration: checkoutInputDecoration(label: addressLabel, hint: addressHint, error: addressError),
            ),
          ],
          if (showDestination) ...[
            const SizedBox(height: 12),
            TextField(
              controller: contact.destination,
              enabled: enabled,
              textCapitalization: TextCapitalization.words,
              minLines: 1,
              maxLines: 2,
              onChanged: (_) => onChanged(),
              decoration: checkoutInputDecoration(label: 'Destination (optional)', hint: 'e.g. Geneva airport'),
            ),
          ],
        ],
      ),
    );
  }
}

InputDecoration checkoutInputDecoration({required String label, String? hint, String? error}) {
  OutlineInputBorder border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c),
      );
  return InputDecoration(
    labelText: label,
    hintText: hint,
    errorText: error,
    counterText: '',
    filled: true,
    fillColor: Colors.white,
    border: border(AppColors.border),
    enabledBorder: border(AppColors.border),
    focusedBorder: border(AppColors.primary_1),
    errorBorder: border(AppColors.error),
    focusedErrorBorder: border(AppColors.error),
    disabledBorder: border(AppColors.border),
  );
}

/// Shows [problem] with the right wording and buttons.
void showCheckoutProblem(BuildContext context, CheckoutProblem problem) {
  final lateFee = problem.kind == CheckoutProblemKind.lateFeeDue;
  showCheckoutMessage(
    context,
    problem.title,
    problem.message,
    isError: problem.kind != CheckoutProblemKind.paymentProcessing &&
        problem.kind != CheckoutProblemKind.priceChanged,
    actionLabel: !lateFee ? null : (problem.bookingId != null ? 'Pay late fee' : 'Go to My bookings'),
    onAction: !lateFee
        ? null
        : problem.bookingId != null
            ? () => Get.toNamed(Routes.bookingDetails, arguments: {'bookingId': problem.bookingId})
            : openMyBookings,
  );
}

/// Bottom nav → Bookings tab.
void openMyBookings() {
  if (Get.isRegistered<NavController>()) Get.find<NavController>().changeIndex(1);
  Get.offAllNamed(Routes.bottomNav);
}

/// After a successful checkout: ski pass → ticket, others → booking details.
/// Removes the checkout and the listing screen from the stack.
void finishCheckout(Booking booking, {required String checkoutRoute, required String detailsRoute}) {
  final pending = booking.status == BookingStatus.pending;
  showAppToast(
    type: ToastType.success,
    title: pending ? 'Booking requested' : 'Booking confirmed',
    message: pending ? 'Paid. Waiting for the provider to approve.' : 'You can find it under Bookings.',
  );
  bool keep(Route<dynamic> r) => r.settings.name != checkoutRoute && r.settings.name != detailsRoute;
  if (booking.kind == ServiceKind.skiPass) {
    Get.offNamedUntil(Routes.ticket, keep, arguments: {'booking': booking});
  } else {
    Get.offNamedUntil(Routes.bookingDetails, keep, arguments: {'bookingId': booking.id, 'booking': booking});
  }
}

/// Handles the result of [CheckoutController.pay] on screen.
/// Returns true when the booking was made (navigation already done).
bool handleCheckoutOutcome(
  BuildContext context,
  CheckoutController checkout,
  CheckoutOutcome outcome, {
  required String checkoutRoute,
  required String detailsRoute,
}) {
  if (outcome == CheckoutOutcome.booked && checkout.booking != null) {
    finishCheckout(checkout.booking!, checkoutRoute: checkoutRoute, detailsRoute: detailsRoute);
    return true;
  }
  final p = checkout.problem;
  if (outcome == CheckoutOutcome.problem && p != null && context.mounted) {
    showCheckoutProblem(context, p);
  }
  return false;
}

/// PopScope wrapper: blocks back while busy, warns when paid but not booked.
class CheckoutPopGuard extends StatelessWidget {
  const CheckoutPopGuard({super.key, required this.checkout, required this.child});

  final CheckoutController checkout;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = checkout;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) => PopScope(
        canPop: !c.isBusy && !c.needsConfirmRetry,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop || c.isBusy) return;
          if (await confirmLeaveUnbookedPayment(context, c.paidIntentId ?? '') && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: child,
      ),
    );
  }
}

/// [CheckoutStage] for the shared [CheckoutBar].
CheckoutStage checkoutStageOf(CheckoutController c) => switch (c.phase) {
      CheckoutPhase.preparing || CheckoutPhase.paying => CheckoutStage.paying,
      CheckoutPhase.confirming => CheckoutStage.booking,
      CheckoutPhase.done => CheckoutStage.completed,
      CheckoutPhase.idle => CheckoutStage.idle,
    };

/// Date then time picker. Days before today (or [firstDate]) can't be picked.
Future<DateTime?> pickCheckoutDateTime(
  BuildContext context, {
  required DateTime? current,
  required DateTime firstDate,
  required String dateHelp,
  required String timeHelp,
  int windowDays = 365,
}) async {
  final today = DateUtils.dateOnly(DateTime.now());
  final first = DateUtils.dateOnly(firstDate).isBefore(today) ? today : DateUtils.dateOnly(firstDate);
  final initial = current != null && !current.isBefore(first) ? current : first;
  FocusManager.instance.primaryFocus?.unfocus();
  final date = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: first,
    lastDate: today.add(Duration(days: windowDays)),
    helpText: dateHelp,
    builder: checkoutPickerTheme,
  );
  if (date == null || !context.mounted) return null;
  FocusManager.instance.primaryFocus?.unfocus();
  final time = await showTimePicker(
    context: context,
    initialTime: current != null ? TimeOfDay.fromDateTime(current) : const TimeOfDay(hour: 9, minute: 0),
    helpText: timeHelp,
    builder: checkoutPickerTheme,
  );
  if (time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

/// "2 days 3 h", "45 min".
String checkoutLengthLabel(Duration d) {
  final days = d.inDays, hours = d.inHours % 24, minutes = d.inMinutes % 60;
  return [
    if (days > 0) '$days ${days == 1 ? 'day' : 'days'}',
    if (hours > 0) '$hours h',
    if (minutes > 0 && days == 0) '$minutes min',
  ].join(' ');
}

/// Grey strip at the bottom of a card (rental length, notes).
class CheckoutInfoStrip extends StatelessWidget {
  const CheckoutInfoStrip({super.key, required this.icon, required this.text, this.color});
  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? AppColors.textTertiary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12, color: color ?? AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
