import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/resort_time.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/checkout_flow_parts.dart';
import '../../../../core/widgets/checkout_parts.dart';
import '../../../../data/api/peak_api.dart';
import '../../../../data/services/stripe/checkout_controller.dart';
import '../../../../routes/app_routes.dart';

/// Ski pass checkout: day + number of people → pay → ticket.
///
/// Arguments: `{'id': listingId, 'listing': SkiPassDetail?}`. Ski passes are
/// confirmed at payment (no provider approval) and get a ticket number.
class SetInformation extends StatelessWidget {
  const SetInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: checkoutAppBar(context, 'Checkout'),
      body: CheckoutListingGate<SkiPassDetail>(
        kind: ServiceKind.skiPass,
        noun: 'ski pass',
        builder: (_, pass) => PassCheckoutForm(pass: pass),
      ),
    );
  }
}

class PassCheckoutForm extends StatefulWidget {
  const PassCheckoutForm({super.key, required this.pass, this.checkout});

  final SkiPassDetail pass;

  /// Injected in tests.
  final CheckoutController? checkout;

  @override
  State<PassCheckoutForm> createState() => _PassCheckoutFormState();
}

class _PassCheckoutFormState extends State<PassCheckoutForm> {
  static const minGuests = 1;
  static const _bookingWindowDays = 365;

  late final CheckoutController _checkout = widget.checkout ?? CheckoutController();

  int _guests = minGuests;
  DateTime? _date;
  bool _showErrors = false;

  SkiPassDetail get _pass => widget.pass;
  int get maxGuests => _pass.maxPeoplePerBooking;

  String? get _dateError {
    if (_date == null) return 'Please choose a date';
    if (_date!.isBefore(resortToday())) return 'This day has already passed';
    return null;
  }

  num get _estimate => _pass.price.amount * _guests;

  BookingRequest _request() => BookingRequest.skiPass(productId: _pass.id, day: _date!, persons: _guests);

  num _total() => _date == null ? _estimate : (_checkout.quotedAmountFor(_request()) ?? _estimate);

  Future<void> _pickDate() async {
    final today = resortToday();
    FocusManager.instance.primaryFocus?.unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date != null && !_date!.isBefore(today) ? _date! : today,
      firstDate: today,
      lastDate: today.add(const Duration(days: _bookingWindowDays)),
      helpText: 'Select visit date',
      builder: checkoutPickerTheme,
    );
    if (picked != null && mounted) {
      setState(() => _date = picked);
      _checkout.clearProblem();
    }
  }

  Future<void> _pay() async {
    if (_checkout.isBusy) return;
    FocusScope.of(context).unfocus();
    if (!_checkout.needsConfirmRetry) {
      setState(() => _showErrors = true);
      if (_dateError != null) return;
    }
    // A retry after payment re-sends what was paid for; the request is ignored.
    final outcome = await _checkout.pay(_request(), shownAmount: _total());
    if (!mounted) return;
    handleCheckoutOutcome(context, _checkout, outcome,
        checkoutRoute: Routes.passInformation, detailsRoute: Routes.passCardDetails);
  }

  @override
  Widget build(BuildContext context) {
    return CheckoutPopGuard(
      checkout: _checkout,
      child: ListenableBuilder(
        listenable: _checkout,
        builder: (context, _) {
          final locked = _checkout.isLocked;
          final total = _total();
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        CheckoutSummaryCard(
                          imageUrl: _pass.thumbnail ?? '',
                          title: _pass.title,
                          location: _pass.serviceArea,
                          price: checkoutEuro(_pass.price.amount),
                          priceSuffix: ' / person',
                        ),
                        const CheckoutSectionLabel('Guests'),
                        CheckoutCard(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Number of people', style: AppTextStyle.sub_h3_medium_14()),
                                    const SizedBox(height: 2),
                                    Text('Up to $maxGuests per booking',
                                        style: AppTextStyle.p_regular_12(color: AppColors.textTertiary)),
                                  ],
                                ),
                              ),
                              CheckoutQuantityStepper(
                                value: _guests,
                                min: minGuests,
                                max: maxGuests,
                                enabled: !locked,
                                unit: 'people',
                                onChanged: (v) {
                                  setState(() => _guests = v);
                                  _checkout.clearProblem();
                                },
                              ),
                            ],
                          ),
                        ),
                        const CheckoutSectionLabel('When'),
                        CheckoutCard(
                          padding: EdgeInsets.zero,
                          child: CheckoutPickerTile(
                            icon: Icons.calendar_today_rounded,
                            label: 'Date',
                            value: _date == null ? null : DateFormat('EEE, d MMM yyyy').format(_date!),
                            placeholder: 'Choose a date',
                            error: _showErrors ? _dateError : null,
                            enabled: !locked,
                            onTap: _pickDate,
                          ),
                        ),
                        const CheckoutSectionLabel('Price details'),
                        CheckoutCard(
                          child: CheckoutPriceBreakdown(
                            lines: [
                              (
                                '${checkoutEuro(_pass.price.amount)} × $_guests ${_guests == 1 ? 'person' : 'people'}',
                                checkoutEuro(_estimate),
                              ),
                            ],
                            total: total.toDouble(),
                            footnote: total != _estimate ? 'Price confirmed by the server.' : null,
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
        },
      ),
    );
  }
}
