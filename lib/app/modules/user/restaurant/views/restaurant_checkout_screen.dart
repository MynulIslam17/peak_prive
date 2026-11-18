import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/resort_time.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/checkout_flow_parts.dart';
import '../../../../core/widgets/checkout_parts.dart';
import '../../../../data/api/peak_api.dart';
import '../../../../data/services/stripe/checkout_controller.dart';
import '../../../../data/services/stripe/checkout_math.dart';
import '../../../../routes/app_routes.dart';

/// Restaurant checkout: date → time slot (free seats from
/// `GET /booking/availability?date=`) → seats per type → phone → pay.
/// Total = Σ seat price × seats + the service fee.
///
/// Arguments: `{'id': listingId, 'listing': RestaurantDetail?,
/// 'seats': {seatTypeId: int}?}` (pre-selection).
class RestaurantCheckoutScreen extends StatelessWidget {
  const RestaurantCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final s = args is Map ? args['seats'] : null;
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: checkoutAppBar(context, 'Reserve a table'),
      body: CheckoutListingGate<RestaurantDetail>(
        kind: ServiceKind.restaurant,
        noun: 'restaurant',
        builder: (_, r) => RestaurantCheckoutForm(
          restaurant: r,
          initialSeats: s is Map
              ? {
                  for (final e in s.entries)
                    if (e.key is String && e.value is int) e.key as String: e.value as int,
                }
              : const {},
        ),
      ),
    );
  }
}

class RestaurantCheckoutForm extends StatefulWidget {
  const RestaurantCheckoutForm({super.key, required this.restaurant, this.initialSeats = const {}, this.checkout});

  final RestaurantDetail restaurant;
  final Map<String, int> initialSeats;
  final CheckoutController? checkout;

  @override
  State<RestaurantCheckoutForm> createState() => _RestaurantCheckoutFormState();
}

class _RestaurantCheckoutFormState extends State<RestaurantCheckoutForm> {
  late final CheckoutController _checkout = widget.checkout ?? CheckoutController();
  final _contact = CheckoutContact();

  DateTime? _day;
  String? _slotId;
  late Map<String, int> _seats;
  bool _showErrors = false;

  List<SlotAvailability>? _slots;
  bool _loadingSlots = false;
  String? _slotsError;
  int _ticket = 0;

  RestaurantDetail get _r => widget.restaurant;

  @override
  void initState() {
    super.initState();
    _seats = clampQuantities(widget.initialSeats, {for (final s in _r.seats) s.id: s.quantity});
  }

  @override
  void dispose() {
    _contact.dispose();
    super.dispose();
  }

  SlotAvailability? get _slot => _slots?.where((s) => s.slotId == _slotId).firstOrNull;

  /// Free seats of [seat] in the chosen slot (total count before a slot is chosen).
  int _maxFor(SeatType seat) => _slot?.seat(seat.id)?.available ?? (_slot == null ? seat.quantity : 0);

  Future<void> _loadSlots() async {
    final day = _day;
    if (day == null) return;
    final ticket = ++_ticket;
    setState(() {
      _loadingSlots = true;
      _slotsError = null;
    });
    final r = await Get.find<PeakApi>().bookings.restaurantAvailability(_r.id, day);
    if (!mounted || ticket != _ticket) return;
    setState(() {
      _loadingSlots = false;
      if (r.isSuccess) {
        _slots = r.data!.slots;
        final still = _slot;
        if (still == null || !still.isBookable) _slotId = null;
        _clampSeats();
      } else {
        _slots = null;
        _slotId = null;
        _slotsError = r.errorMessage;
      }
    });
  }

  void _clampSeats() {
    _seats = clampQuantities(_seats, {for (final s in _r.seats) s.id: _maxFor(s)});
  }

  int get _seatCount => _seats.values.fold(0, (a, b) => a + b);

  String? get _dayError => _day == null ? 'Choose a date' : null;
  String? get _slotError => _slotId == null ? 'Choose a time' : null;
  String? get _seatsError => _seatCount == 0 ? 'Choose at least one seat' : null;

  bool get _isValid =>
      _dayError == null && _slotError == null && _seatsError == null && _contact.phoneError(required: false) == null;

  BookingRequest _request() => BookingRequest.restaurant(
        productId: _r.id,
        day: _day!,
        slotId: _slotId!,
        seats: [for (final e in _seats.entries) ItemQuantity(e.key, e.value)],
        phoneNumber: _contact.phone,
      );

  num get _seatsTotal => _r.seats.fold<num>(0, (s, seat) => s + seat.price * (_seats[seat.id] ?? 0));

  num get _estimate => _seatCount == 0 ? 0 : _seatsTotal + _r.serviceFee;

  num get _total {
    if (_day == null || _slotId == null || _seatCount == 0) return _estimate;
    return _checkout.quotedAmountFor(_request()) ?? _estimate;
  }

