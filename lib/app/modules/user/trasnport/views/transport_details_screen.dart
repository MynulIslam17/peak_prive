import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/widgets/cusom_text_fiield.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/core/widgets/custome_button.dart';
import 'package:harry_service_app/app/core/widgets/provider_info.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/transport_details_shimmer.dart';
import 'package:harry_service_app/app/modules/user/pass/controllers/pass_booking_controller.dart';
import 'package:harry_service_app/app/modules/user/trasnport/controlers/trasnport_details_controller.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../core/widgets/custome_back_button.dart';
import '../../../../data/services/stripe/payment_result.dart';
import '../../../../data/services/stripe/stripe_config.dart';
import '../../../../data/services/stripe/stripe_helper.dart';
import '../../../../core/constants/env_config.dart';
import '../../../../routes/app_routes.dart';

class TransportDetailsScreen extends StatefulWidget {
  const TransportDetailsScreen({super.key});

  @override
  State<TransportDetailsScreen> createState() => _TransportDetailsScreenState();
}

class _TransportDetailsScreenState extends State<TransportDetailsScreen> {
  late StripePaymentHelper _paymentHelper;
  bool _isProcessingPayment = false;
  late final String productId;
  final destinationTEController=TextEditingController();

  final transportController = Get.find<TransportDetailsController>();
  final createBookingController = Get.find<CreateBookingController>();
  final authController = Get.find<AuthController>();

  final image = Assets.images;
  final icon = Assets.icons;

  int? totalPrice;
  bool _isRentClicked = false;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  @override
  void initState() {
    super.initState();
    productId = Get.arguments["id"];
    _fetchDetails();
    _initializeStripeHelper();
  }

  void _initializeStripeHelper() {
    final config = StripeConfig(
      secretKey: EnvConfig.stripeSk,
      merchantDisplayName: 'Harry Service',
      paymentSheetTheme: ThemeMode.light,
      allowsDelayedPaymentMethods: true,
    );

    _paymentHelper = StripePaymentHelper(
      config: config,
      onPaymentSuccess: (result) => setState(() => _isProcessingPayment = false),
      onPaymentFailure: (result) => setState(() => _isProcessingPayment = false),
      onLog: (message) => debugPrint('StripeLog: $message'),
    );
  }

  Future<void> _fetchDetails() async {
    await transportController.fetchTransportDetails(productId);
  }

  Future<DateTime?> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String getTotalDuration(DateTime? start, DateTime? end) {
    if (start == null || end == null) return "Not selected";
    final duration = end.difference(start);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    String result = "";
    if (days > 0) result += "$days day${days > 1 ? 's' : ''} ";
    if (hours > 0) result += "$hours hr ";
    if (minutes > 0 && days == 0) result += "$minutes min";
    return result.isEmpty ? "0 min" : result.trim();
  }

  int calculateTotalRate(int ratePerHour, DateTime? start, DateTime? end) {
    if (start == null || end == null) return 0;
    final duration = end.difference(start);
    final totalHours = duration.inMinutes / 60;
    totalPrice = (totalHours * ratePerHour).ceil();
    return totalPrice!;
  }

