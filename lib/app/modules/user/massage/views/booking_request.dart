import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/utils/resort_time.dart';
import '../../../../core/widgets/checkout_flow_parts.dart';
import '../../../../core/widgets/checkout_parts.dart';
import '../../../../data/api/peak_api.dart';
import '../../../../data/services/stripe/checkout_controller.dart';
import '../../../../data/services/stripe/checkout_math.dart';
import '../../../../routes/app_routes.dart';

/// Massage checkout: duration, day, start time (inside opening hours, the
/// session must end by closing time), persons, phone → pay. The provider
/// then approves.
///
/// Arguments: `{'id': listingId, 'listing': MassageDetail?,
/// 'durationId': String?}` (pre-selected duration).
class MassageCheckoutScreen extends StatelessWidget {
  const MassageCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final pre = args is Map ? args['durationId'] : null;
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: checkoutAppBar(context, 'Book a massage'),
      body: CheckoutListingGate<MassageDetail>(
        kind: ServiceKind.massage,
        noun: 'massage',
        builder: (_, m) => MassageCheckoutForm(massage: m, initialDurationId: pre is String ? pre : null),
      ),
    );
  }
}

class MassageCheckoutForm extends StatefulWidget {
  const MassageCheckoutForm({
    super.key,
    required this.massage,
    this.initialDurationId,
    this.checkout,
    this.now,
    this.loadSlots,
  });

  final MassageDetail massage;
  final String? initialDurationId;
  final CheckoutController? checkout;

  /// Injected in tests.
  final DateTime Function()? now;

  /// Free places per start time; defaults to the API. Injected in tests.
  final Future<ApiResult<Availability>> Function(DateTime day, String duration, int persons)? loadSlots;

  @override
  State<MassageCheckoutForm> createState() => _MassageCheckoutFormState();
}

class _MassageCheckoutFormState extends State<MassageCheckoutForm> {
  static const maxPersons = 6;

  /// Start times from the server (places left); null until loaded or when
  /// the call fails (then every time in opening hours is offered and the
  /// server still checks on payment).
  List<SessionSlot>? _slots;
  bool _slotsLoading = false;
  int _slotRequest = 0;

  late final CheckoutController _checkout = widget.checkout ?? CheckoutController();
  final _contact = CheckoutContact();

  MassageDuration? _duration;
  DateTime? _day;
  int? _start; // minutes after midnight
  int _persons = 1;
  bool _showErrors = false;

  MassageDetail get _m => widget.massage;
  /// Session times are Paris (resort) clock times, so "now" is too.
  DateTime _now() => widget.now != null ? widget.now!() : resortNow();

  @override
  void initState() {
    super.initState();
    final ds = _m.durations;
    _duration = ds.where((d) => d.id == widget.initialDurationId).firstOrNull ?? (ds.length == 1 ? ds.first : null);
  }

  @override
  void dispose() {
    _contact.dispose();
    super.dispose();
  }

  List<int> get _times => (_duration == null || _day == null)
      ? const []
      : sessionStartTimes(
          openTime: _m.openTime,
          closeTime: _m.closeTime,
          durationMinutes: _duration!.minutes ?? 60,
          day: _day!,
          now: _now(),
        );

  String? get _durationError => _duration == null ? 'Choose a duration' : null;
  String? get _dayError => _day == null ? 'Choose a day' : null;
  String? get _timeError {
    if (_start == null) return 'Choose a start time';
    if (!_times.contains(_start)) return 'This time is no longer available';
    if (!_isFree(_start!)) return 'This time is already booked. Choose another time.';
    return null;
  }

  /// Guests the listing can take at once (never more than [maxPersons] here).
  int get _maxPersons => _m.capacity.clamp(1, maxPersons);

  SessionSlot? _slotAt(int minutes) {
    final label = formatClock(minutes);
    return _slots?.where((s) => s.time == label).firstOrNull;
  }

  /// Unknown times count as free; the server has the final say.
  bool _isFree(int minutes) {
    final slot = _slotAt(minutes);
    return slot == null || (slot.available && !slot.isPast && slot.left >= _persons);
  }

  Future<void> _loadSlots() async {
    final day = _day, duration = _duration;
    if (day == null || duration == null) return;
    final load = widget.loadSlots ??
        (Get.isRegistered<PeakApi>()
            ? (DateTime d, String du, int p) => Get.find<PeakApi>().bookings.massageSlots(_m.id, d, du, p)
            : null);
    if (load == null) return;
    final id = ++_slotRequest;
    setState(() => _slotsLoading = true);
    final r = await load(day, duration.duration, _persons);
    if (!mounted || id != _slotRequest) return;
    setState(() {
      _slotsLoading = false;
      _slots = r.isSuccess ? r.data?.sessions : null;
    });
  }

  bool get _isValid =>
      _durationError == null && _dayError == null && _timeError == null && _contact.phoneError(required: false) == null;

  BookingRequest _request() => BookingRequest.massage(
        productId: _m.id,
        day: _day!,
        time: formatClock(_start!),
        duration: _duration!.duration,
        persons: _persons,
        phoneNumber: _contact.phone,
      );

  num get _estimate => (_duration?.price ?? _m.price.amount) * _persons;

  num get _total {
    if (_duration == null || _day == null || _start == null) return _estimate;
    return _checkout.quotedAmountFor(_request()) ?? _estimate;
  }

