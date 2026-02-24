import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/core/widgets/custome_button.dart';
import 'package:harry_service_app/app/core/widgets/provider_info.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/hire_shimmer.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/pass_details_skeleton.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/transport_details_shimmer.dart';
import 'package:harry_service_app/app/modules/user/pass/controllers/pass_booking_controller.dart';
import 'package:harry_service_app/app/modules/user/trasnport/controlers/trasnport_details_controller.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../core/widgets/custome_back_button.dart';
import '../../../../data/services/stripe/payment_result.dart';
import '../../../../data/services/stripe/stripe_config.dart';
import '../../../../data/services/stripe/stripe_helper.dart';
import '../../../../core/constants/env_config.dart';

class TransportDetailsScreen extends StatefulWidget {
  const TransportDetailsScreen({super.key});

  @override
  State<TransportDetailsScreen> createState() => _TransportDetailsScreenState();
}

class _TransportDetailsScreenState extends State<TransportDetailsScreen> {


  // Stripe payment helper
  late StripePaymentHelper _paymentHelper;
  bool _isProcessingPayment = false;


  late final String productId;

  /// find controllers
  final transportController = Get.find<TransportDetailsController>();
  final createBookingController = Get.find<CreateBookingController>();
  final authController = Get.find<AuthController>();



  final image = Assets.images;
  final icon = Assets.icons;

  /// total price
  int ? totalPrice;

  bool _isRentClicked = false;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  /// Pick date and time
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

  /// Calculate total duration between start and end date
  String getTotalDuration(DateTime? start, DateTime? end) {
    if (start == null || end == null) return "Not selected";

    final duration = end.difference(start);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    String result = "";
    if (days > 0) result += "$days day${days > 1 ? 's' : ''} ";
    if (hours > 0) result += "$hours hour${hours > 1 ? 's' : ''} ";
    if (minutes > 0 && days == 0) result += "$minutes min";

    return result.trim();
  }

  /// Calculate total rent based on duration and per-hour rate
  int calculateTotalRate(int ratePerHour, DateTime? start, DateTime? end) {
    if (start == null || end == null) return 0;

    final duration = end.difference(start);
    final totalHours = duration.inMinutes / 60;

    totalPrice=(totalHours * ratePerHour).ceil();

    return (totalHours * ratePerHour).ceil() ;
  }




  /// create new booking

