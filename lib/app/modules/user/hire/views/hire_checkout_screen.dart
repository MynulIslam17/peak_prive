import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/checkout_flow_parts.dart';
import '../../../../core/widgets/checkout_parts.dart';
import '../../../../data/api/peak_api.dart';
import '../../../../data/services/stripe/checkout_controller.dart';
import '../../../../data/services/stripe/checkout_math.dart';
import '../../../../routes/app_routes.dart';

/// Ski hire checkout: equipment × quantity, pick-up/return, contact → pay.
///
/// Arguments: `{'id': listingId, 'listing': SkiHireDetail?,
/// 'quantities': {itemId: int}?}` (pre-selection from the listing).
/// Quantities are capped by `GET /booking/availability` for the chosen period.
class HireCheckoutScreen extends StatelessWidget {
  const HireCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final q = args is Map ? args['quantities'] : null;
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: checkoutAppBar(context, 'Checkout'),
      body: CheckoutListingGate<SkiHireDetail>(
        kind: ServiceKind.skiHire,
        noun: 'ski hire',
        builder: (_, hire) => HireCheckoutForm(
          hire: hire,
          initialQuantities: q is Map
              ? {
                  for (final e in q.entries)
                    if (e.key is String && e.value is int) e.key as String: e.value as int,
                }
              : const {},
        ),
      ),
    );
  }
}

class HireCheckoutForm extends StatefulWidget {
  const HireCheckoutForm({super.key, required this.hire, this.initialQuantities = const {}, this.checkout});

  final SkiHireDetail hire;
  final Map<String, int> initialQuantities;
  final CheckoutController? checkout;

  @override
  State<HireCheckoutForm> createState() => _HireCheckoutFormState();
}

class _HireCheckoutFormState extends State<HireCheckoutForm> {
  /// The server only needs the return after the pick-up (a short rental is
  /// charged as one unit).
  static const _minRental = Duration(minutes: 1);

  late final CheckoutController _checkout = widget.checkout ?? CheckoutController();
  final _contact = CheckoutContact();

  late Map<String, int> _qty;
  DateTime? _start;
  DateTime? _end;
  bool _showErrors = false;

  /// Free units per item for [_start]–[_end]; null until checked.
  Map<String, int>? _available;
  bool _checking = false;
  String? _availabilityError;
  int _availabilityRequest = 0;

  SkiHireDetail get _hire => widget.hire;
  String get _unit => _hire.priceUnit;

  @override
  void initState() {
    super.initState();
    final stock = {for (final i in _hire.items) i.id: i.quantity};
    _qty = clampQuantities(widget.initialQuantities, stock);
    // A single item: start at 1 so the user isn't stuck on an empty cart.
    if (_qty.isEmpty && _hire.items.length == 1 && _hire.items.first.quantity > 0) {
      _qty = {_hire.items.first.id: 1};
    }
  }

  @override
  void dispose() {
    _contact.dispose();
    super.dispose();
  }

  // ───────────────────────────── Availability ─────────────────────────────

  int _maxFor(HireItem item) => _available?[item.id] ?? item.quantity;

  Future<void> _checkAvailability() async {
    final s = _start, e = _end;
    if (s == null || e == null || _endError != null) return;
    final ticket = ++_availabilityRequest;
    setState(() {
      _checking = true;
      _availabilityError = null;
    });
    final r = await Get.find<PeakApi>().bookings.hireAvailability(_hire.id, s, e);
    if (!mounted || ticket != _availabilityRequest) return;
    setState(() {
      _checking = false;
      if (r.isSuccess) {
        _available = {for (final i in r.data!.items) i.itemId: i.available};
        final before = _qty.values.fold(0, (a, b) => a + b);
        _qty = clampQuantities(_qty, _available!);
        if (_qty.values.fold(0, (a, b) => a + b) < before) {
          _availabilityError = 'Some quantities were lowered to what is free for these dates.';
        }
      } else {
        _available = null;
        _availabilityError = "Couldn't check availability (${r.errorMessage}). It's checked again when you pay.";
      }
    });
  }

  // ───────────────────────────── Validation ─────────────────────────────

  String? get _itemsError => _qty.isEmpty ? 'Choose at least one item' : null;

  String? get _startError {
    if (_start == null) return 'Please choose a pick-up time';
    if (!_start!.isAfter(DateTime.now())) return 'This time has already passed';
    return null;
  }

  String? get _endError {
    if (_end == null) return 'Please choose a return time';
    if (_start != null && _end!.difference(_start!) < _minRental) {
      return 'The return must be after the pick-up';
    }
    return null;
  }

  bool get _isValid =>
      _itemsError == null &&
      _startError == null &&
      _endError == null &&
      _contact.phoneError() == null &&
      _contact.addressError() == null;