  Future<void> _pickDay() async {
    final today = DateUtils.dateOnly(_now());
    FocusManager.instance.primaryFocus?.unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: _day != null && !_day!.isBefore(today) ? _day! : today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      helpText: 'Massage day',
      builder: checkoutPickerTheme,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _day = picked;
      _slots = null;
      if (_start != null && !_times.contains(_start)) _start = null;
    });
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
    // Someone may have taken the time meanwhile (409): show what is left.
    _loadSlots();
    handleCheckoutOutcome(context, _checkout, outcome,
        checkoutRoute: Routes.bookingRequest, detailsRoute: Routes.massageDetails);
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
    final times = _times;
    final hours = (_m.openTime != null && _m.closeTime != null) ? '${_m.openTime} – ${_m.closeTime}' : null;

    if (_m.durations.isEmpty) {
      return CheckoutStateView(
        icon: Icons.spa_outlined,
        title: 'Not bookable yet',
        message: 'This massage has no durations or prices yet.',
        actionLabel: 'Go back',
        onAction: () => Navigator.maybePop(context),
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
                    imageUrl: _m.thumbnail ?? '',
                    title: _m.title,
                    location: _m.serviceArea,
                    price: 'From ${checkoutEuro(_m.price.amount)}',
                    priceSuffix: ' / person',
                  ),
                  const CheckoutSectionLabel('Duration'),
                  CheckoutCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final d in _m.durations)
                              _Chip(
                                label: '${d.label} · ${checkoutEuro(d.price)}',
                                selected: _duration?.id == d.id,
                                enabled: !locked,
                                onTap: () {
                                  setState(() {
                                    _duration = d;
                                    _slots = null;
                                    if (_start != null && !_times.contains(_start)) _start = null;
                                  });
                                  _checkout.clearProblem();
                                  _loadSlots();
                                },
                              ),
                          ],
                        ),
                        if (_showErrors && _durationError != null) _ErrorText(_durationError!),
                      ],
                    ),
                  ),
                  const CheckoutSectionLabel('When'),
                  CheckoutCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckoutPickerTile(
                          icon: Icons.calendar_today_rounded,
                          label: 'Day',
                          value: _day == null ? null : DateFormat('EEE, d MMM yyyy').format(_day!),
                          placeholder: 'Choose a day',
                          error: _showErrors ? _dayError : null,
                          enabled: !locked,
                          onTap: _pickDay,
                        ),
                        if (_day != null && _duration != null) ...[
                          const Divider(height: 1, color: AppColors.divider),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: times.isEmpty
                                ? Text(
                                    hours == null
                                        ? 'Opening hours are missing. Contact the provider.'
                                        : 'No start time fits a ${_duration!.label} session on this day (open $hours). '
                                            'Try another day or a shorter duration.',
                                    style: AppTextStyle.p_regular_12(color: AppColors.error),
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          _slotsLoading
                                              ? 'Checking free times…'
                                              : 'Start time, Paris time${hours == null ? '' : ' (open $hours)'}',
                                          style: AppTextStyle.p_regular_12(color: AppColors.textTertiary)),
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          for (final t in times)
                                            _Chip(
                                              label: formatClock(t),
                                              selected: _start == t,
                                              enabled: !locked && _isFree(t),
                                              taken: !_isFree(t),
                                              onTap: () {
                                                setState(() => _start = t);
                                                _checkout.clearProblem();
                                              },
                                            ),
                                        ],
                                      ),
                                      if (_slots != null && times.any((t) => !_isFree(t)))
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: Text(
                                            'Crossed-out times are booked${_persons > 1 ? ' or have fewer than $_persons places' : ''}.',
                                            style: AppTextStyle.p_regular_12(color: AppColors.textTertiary),
                                          ),
                                        ),
                                      if ((_showErrors || (_start != null && !_isFree(_start!))) && _timeError != null)
                                        _ErrorText(_timeError!),
                                    ],
                                  ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const CheckoutSectionLabel('People'),
                  CheckoutCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text('Number of people', style: AppTextStyle.sub_h3_medium_14())),
                            CheckoutQuantityStepper(
                              value: _persons,
                              min: 1,
                              max: _maxPersons,
                              enabled: !locked,
                              unit: 'people',
                              onChanged: (v) {
                                setState(() => _persons = v);
                                _checkout.clearProblem();
                                _loadSlots();
                              },
                            ),
                          ],
                        ),
                        if (_m.capacity == 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'This massage is for one guest at a time.',
                              style: AppTextStyle.p_regular_12(color: AppColors.textTertiary),
                            ),
                          ),
                      ],
                    ),
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
                        if (_duration != null)
                          ('${_duration!.label} × $_persons ${_persons == 1 ? 'person' : 'people'}', checkoutEuro(_estimate)),
                      ],
                      total: total.toDouble(),
                      footnote: 'The provider confirms your booking. If they decline, you are refunded in full.',
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
          onPressed: _pay,
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.enabled, required this.onTap, this.taken = false});
  final String label;
  final bool selected;
  final bool enabled;

  /// Already booked: crossed out and not selectable.
  final bool taken;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (taken && !selected) {
      return Semantics(
        label: '$label, booked',
        child: ChoiceChip(
          label: Text(label),
          selected: false,
          onSelected: null,
          showCheckmark: false,
          backgroundColor: AppColors.surfaceAlt,
          disabledColor: AppColors.surfaceAlt,
          labelStyle: AppTextStyle.sub_h3_medium_14(color: AppColors.textTertiary).copyWith(
            decoration: TextDecoration.lineThrough,
            decorationColor: AppColors.textTertiary,
          ),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: enabled ? (_) => onTap() : null,
      showCheckmark: false,
      selectedColor: AppColors.primary_1,
      backgroundColor: Colors.white,
      labelStyle: AppTextStyle.sub_h3_medium_14(color: selected ? Colors.white : AppColors.textPrimary),
      side: BorderSide(color: selected ? AppColors.primary_1 : AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(text, style: AppTextStyle.p_regular_12(color: AppColors.error)),
      );
}