  Future<void> _createBooking(Map<String, dynamic> reqBody) async {
    bool success = await createBookingController.proceedBooking(reqBody);

    if (success) {

      /// showing dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
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
                SizedBox(height: 8.h),
                Text(
                  "Your Booking has been processed successfully",
                  textAlign: TextAlign.center,
                  style: AppTextStyle.c_regular_12(color: AppColors.black_3),
                ),
              ],
            ),
          );
        },
      );



      await Future.delayed(Duration(seconds: 2));

      if(mounted){
        Navigator.of(context).pop();/// close the dilaog
        Get.back(); /// back to previous screen
      }
    }
  }

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
      onPaymentSuccess: _handlePaymentSuccess,
      onPaymentFailure: _handlePaymentFailure,
      onLog: (message) => debugPrint('StripeLog: $message'),
    );
  }

  void _handlePaymentSuccess(PaymentResult result) {
    ///  Don't show snackbar immediately - wait for sheet to close
    setState(() {

      _isProcessingPayment = false;
    });
  }

  void _handlePaymentFailure(PaymentResult result) {
    setState(() {
      _isProcessingPayment = false;
    });
  }

  /// call api method
  Future<void> _fetchDetails() async {
    await transportController.fetchTransportDetails(productId);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: GetBuilder<TransportDetailsController>(
        builder: (controller) {
          if (controller.fetchProgress) return TransportDetailsSkeleton();

          if (controller.transportDetails == null) {
            return Center(child: Text("Failed to load details"));
          }

          final transport = controller.transportDetails!;
          final owner = transport.owner;

          return SizedBox(
            height: double.infinity,
            child: Stack(
              children: [
                // Background image
                Image.network(
                  transport.thumbnail.isNotEmpty ? transport.thumbnail : "",
                  height: size.height * 0.4,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    "assets/images/placeholder.png",
                    height: size.height * 0.4,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                // Bottom Card
                Positioned(
                  top: size.height * 0.33,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xffFDFAF6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          image.line.image(),

                          if (_isRentClicked) ...[
                            Expanded(
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            transport.title,
                                            style: AppTextStyle.sub_h1_medium_18(),
                                          ),
                                          Text(
                                            "\$${transport.amount}/ hr",
                                            style: AppTextStyle.sub_h3_medium_14(
                                              color: AppColors.primary_1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),

                                      // Date pickers
                                      Card(
                                        color: const Color(0xFFFDFAF6),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Start Date & Time",
                                                      style: AppTextStyle.sub_h3_medium_14().copyWith(fontSize: 12),
                                                    ),
                                                    SizedBox(height: 6),
                                                    InkWell(
                                                      onTap: () async {
                                                        final selected = await _pickDateTime();
                                                        if (selected != null) {
                                                          setState(() {
                                                            selectedStartDate = selected;
                                                          });
                                                        }
                                                      },
                                                      child: _dateBox(selectedStartDate),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 20),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "End Date & Time",
                                                      style: AppTextStyle.sub_h3_medium_14().copyWith(fontSize: 12),
                                                    ),
                                                    SizedBox(height: 6),
                                                    InkWell(
                                                      onTap: () async {
                                                        final selected = await _pickDateTime();
                                                        if (selected != null) {
                                                          setState(() {
                                                            selectedEndDate = selected;
                                                          });
                                                        }
                                                      },
                                                      child: _dateBox(selectedEndDate),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Checkout section
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: Color(0xffE7E7E7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  icon.time.svg(width: 17, height: 17),
                                  SizedBox(width: 6),
                                  Text(getTotalDuration(selectedStartDate, selectedEndDate),style: AppTextStyle.p_medium_12(color: AppColors.primary_1),),
                                  SizedBox(width: 12),
                                  _divider(),
                                  SizedBox(width: 6),
                                  icon.carProfile.svg(width: 17, height: 17),
                                  SizedBox(width: 6),
                                  Text("1 Car",style: AppTextStyle.p_medium_12(color: AppColors.primary_1),),
                                  SizedBox(width: 12),
                                  _divider(),
                                  SizedBox(width: 6),
                                  icon.currencyCircleDollar.svg(width: 17, height: 17),
                                  SizedBox(width: 6),
                                  // Display total amount dynamically based on duration
                                  Text(
                                    "\$${calculateTotalRate(transport.amount, selectedStartDate, selectedEndDate)}",
                                    style: AppTextStyle.p_medium_12(color: AppColors.primary_1),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 20),

                            /// checkout button
                            SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: GetBuilder<CreateBookingController>(builder: (controller){
                                  return controller.bookingProgress?
                                  CircularProgressIndicator(color: AppColors.primary_1,)
                                      :  CustomButton(
                                    text: "Checkout",
                                    width: double.infinity,
                                    onTap: ()async {
                                      if (_isProcessingPayment) return;

                                      if (selectedStartDate == null || selectedEndDate == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("Please select both start and end date & time before proceeding."),
                                            backgroundColor: Colors.redAccent,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                        return;
                                      }

                                      // Process Stripe payment
                                      final PaymentResult = await _paymentHelper.processPayment(
                                        context: context,
                                        amount: 100.0, // Payment amount in dollars
                                        currency: 'USD',
                                        description: 'Pass Booking Payment',
                                        metadata: {

                                          "userId": authController.userModel?.id ?? "",
                                          "productId": productId,

                                        },
                                      );

                                      if(PaymentResult.isSuccess){
                                        Map<String, dynamic> body = {
                                          "userId": authController.userModel!.id,
                                          "productId": productId,
                                          "totalPrice" : totalPrice ?? 0,
                                          "startDateAndTime": selectedStartDate!.toIso8601String(), // ISO format
                                          "endDateAndTime": selectedEndDate!.toIso8601String(), // ISO format
                                          "transactionId": PaymentResult.paymentData?['transactionId'],
                                        };

                                        /// call the api for create booking

                                        await   _createBooking(body);


                                      }

                                    },
                                  );
                                }),
                              ),
                            ),
                            SizedBox(height: 20),



                          ] else ...[

                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    ProviderInfo(
                                      image: owner.profileUrl,
                                      providerName: owner.fullName,
                                      rating: transport.averageRating.toString(),
                                      reviewCount: transport.reviews.length,
                                      onTapCall: () {},
                                      onTapMessage: () {},
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      transport.description,
                                      style: AppTextStyle.p_regular_12().copyWith(
                                        fontSize: 14,
                                        color: AppColors.black_2,
                                      ),
                                    ),
                                    SizedBox(height: 10),

                                    // Price card
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          children: [
                                            _priceRow("Insurance Fee", transport.insuranceFee),
                                            _priceRow("Maintain Charge", transport.maintainCharge),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),

                            Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    "${controller.transportDetails!.amount}/hr",
                                    style: AppTextStyle.sub_h1_medium_18().copyWith(fontSize: 18,fontWeight: FontWeight.w500,color: AppColors.primary_1),
                                  ),
                                ),
                                SizedBox(width: 30),
                                Expanded(
                                  child: CustomButton(
                                    text: "Rent Car",
                                    onTap: () {
                                      setState(() {
                                        _isRentClicked = true;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                /// Back button
                CustomBackButton(onTap: () => Get.back()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _divider() => Container(height: 20, width: 2, color: Colors.grey);

  Widget _priceRow(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyle.sub_h3_medium_14()),
        Text("\$$value", style: AppTextStyle.sub_h3_medium_14()),
      ],
    );
  }

  Widget _dateBox(DateTime? date) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          icon.calendarDots.svg(width: 20, height: 20),
          SizedBox(width: 5),
          Text(
            date == null
                ? "Select Date & Time"
                : "${date.day.toString().padLeft(2, '0')}/"
                "${date.month.toString().padLeft(2, '0')}/"
                "${date.year}  "
                "${date.hour.toString().padLeft(2, '0')}:"
                "${date.minute.toString().padLeft(2, '0')}",style: TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }
}