  Future<void> _createBooking(Map<String, dynamic> reqBody) async {
    bool success = await createBookingController.proceedBooking(reqBody);
    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60.sp),
              SizedBox(height: 16.h),
              Text("Booking Successful!", style: AppTextStyle.sub_h2_medium_16(color: Colors.green)),
            ],
          ),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pop();
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<TransportDetailsController>(
        builder: (controller) {
          if (controller.fetchProgress) return const TransportDetailsSkeleton();
          if (controller.transportDetails == null) return const Center(child: Text("Failed to load details"));

          final transport = controller.transportDetails!;
          final owner = transport.owner;

          return SafeArea(
            child: SlidingUpPanel(
              maxHeight: size.height * 0.97,
              minHeight: size.height * 0.45,
              parallaxEnabled: true,
              parallaxOffset: 0.5,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              // Persistent Footer logic
              footer: _buildPersistentFooter(transport),
              panelBuilder: (scrollController) => _buildSlidingContent(
                context: context,
                transport: transport,
                owner: owner,
                scrollController: scrollController,
              ),
              body: Stack(
                children: [

                  Image.network(
                    transport.thumbnail.isNotEmpty ? transport.thumbnail : "",
                    height: size.height * 0.6,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                  ),
                  Positioned(
                    top: 50.h,
                    left: 20.w,
                    child: CustomBackButton(onTap: Get.back),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlidingContent({
    required BuildContext context,
    required dynamic transport,
    required dynamic owner,
    required ScrollController scrollController,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.only(bottom: 150), // Extra space for footer
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 60,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
          ),
          if (_isRentClicked) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(transport.title, style: AppTextStyle.sub_h1_medium_18()),
                Text("\$${transport.amount}/ hr", style: AppTextStyle.sub_h3_medium_14(color: AppColors.primary_1)),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              color: const Color(0xFFFDFAF6),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child:Column(
                  children: [
                    Row(
                      children: [
                        _buildDateSelector("Start Date", selectedStartDate, (date) => setState(() => selectedStartDate = date)),
                        const SizedBox(width: 15),
                        _buildDateSelector("End Date", selectedEndDate, (date) => setState(() => selectedEndDate = date)),
                      ],
                    ),
                    const SizedBox(height: 10,),
                  
                    CustomTextField(
                          prefixIcon: Icons.location_on,
                         controller: destinationTEController,
                        hintText: "Destination"


                    )

                  ],
                )
              ),
            ),
          ] else ...[
            ProviderInfo(
              image: owner.profileUrl,
              providerName: owner.fullName,
              rating: transport.averageRating.toString(),
              reviewCount: transport.reviews.length,
              onTapCall: () {
                //TODO : call provider
                makePhoneCall(owner.phoneNumber);

              },
              onTapMessage: () {
                //TODO : message provider

                Get.toNamed(
                  Routes.messagingScreen,
                  arguments: {
                    'otherUserId': owner.id,
                    'chatId': '',
                    'otherUserName': owner.fullName,
                    'otherUserProfileUrl': owner.profileUrl,
                    'isOnline': false,
                  },
                );



              },
            ),
            const SizedBox(height: 15),
            Text(transport.description, style: AppTextStyle.p_regular_12().copyWith(fontSize: 14, color: AppColors.black_2)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _priceRow("Insurance Fee", transport.insuranceFee),
                  const Divider(),
                  _priceRow("Maintain Charge", transport.maintainCharge),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPersistentFooter(dynamic transport) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(context).padding.bottom + 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: _isRentClicked ? _buildCheckoutSection(transport) : _buildRentNowSection(transport),
    );
  }

  Widget _buildRentNowSection(dynamic transport) {
    return Row(
      children: [
        Text("\$${transport.amount}/hr", style: AppTextStyle.sub_h1_medium_18(color: AppColors.primary_1)),
        const Spacer(),
        SizedBox(
          width: 180.w,
          child: CustomButton(text: "Rent Car", onTap: () => setState(() => _isRentClicked = true)),
        ),
      ],
    );
  }

  Widget _buildCheckoutSection(dynamic transport) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(color: const Color(0xffF3F3F3), borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoTile(icon.time, getTotalDuration(selectedStartDate, selectedEndDate)),
              _verticalDivider(),
              _infoTile(icon.carProfile, "1 Car"),
              _verticalDivider(),
              _infoTile(icon.currencyCircleDollar, "\$${calculateTotalRate(transport.amount, selectedStartDate, selectedEndDate)}"),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GetBuilder<CreateBookingController>(
          builder: (controller) {
            return controller.bookingProgress
                ? const CircularProgressIndicator()
                : CustomButton(
              text: "Checkout",
              width: double.infinity,
              onTap: _handleCheckout,
            );
          },
        ),
      ],
    );
  }

  Future<void> _handleCheckout() async {
    if (_isProcessingPayment) return;

    if (selectedStartDate == null || selectedEndDate == null) {
      Get.snackbar("Error", "Please select dates", backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }



    if (destinationTEController.text.trim().isEmpty) {
      Get.snackbar("Error", "Destination is required",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final payment = await _paymentHelper.processPayment(
      context: context,
      amount: (totalPrice ?? 0).toDouble(),
      currency: 'USD',
      description: 'Car Rental',
    );

    if (payment.isSuccess) {
      await _createBooking({
        "userId": authController.userModel!.id,
        "productId": productId,
        "totalPrice": totalPrice,
        "destination": destinationTEController.text.trim(),
        "startDateAndTime": selectedStartDate!.toIso8601String(),
        "endDateAndTime": selectedEndDate!.toIso8601String(),
        "transactionId": payment.paymentData?['transactionId'],
      });
    }
  }

  Widget _buildDateSelector(String label, DateTime? date, Function(DateTime) onPick) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          InkWell(
            onTap: () async {
              final picked = await _pickDateTime();
              if (picked != null) onPick(picked);
            },
            child: _dateBox(date),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(dynamic svgIcon, String text) {
    return Row(
      children: [

        svgIcon.svg(width: 16.0, height: 16.0, color: AppColors.primary_1),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyle.p_medium_12(color: AppColors.primary_1)),
      ],
    );
  }

  Widget _verticalDivider() => Container(height: 20, width: 1, color: Colors.grey[300]);

  Widget _priceRow(String label, int value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyle.sub_h3_medium_14()),
        Text("\$$value", style: AppTextStyle.sub_h3_medium_14(color: Colors.black87)),
      ],
    ),
  );

  Widget _dateBox(DateTime? date) {
    return Container(
      height: 40,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8), color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          icon.calendarDots.svg(width: 16.0, height: 16.0),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              date == null ? "Pick Date" : "${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
              style: const TextStyle(fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}