  BookingRequest _request() => BookingRequest.skiHire(
        productId: _hire.id,
        start: _start!,
        end: _end!,
        items: [for (final e in _qty.entries) ItemQuantity(e.key, e.value)],
        phoneNumber: _contact.phone,
        address: _contact.address.text,
      );

  num get _perUnit => _hire.items.fold<num>(0, (s, i) => s + i.price * (_qty[i.id] ?? 0));

  int? get _units => (_start != null && _end != null && _endError == null) ? rentalUnits(_unit, _start!, _end!) : null;

  num get _estimate => _perUnit * (_units ?? 1);

  num get _total {
    if (_start == null || _end == null || _qty.isEmpty) return _estimate;
    return _checkout.quotedAmountFor(_request()) ?? _estimate;
  }

  // ───────────────────────────── Pickers ─────────────────────────────

  Future<void> _pickStart() async {
    final picked = await pickCheckoutDateTime(
      context,
      current: _start,
      firstDate: DateTime.now(),
      dateHelp: 'Pick-up date',
      timeHelp: 'Pick-up time',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _start = picked;
      if (_end != null && _end!.difference(picked) < _minRental) _end = null;
    });
    _checkout.clearProblem();
    _checkAvailability();
  }

  Future<void> _pickEnd() async {
    final picked = await pickCheckoutDateTime(
      context,
      current: _end ?? _start?.add(const Duration(days: 1)),
      firstDate: _start ?? DateTime.now(),
      dateHelp: 'Return date',
      timeHelp: 'Return time',
    );
    if (picked == null || !mounted) return;
    setState(() => _end = picked);
    _checkout.clearProblem();
    _checkAvailability();
  }

  // ───────────────────────────── Pay ─────────────────────────────

  Future<void> _pay() async {
    if (_checkout.isBusy) return;
    FocusScope.of(context).unfocus();
    if (!_checkout.needsConfirmRetry) {
      setState(() => _showErrors = true);
      if (!_isValid) return;
    }
    final outcome = await _checkout.pay(_request(), shownAmount: _total);
    if (!mounted) return;
    final booked = handleCheckoutOutcome(context, _checkout, outcome,
        checkoutRoute: Routes.hireCheckout, detailsRoute: Routes.hireDetails);
    final kind = _checkout.problem?.kind;
    if (!booked && (kind == CheckoutProblemKind.unavailable || kind == CheckoutProblemKind.rejectedAfterPayment)) {
      _checkAvailability();
    }
  }

  // ───────────────────────────── Build ─────────────────────────────

  @override
  Widget build(BuildContext context) {
    return CheckoutPopGuard(
      checkout: _checkout,
      child: ListenableBuilder(
        listenable: _checkout,
        builder: (context, _) => _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    final locked = _checkout.isLocked;
    final units = _units;
    final perRental = _unit == 'per_rental';
    final unitWord = priceUnitLabel(_unit).isEmpty ? 'day' : priceUnitLabel(_unit);
    final waitingForDates = units == null && !perRental;
    final total = _total;
    final fmt = DateFormat('EEE, d MMM yyyy · h:mm a');

    if (_hire.items.isEmpty) {
      return CheckoutStateView(
        icon: Icons.inventory_2_outlined,
        title: 'Nothing to rent yet',
        message: 'This shop has no equipment listed.',
        actionLabel: 'Go back',
        onAction: Get.back,
      );
    }

    return Column(
      children: [
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  CheckoutSummaryCard(
                    imageUrl: _hire.thumbnail ?? '',
                    title: _hire.title,
                    location: _hire.serviceArea,
                  ),
                  const CheckoutSectionLabel('Rental period'),
                  CheckoutCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        CheckoutPickerTile(
                          icon: Icons.login_rounded,
                          label: 'Pick-up',
                          value: _start == null ? null : fmt.format(_start!),
                          placeholder: 'Choose date & time',
                          error: (_showErrors || _start != null) ? _startError : null,
                          enabled: !locked,
                          onTap: _pickStart,
                        ),
                        const Divider(height: 1, indent: 64, color: AppColors.divider),
                        CheckoutPickerTile(
                          icon: Icons.logout_rounded,
                          label: 'Return',
                          value: _end == null ? null : fmt.format(_end!),
                          placeholder: 'Choose date & time',
                          // Once both are picked, say right away what's wrong.
                          error: (_showErrors || (_start != null && _end != null)) ? _endError : null,
                          enabled: !locked,
                          onTap: _pickEnd,
                        ),
                        if (units != null)
                          CheckoutInfoStrip(
                            icon: Icons.timelapse_rounded,
                            text: perRental
                                ? 'Rental length: ${checkoutLengthLabel(_end!.difference(_start!))}'
                                : 'Rental length: ${checkoutLengthLabel(_end!.difference(_start!))} · charged as $units $unitWord${units == 1 ? '' : 's'}',
                          ),
                      ],
                    ),
                  ),
                  const CheckoutSectionLabel('Equipment'),
                  CheckoutCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Column(
                      children: [
                        for (var i = 0; i < _hire.items.length; i++) ...[
                          if (i > 0) const Divider(height: 1, color: AppColors.divider),
                          _ItemRow(
                            item: _hire.items[i],
                            qty: _qty[_hire.items[i].id] ?? 0,
                            max: _maxFor(_hire.items[i]),
                            checked: _available != null,
                            unitSuffix: perRental ? '' : ' / $unitWord',
                            enabled: !locked && !_checking,
                            onChanged: (v) {
                              setState(() {
                                if (v <= 0) {
                                  _qty.remove(_hire.items[i].id);
                                } else {
                                  _qty[_hire.items[i].id] = v;
                                }
                              });
                              _checkout.clearProblem();
                            },
                          ),
                        ],
                        if (_checking)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: LinearProgressIndicator(color: AppColors.primary_1, minHeight: 2),
                          ),
                      ],
                    ),
                  ),
                  if (_availabilityError != null || (_showErrors && _itemsError != null))
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                      child: Text(
                        _availabilityError ?? _itemsError!,
                        style: AppTextStyle.p_regular_12(
                          color: _availabilityError != null ? AppColors.textSecondary : AppColors.error,
                        ),
                      ),
                    ),
                  const CheckoutSectionLabel('Contact details'),
                  CheckoutContactCard(
                    contact: _contact,
                    enabled: !locked,
                    onChanged: () => setState(() {}),
                    phoneError: _showErrors ? _contact.phoneError() : null,
                    showAddress: true,
                    addressError: _showErrors ? _contact.addressError() : null,
                  ),
                  const CheckoutSectionLabel('Price details'),
                  CheckoutCard(
                    child: CheckoutPriceBreakdown(
                      lines: [
                        for (final item in _hire.items)
                          if ((_qty[item.id] ?? 0) > 0)
                            (
                              '${item.name} × ${_qty[item.id]}',
                              perRental
                                  ? checkoutEuro(item.price * _qty[item.id]!)
                                  : '${checkoutEuro(item.price * _qty[item.id]!)} / $unitWord',
                            ),
                        if (units != null && !perRental)
                          ('${checkoutEuro(_perUnit)} × $units $unitWord${units == 1 ? '' : 's'}', checkoutEuro(_estimate)),
                      ],
                      total: total.toDouble(),
                      totalLabel: waitingForDates ? 'Per $unitWord (EUR)' : 'Total (EUR)',
                      footnote: [
                        if (waitingForDates) 'Choose pick-up and return to see the total. Every started $unitWord is charged.',
                        if (_hire.extraChargePerHour > 0)
                          'Late return: ${checkoutEuro(_hire.extraChargePerHour)} per started hour after a 15-minute grace period, '
                              'capped at the booking price.',
                      ].join('\n').ifEmptyNull,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const CheckoutSecureNote(),
                ],
              ),
            ),
          ),
        ),
        CheckoutBar(
          total: total.toDouble(),
          stage: checkoutStageOf(_checkout),
          needsBookingRetry: _checkout.needsConfirmRetry,
          totalLabel: waitingForDates ? 'Per $unitWord' : 'Total',
          idleButtonLabel: waitingForDates ? 'Choose dates' : null,
          onPressed: _checking ? null : _pay,
        ),
      ],
    );
  }

}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.item,
    required this.qty,
    required this.max,
    required this.checked,
    required this.unitSuffix,
    required this.enabled,
    required this.onChanged,
  });

  final HireItem item;
  final int qty;
  final int max;

  /// True when [max] comes from the availability check for the dates.
  final bool checked;
  final String unitSuffix;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final soldOut = max <= 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyle.sub_h3_medium_14()),
                const SizedBox(height: 2),
                Text(
                  '${checkoutEuro(item.price)}$unitSuffix · '
                  '${soldOut ? (checked ? 'none free for these dates' : 'out of stock') : checked ? '$max free' : '$max in stock'}',
                  style: AppTextStyle.p_regular_12(color: soldOut ? AppColors.error : AppColors.textTertiary),
                ),
              ],
            ),
          ),
          CheckoutQuantityStepper(
            value: qty,
            min: 0,
            max: max < 0 ? 0 : max,
            enabled: enabled,
            buttonSize: 34,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

extension on String {
  String? get ifEmptyNull => isEmpty ? null : this;
}
