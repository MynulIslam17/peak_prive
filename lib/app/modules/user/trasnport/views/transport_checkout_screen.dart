import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/checkout_flow_parts.dart';
import '../../../../core/widgets/checkout_parts.dart';
import '../../../../data/api/peak_api.dart';
import '../../../../data/services/stripe/checkout_controller.dart';
import '../../../../routes/app_routes.dart';

/// Transport checkout: start/end, passengers (≤ seats), pick-up address,
/// destination, phone → pay. One price per booking (`price.amount`).
///
/// Arguments: `{'id': listingId, 'listing': TransportDetail?}`.
class TransportCheckoutScreen extends StatelessWidget {
  const TransportCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: checkoutAppBar(context, 'Checkout'),
      body: CheckoutListingGate<TransportDetail>(
        kind: ServiceKind.transport,
        noun: 'vehicle',
        builder: (_, t) => TransportCheckoutForm(transport: t),
      ),
    );
  }
}

class TransportCheckoutForm extends StatefulWidget {
  const TransportCheckoutForm({super.key, required this.transport, this.checkout});

  final TransportDetail transport;
  final CheckoutController? checkout;

  @override
  State<TransportCheckoutForm> createState() => _TransportCheckoutFormState();
}

class _TransportCheckoutFormState extends State<TransportCheckoutForm> {
  static const _minTrip = Duration(minutes: 1); // server: end after start

  late final CheckoutController _checkout = widget.checkout ?? CheckoutController();
  final _contact = CheckoutContact();

  DateTime? _start;
  DateTime? _end;
  int _passengers = 1;
  bool _showErrors = false;

  /// Result of the availability check for [_start]–[_end]; null = unknown.
  bool? _free;

  /// The previous customer hasn't returned the vehicle yet.
  bool _notReturned = false;
  bool _checking = false;
  int _ticket = 0;

  TransportDetail get _t => widget.transport;

  /// Seats; very old listings have none, then allow up to 8.
  int get _maxPassengers => (_t.seats ?? 0) > 0 ? _t.seats! : 8;

  @override
  void dispose() {
    _contact.dispose();
    super.dispose();
  }

  Future<void> _checkAvailability() async {
    final s = _start, e = _end;
    if (s == null || e == null || _endError != null) return;
    final ticket = ++_ticket;
    setState(() {
      _checking = true;
      _free = null;
      _notReturned = false;
    });
    final r = await Get.find<PeakApi>().bookings.availability(_t.id, start: s, end: e);
    if (!mounted || ticket != _ticket) return;
    setState(() {
      _checking = false;
      // A failed check isn't a "no": the server checks again at payment.
      _free = r.isSuccess ? r.data!.available : null;
      _notReturned = r.isSuccess && r.data!.available == false && r.data!.notReturned;
    });
  }

  String? get _startError {
    if (_start == null) return 'Please choose a start time';
    if (!_start!.isAfter(DateTime.now())) return 'This time has already passed';
    return null;
  }

  String? get _endError {
    if (_end == null) return 'Please choose an end time';
    if (_start != null && _end!.difference(_start!) < _minTrip) return 'The end must be after the start';
    return null;
  }

  bool get _isValid =>
      _startError == null &&
      _endError == null &&
      _free != false &&
      _contact.phoneError() == null &&
      _contact.addressError(message: 'Please enter the pick-up address') == null;

  BookingRequest _request() => BookingRequest.transport(
        productId: _t.id,
        start: _start!,
        end: _end!,
        passengers: _passengers,
        phoneNumber: _contact.phone,
        pickupAddress: _contact.address.text,
        destination: _contact.destination.text,
      );

  num get _total {
    if (_start == null || _end == null) return _t.price.amount;
    return _checkout.quotedAmountFor(_request()) ?? _t.price.amount;
  }

  Future<void> _pickStart() async {
    final picked = await pickCheckoutDateTime(context,
        current: _start, firstDate: DateTime.now(), dateHelp: 'Start date', timeHelp: 'Start time');
    if (picked == null || !mounted) return;
    setState(() {
      _start = picked;
      if (_end != null && _end!.difference(picked) < _minTrip) _end = null;
    });
    _checkout.clearProblem();
    _checkAvailability();
  }

