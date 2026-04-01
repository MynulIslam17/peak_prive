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
import '../../../../core/utils/date_parser.dart';
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

  Future<DateTime?> _pickDateTime({required bool isStart}) async {
    // ১. তারিখ সিলেক্ট করা
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return null;

    // ২. সময় সিলেক্ট করা (১২ ঘণ্টা ফরম্যাটে)
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (pickedTime == null) return null;

    // ৩. তারিখ এবং সময়কে একত্রে যুক্ত করা
    final combinedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // ৪. বর্তমান মুহূর্ত নির্ধারণ (সেকেন্ড এবং মিলিসেকেন্ড জিরো করে তুলনা করা)
    final now = DateTime.now();
    final currentMoment = DateTime(now.year, now.month, now.day, now.hour, now.minute);

    // ৫. ভ্যালিডেশন চেক
    if (isStart) {
      // বর্তমান সময়ের চেয়ে ৫ মিনিট আগের সময় পর্যন্ত "ভ্যালিড" ধরা হবে (পেমেন্ট বাফার)
      final bufferTime = currentMoment.subtract(const Duration(minutes: 5));

      if (combinedDateTime.isBefore(bufferTime)) {
        Get.snackbar(
          "Invalid Time",
          "Start time cannot be in the past. Please select current or future time.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }
    } else {
      // এন্ড ডেট অবশ্যই স্টার্ট ডেটের পরে হতে হবে
      if (selectedStartDate != null && combinedDateTime.isBefore(selectedStartDate!)) {
        Get.snackbar(
          "Invalid Time",
          "End time cannot be before start time",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }
    }

    return combinedDateTime;
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
                        _buildDateSelector("Start Date", selectedStartDate, (date) => setState(() => selectedStartDate = date), isStart: true),
                        const SizedBox(width: 15),
                        _buildDateSelector("End Date", selectedEndDate, (date) => setState(() => selectedEndDate = date), isStart: false),
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
            return controller.isLoading
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

    // 1️⃣ Validate if dates are selected (Null Check)
    if (selectedStartDate == null || selectedEndDate == null) {
      Get.snackbar(
        "Error",
        "Please select both start and end dates",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // 2️⃣ Start Date Validation: 3-minute backdate limit
    final now = DateTime.now();
    final backdateLimit = now.subtract(const Duration(minutes: 3)); // 3 min backdate
    if (selectedStartDate!.isBefore(backdateLimit)) {
      Get.snackbar(
        "Invalid Start Time",
        "Start time cannot be more than 3 minutes in the past. Please select a valid time.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // 3️⃣ End date should not be before start date
    if (selectedEndDate!.isBefore(selectedStartDate!)) {
      Get.snackbar(
        "Invalid End Time",
        "End time cannot be before start time.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // 4️⃣ Ensure destination is provided
    if (destinationTEController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Destination is required",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // 5️⃣ Start Payment Processing
    setState(() => _isProcessingPayment = true);

    final payment = await _paymentHelper.processPayment(
      context: context,
      amount: (totalPrice ?? 0).toDouble(),
      currency: 'USD',
      description: 'Car Rental',
    );

    // 6️⃣ If payment is successful, proceed to Create Booking API
    if (payment.isSuccess) {
      await _createBooking({
        "userId": authController.userModel!.id,
        "productId": productId,
        "totalPrice": totalPrice,
        "destination": destinationTEController.text.trim(),
        "startDateAndTime": selectedStartDate!.toUtc().toIso8601String(),
        "endDateAndTime": selectedEndDate!.toUtc().toIso8601String(),
        "transactionId": payment.paymentData?['transactionId'],
      });
    } else {
      // Reset processing state if payment fails or is cancelled
      setState(() => _isProcessingPayment = false);
    }
  }

  Widget _buildDateSelector(String label, DateTime? date, Function(DateTime) onPick, {required bool isStart}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          InkWell(
            onTap: () async {
              final picked = await _pickDateTime(isStart: isStart);
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
              DateParserHelper.formatDateTime(date),
              style: const TextStyle(fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}