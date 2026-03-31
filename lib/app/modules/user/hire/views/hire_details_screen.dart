import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/hire_shimmer.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../core/widgets/custome_back_button.dart';
import '../../../../core/widgets/hire_card_item.dart';
import '../../../../core/widgets/provider_info.dart';
import '../../../../core/widgets/selected_hire_tem.dart';
import '../../../../modules/user/pass/controllers/pass_booking_controller.dart';
import '../../../../modules/user/hire/contollers/hire_details_controller.dart';
import '../../../../modules/user/massage/views/review_screen.dart';
import '../../../../data/services/stripe/payment_result.dart';
import '../../../../data/services/stripe/stripe_config.dart';
import '../../../../data/services/stripe/stripe_helper.dart';
import '../../../../core/constants/env_config.dart';
import '../../../../routes/app_routes.dart';

class HireDetailsScreen extends StatefulWidget {
  const HireDetailsScreen({super.key});

  @override
  State<HireDetailsScreen> createState() => _HireDetailsScreenState();
}

class _HireDetailsScreenState extends State<HireDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final hireController = Get.find<HireDetailsController>();
  final bookingController = Get.put(CreateBookingController());
  final authController = Get.put(AuthController());

  bool _isCheckoutMode = false;
  bool _isProcessingPayment = false;

  final addressController = TextEditingController();
  final phoneController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  late StripePaymentHelper _stripeHelper;
  late String hireId;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    final args = Get.arguments;
    hireId = args['id'] ?? '';
    _fetchHireDetails();
    _initializeStripe();
  }

  void _initializeStripe() {
    final config = StripeConfig(
     // secretKey: EnvConfig.stripeSk,
      secretKey:'sk_test_REDACTED_ROTATE_ME',
      merchantDisplayName: 'Harry Service',
      paymentSheetTheme: ThemeMode.light,
      allowsDelayedPaymentMethods: true,
    );

    _stripeHelper = StripePaymentHelper(
      config: config,
      onPaymentSuccess: _onPaymentSuccess,
      onPaymentFailure: _onPaymentFailure,
      onLog: (msg) => debugPrint("StripeLog: $msg"),
    );
  }

  void _showSnackBar(String title, String message, Color bgColor) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bgColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onPaymentSuccess(PaymentResult result) async {
    final itemList = hireController.selectedItems.entries
        .map((e) => {"itemId": e.key, "quantity": e.value})
        .toList();

    final reqBody = {
      "userId": authController.userModel!.id,
      "productId": hireId,
      "bookingItems": itemList,
      "address": addressController.text.trim(),
      "phoneNumber": phoneController.text.trim(),
      "startDateAndTime": startDate!.toUtc().toIso8601String(),
      "endDateAndTime": endDate!.toUtc().toIso8601String(),
      "transactionId": result.paymentData?['transactionId'],
    };

    final success = await bookingController.proceedBooking(reqBody);

    if (!mounted) return;
    setState(() => _isProcessingPayment = false);

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60.sp),
              SizedBox(height: 16.h),
              Text(
                "Booking Successful!",
                style: AppTextStyle.sub_h2_medium_16(color: Colors.green),
              ),
            ],
          ),
        ),
      );

      // Navigate back after showing success
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pop(); // Close dialog
          Get.back(); // Go back to previous screen
        }
      });
    } else {
      _showSnackBar("Booking Failed", "Please try again", Colors.red);
    }
  }

  void _onPaymentFailure(PaymentResult result) {
    setState(() => _isProcessingPayment = false);
    _showSnackBar("Payment Failed", "Please try again", Colors.red);
  }

  Future<void> _fetchHireDetails() async {
    await hireController.fetchHireDetails(hireId);
  }

  bool _isValidPhone(String phone) {
    if (phone.isEmpty) return false;
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 7 && digits.length <= 15;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (!isStart && startDate != null && combined.isBefore(startDate!)) {
      _showSnackBar(
        "Invalid",
        "End time cannot be before start time",
        Colors.red,
      );
      return;
    }

    setState(() {
      if (isStart)
        startDate = combined;
      else
        endDate = combined;
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: GetBuilder<HireDetailsController>(
        builder: (controller) {
          if (controller.isLoading)
            return const Center(child: HireDetailsSkeleton());
          if (controller.hireDetails == null)
            return const Center(child: Text("Hire details not available"));

          final hireDetails = controller.hireDetails!;

          return SafeArea(
            child: SlidingUpPanel(
              minHeight: size.height * 0.55,
              maxHeight: size.height * 0.97,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              parallaxEnabled: true,
              parallaxOffset: 0.2,
              footer: _buildPersistentFooter(controller), // Added Footer
              body: Stack(
                children: [
                  SizedBox(
                    width: size.width,
                    height: size.height,
                    child: Image.network(
                      hireDetails.thumbnail,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: CustomBackButton(
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ],
              ),
              panelBuilder: (ScrollController sc) =>
                  _buildPanelContent(sc, hireDetails, controller),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPanelContent(
    ScrollController sc,
    dynamic hireDetails,
    HireDetailsController controller,
  ) {
    return Column(
      children: [
        SizedBox(height: 12.h),
        Center(
          child: Container(
            width: 50.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            controller: sc,
            padding: EdgeInsets.fromLTRB(
              12,
              10,
              12,
              120.h,
            ), // Extra padding for persistent footer
            children: [
              _isCheckoutMode
                  ? _buildCheckoutForm(hireDetails, controller)
                  : _buildHireInfo(hireDetails),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutForm(
    dynamic hireDetails,
    HireDetailsController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Selected Items", style: AppTextStyle.sub_h1_medium_18()),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: hireDetails.items
              .where((item) => controller.getQuantity(item.id) > 0)
              .length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.6,
          ),
          itemBuilder: (context, index) {
            final filteredItems = hireDetails.items
                .where((item) => controller.getQuantity(item.id) > 0)
                .toList();
            final item = filteredItems[index];
            return SelectedItem(
              productName: item.productName,
              productImg: item.productPhoto,
              quantity: controller.getQuantity(item.id),
              price: item.price,
            );
          },
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            _buildDateField("Select Start Date", startDate, true),
            SizedBox(width: 10.w),
            _buildDateField("Select End Date", endDate, false),
          ],
        ),
        SizedBox(height: 20.h),
        IntlPhoneField(
          controller: phoneController,
          initialCountryCode: 'BD',
          decoration: InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        Text("Address", style: AppTextStyle.sub_h3_medium_14()),
        SizedBox(height: 10.h),
        TextFormField(
          controller: addressController,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: "Address",
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, bool isStart) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          SizedBox(height: 10.h),
          InkWell(
            onTap: () => _pickDate(isStart: isStart),
            child: Container(
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                date == null
                    ? "Pick Time"
                    : "${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHireInfo(dynamic hireDetails) {
    return Column(
      children: [
        ProviderInfo(
          image: hireDetails.owner.profileUrl,
          providerName: hireDetails.owner.fullName,
          reviewCount: hireDetails.reviews.length,
          onTapCall: () {
            //TODO : call provider
            makePhoneCall(hireDetails.owner.phoneNumber);
          },
          onTapMessage: () {
            //TODO : message provider
            Get.toNamed(
              Routes.messagingScreen,
              arguments: {
                'otherUserId': hireDetails.owner.id,
                'chatId': '',
                'otherUserName': hireDetails.owner.fullName,
                'otherUserProfileUrl': hireDetails.owner.profileUrl,
                'isOnline': false,
              },
            );

          },
        ),
        SizedBox(height: 10.h),
        TabBar(
          controller: tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          indicator: const BoxDecoration(
            color: Color(0xffd6c24d),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          tabs: const [
            Tab(text: "About"),
            Tab(text: "Review"),
          ],
        ),
        SizedBox(
          height: 400.h,
          child: TabBarView(
            controller: tabController,
            children: [
              _aboutSection(hireDetails),
              ReviewScreen(reviewList: hireDetails.reviews),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersistentFooter(HireDetailsController controller) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(
        20,
        10,
        20,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: _isCheckoutMode
          ? _buildFooterCheckout()
          : _buildFooterBookNow(controller),
    );
  }

  Widget _buildFooterBookNow(HireDetailsController controller) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            "\$${controller.totalSelectedPrice}",
            style: TextStyle(
              fontSize: 20.sp,
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Spacer(),
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: controller.totalSelectedPrice > 0
                  ? () => setState(() => _isCheckoutMode = true)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary_1,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Book Now"),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterCheckout() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: (bookingController.bookingProgress || _isProcessingPayment)
            ? null
            : () async {
                final phone = phoneController.text.trim();
                final address = addressController.text.trim();

                if (!_isValidPhone(phone) ||
                    startDate == null ||
                    endDate == null ||
                    address.isEmpty) {
                  _showSnackBar(
                    "Validation Error",
                    "Fill all required fields",
                    Colors.red,
                  );
                  return;
                }

                setState(() => _isProcessingPayment = true);
                await _stripeHelper.processPayment(
                  context: context,
                  amount: hireController.totalSelectedPrice
                      .toDouble(), // Ensure double
                  currency: "USD",
                  description: "Hire Booking Payment",
                  metadata: {
                    "userId": authController.userModel!.id,
                    "productId": hireId,
                  },
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary_1,
          disabledBackgroundColor: AppColors.primary_1.withOpacity(0.7),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: (bookingController.bookingProgress || _isProcessingPayment)
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text("Checkout"),
      ),
    );
  }

  Widget _aboutSection(dynamic hireDetails) {
    return GetBuilder<HireDetailsController>(
      builder: (controller) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: hireDetails.items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.77,
          ),
          itemBuilder: (context, index) {
            final item = hireDetails.items[index];
            return HireCardItem(
              productImg: item.productPhoto,
              itemName: item.productName,
              productPrice: item.price,
              quantity: controller.getQuantity(item.id),
              addOnTap: () => controller.addItem(item.id),
              removeOnTap: () => controller.removeItem(item.id),
            );
          },
        );
      },
    );
  }
}