  Future<void> _pickEnd() async {
    final picked = await pickCheckoutDateTime(context,
        current: _end ?? _start?.add(const Duration(hours: 2)),
        firstDate: _start ?? DateTime.now(),
        dateHelp: 'End date',
        timeHelp: 'End time');
    if (picked == null || !mounted) return;
    setState(() => _end = picked);
    _checkout.clearProblem();
    _checkAvailability();
  }

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
        checkoutRoute: Routes.transportCheckout, detailsRoute: Routes.transportDetails);
    final kind = _checkout.problem?.kind;
    if (!booked && (kind == CheckoutProblemKind.unavailable || kind == CheckoutProblemKind.rejectedAfterPayment)) {
      _checkAvailability();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CheckoutPopGuard(
      checkout: _checkout,
      child: ListenableBuilder(listenable: _checkout, builder: (context, _) => _buildForm()),
    );
  }

  Widget _buildForm() {
    final locked = _checkout.isLocked;
    final fmt = DateFormat('EEE, d MMM yyyy · h:mm a');
    final hasPeriod = _start != null && _end != null && _endError == null;
    final total = _total;
    final late = _t.extraChargePerHour ?? 0;

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
                    imageUrl: _t.thumbnail ?? '',
                    title: _t.title,
                    location: _t.serviceArea,
                    price: checkoutEuro(_t.price.amount),
                    priceSuffix: ' per booking',
                  ),
                  const CheckoutSectionLabel('Trip'),
                  CheckoutCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        CheckoutPickerTile(
                          icon: Icons.login_rounded,
                          label: 'Start',
                          value: _start == null ? null : fmt.format(_start!),
                          placeholder: 'Choose date & time',
                          error: (_showErrors || _start != null) ? _startError : null,
                          enabled: !locked,
                          onTap: _pickStart,
                        ),
                        const Divider(height: 1, indent: 64, color: AppColors.divider),
                        CheckoutPickerTile(
                          icon: Icons.logout_rounded,
                          label: 'End',
                          value: _end == null ? null : fmt.format(_end!),
                          placeholder: 'Choose date & time',
                          error: (_showErrors || (_start != null && _end != null)) ? _endError : null,
                          enabled: !locked,
                          onTap: _pickEnd,
                        ),
                        if (hasPeriod)
                          CheckoutInfoStrip(
                            icon: _free == false ? Icons.event_busy_rounded : Icons.timelapse_rounded,
                            color: _free == false ? AppColors.error : null,
                            text: _checking
                                ? 'Checking availability…'
                                : _free == false
                                    ? (_notReturned
                                        ? 'The previous customer has not returned this vehicle yet. Choose a later time or another vehicle.'
                                        : 'Already booked for these times. Choose other times.')
                                    : 'Trip length: ${checkoutLengthLabel(_end!.difference(_start!))}',
                          ),
                      ],
                    ),
                  ),
                  const CheckoutSectionLabel('Passengers'),
                  CheckoutCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Number of passengers', style: AppTextStyle.sub_h3_medium_14()),
                              const SizedBox(height: 2),
                              Text('Up to $_maxPassengers seats',
                                  style: AppTextStyle.p_regular_12(color: AppColors.textTertiary)),
                            ],
                          ),
                        ),
                        CheckoutQuantityStepper(
                          value: _passengers,
                          min: 1,
                          max: _maxPassengers,
                          enabled: !locked,
                          unit: 'passengers',
                          onChanged: (v) {
                            setState(() => _passengers = v);
                            _checkout.clearProblem();
                          },
                        ),
                      ],
                    ),
                  ),
                  const CheckoutSectionLabel('Pick-up & contact'),
                  CheckoutContactCard(
                    contact: _contact,
                    enabled: !locked,
                    onChanged: () => setState(() {}),
                    phoneError: _showErrors ? _contact.phoneError() : null,
                    showAddress: true,
                    addressLabel: 'Pick-up address',
                    addressHint: 'Hotel, chalet or street address',
                    addressError: _showErrors ? _contact.addressError(message: 'Please enter the pick-up address') : null,
                    showDestination: true,
                  ),
                  const CheckoutSectionLabel('Price details'),
                  CheckoutCard(
                    child: CheckoutPriceBreakdown(
                      lines: [('Trip (whole booking)', checkoutEuro(_t.price.amount))],
                      total: total.toDouble(),
                      footnote: [
                        'One price for the whole booking, whatever its length.',
                        if (late > 0)
                          'Late return: ${checkoutEuro(late)} per started hour after a 15-minute grace period, '
                              'capped at the booking price.',
                      ].join('\n'),
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
          onPressed: _checking ? null : _pay,
        ),
      ],
    );
  }
}