  Future<void> _pickDay() async {
    final today = resortToday();
    FocusManager.instance.primaryFocus?.unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: _day != null && !_day!.isBefore(today) ? _day! : today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      helpText: 'Reservation date',
      builder: checkoutPickerTheme,
    );
    if (picked == null || !mounted) return;
    setState(() => _day = picked);
    _checkout.clearProblem();
    _loadSlots();
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
        checkoutRoute: Routes.restaurantCheckout, detailsRoute: Routes.restaurantDetails);
    final kind = _checkout.problem?.kind;
    if (!booked && (kind == CheckoutProblemKind.unavailable || kind == CheckoutProblemKind.rejectedAfterPayment)) {
      _loadSlots();
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
    final total = _total;

    if (_r.seats.isEmpty || _r.slots.isEmpty) {
      return CheckoutStateView(
        icon: Icons.table_restaurant_outlined,
        title: 'Not bookable yet',
        message: 'This restaurant has no seats or time slots yet.',
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
                    imageUrl: _r.thumbnail ?? '',
                    title: _r.title,
                    location: _r.serviceArea,
                    price: 'From ${checkoutEuro(_r.price.amount)}',
                    priceSuffix: ' / seat',
                  ),
                  const CheckoutSectionLabel('Date'),
                  CheckoutCard(
                    padding: EdgeInsets.zero,
                    child: CheckoutPickerTile(
                      icon: Icons.calendar_today_rounded,
                      label: 'Reservation date',
                      value: _day == null ? null : DateFormat('EEE, d MMM yyyy').format(_day!),
                      placeholder: 'Choose a date',
                      error: _showErrors ? _dayError : null,
                      enabled: !locked,
                      onTap: _pickDay,
                    ),
                  ),
                  if (_day != null) ...[
                    const CheckoutSectionLabel('Time'),
                    CheckoutCard(child: _buildSlots(locked)),
                  ],
                  const CheckoutSectionLabel('Seats'),
                  CheckoutCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Column(
                      children: [
                        for (var i = 0; i < _r.seats.length; i++) ...[
                          if (i > 0) const Divider(height: 1, color: AppColors.divider),
                          _SeatRow(
                            seat: _r.seats[i],
                            qty: _seats[_r.seats[i].id] ?? 0,
                            max: _maxFor(_r.seats[i]),
                            inSlot: _slot != null,
                            enabled: !locked && !_loadingSlots,
                            onChanged: (v) {
                              setState(() {
                                if (v <= 0) {
                                  _seats.remove(_r.seats[i].id);
                                } else {
                                  _seats[_r.seats[i].id] = v;
                                }
                              });
                              _checkout.clearProblem();
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_showErrors && _seatsError != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                      child: Text(_seatsError!, style: AppTextStyle.p_regular_12(color: AppColors.error)),
                    ),
                  const CheckoutSectionLabel('Contact'),
                  CheckoutContactCard(
                    contact: _contact,
                    enabled: !locked,
                    onChanged: () => setState(() {}),
                    phoneError: _showErrors ? _contact.phoneError(required: false) : null,
                  ),
                  const CheckoutSectionLabel('Price details'),
                  CheckoutCard(
                    child: CheckoutPriceBreakdown(
                      lines: [
                        for (final seat in _r.seats)
                          if ((_seats[seat.id] ?? 0) > 0)
                            ('${seat.type} × ${_seats[seat.id]}', checkoutEuro(seat.price * _seats[seat.id]!)),
                        if (_seatCount > 0 && _r.serviceFee > 0) ('Service fee', checkoutEuro(_r.serviceFee)),
                      ],
                      total: total.toDouble(),
                      footnote: 'The restaurant confirms your table. If they decline, you are refunded in full.',
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
          onPressed: _loadingSlots ? null : _pay,
        ),
      ],
    );
  }

  Widget _buildSlots(bool locked) {
    if (_loadingSlots) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(color: AppColors.primary_1, minHeight: 2),
      );
    }
    if (_slotsError != null) {
      return Row(
        children: [
          Expanded(
            child: Text('Could not load times: $_slotsError',
                style: AppTextStyle.p_regular_12(color: AppColors.error)),
          ),
          TextButton(onPressed: _loadSlots, child: const Text('Retry')),
        ],
      );
    }
    final slots = _slots ?? const <SlotAvailability>[];
    if (!slots.any((s) => s.isBookable)) {
      return Text('No free tables on this day. Try another date.',
          style: AppTextStyle.p_regular_12(color: AppColors.error));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in slots)
              ChoiceChip(
                label: Text(s.isPast ? '${s.label} · passed' : s.freeSeats == 0 ? '${s.label} · full' : s.label),
                selected: _slotId == s.slotId,
                onSelected: locked || !s.isBookable
                    ? null
                    : (_) {
                        setState(() {
                          _slotId = s.slotId;
                          _clampSeats();
                        });
                        _checkout.clearProblem();
                      },
                showCheckmark: false,
                selectedColor: AppColors.primary_1,
                backgroundColor: Colors.white,
                disabledColor: AppColors.surfaceAlt,
                labelStyle: AppTextStyle.sub_h3_medium_14(
                  color: _slotId == s.slotId
                      ? Colors.white
                      : s.isBookable
                          ? AppColors.textPrimary
                          : AppColors.textDisabled,
                ),
                side: BorderSide(color: _slotId == s.slotId ? AppColors.primary_1 : AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
          ],
        ),
        if (_showErrors && _slotError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_slotError!, style: AppTextStyle.p_regular_12(color: AppColors.error)),
          ),
      ],
    );
  }
}

class _SeatRow extends StatelessWidget {
  const _SeatRow({
    required this.seat,
    required this.qty,
    required this.max,
    required this.inSlot,
    required this.enabled,
    required this.onChanged,
  });

  final SeatType seat;
  final int qty;
  final int max;
  final bool inSlot;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(seat.type, style: AppTextStyle.sub_h3_medium_14()),
                const SizedBox(height: 2),
                Text(
                  '${checkoutEuro(seat.price)} / seat · '
                  '${max <= 0 ? 'none free' : inSlot ? '$max free at this time' : '$max seats'}',
                  style: AppTextStyle.p_regular_12(color: max <= 0 ? AppColors.error : AppColors.textTertiary),
                ),
              ],
            ),
          ),
          CheckoutQuantityStepper(
            value: qty,
            min: 0,
            max: max < 0 ? 0 : max,
            enabled: enabled,
            unit: 'seats',
            buttonSize: 34,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
