import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/core/controllers/nav_controller.dart';
import 'package:harry_service_app/app/core/widgets/selected_hire_tem.dart';
import 'package:harry_service_app/app/modules/user/hire/contollers/hire_details_controller.dart';
import 'package:harry_service_app/app/modules/user/massage/views/review_screen.dart';
import 'package:harry_service_app/app/modules/user/pass/controllers/pass_booking_controller.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/custome_back_button.dart';
import '../../../../core/widgets/custome_button.dart';
import '../../../../core/widgets/hire_card_item.dart';
import '../../../../core/widgets/shimmer/hire_shimmer.dart';

import '../../../../core/widgets/provider_info.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../data/services/stripe/payment_result.dart';
import '../../../../data/services/stripe/stripe_config.dart';
import '../../../../data/services/stripe/stripe_helper.dart';

class HireDetailsScreen extends StatefulWidget {
  const HireDetailsScreen({super.key});

  @override
  State<HireDetailsScreen> createState() => _HireDetailsScreenState();
}

class _HireDetailsScreenState extends State<HireDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;


  ///  Stripe payment helper
  late StripePaymentHelper _paymentHelper;
  bool _isProcessingPayment = false;

  /// textEditing Controlller
  final addressTEController = TextEditingController();
  final numberController = TextEditingController();

  final bookingController = Get.put(CreateBookingController());

  /// Find controllers
  final hireController = Get.find<HireDetailsController>();
  final navController = Get.find<NavController>();
  final authController = Get.find<AuthController>();

  late final String id;
  final icon = Assets.icons;
  final image = Assets.images;

  bool _isClickedBookButton = false;
  DateTime? startDate;
  DateTime? endDate;
  String? _phoneCountryCode = 'BD'; // Store country code

  /// Show error message
  void _showError(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Validate phone number format
  bool _isValidPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return false;


    String digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Check if it has at least 7 digits and max 15 digits (international standard)
    if (digitsOnly.length < 7 || digitsOnly.length > 15) {
      return false;
    }

    return true;
  }

  /// Pick date and time
  Future<void> _datePicker({required bool isStart}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
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

    if (!isStart && startDate != null) {
      if (combined.isBefore(startDate!)) {
        _showError(
          "Invalid End Time",
          "End time cannot be earlier than start time.",
        );
        return;
      }
    }

    setState(() {
      if (isStart) {
        startDate = combined;
        if (endDate != null && endDate!.isBefore(startDate!)) {
          endDate = null;
        }
      } else {
        endDate = combined;
      }
    });
  }



  /// create new booking
  Future<void> _createBooking(Map<String, dynamic> reqBody) async {
    bool success = await bookingController.proceedBooking(reqBody);

    if (success) {
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

      if (mounted) {
        Navigator.of(context).pop();
        Get.back();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);

    var argument = Get.arguments;
    id = argument["id"];

    _fetchDetails();
    _initializeStripeHelper();
  }




  void _initializeStripeHelper() {
    final config = StripeConfig(
      secretKey: 'sk_test_REDACTED_ROTATE_ME',
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




  @override
  void dispose() {
    tabController.dispose();
    addressTEController.dispose();
    numberController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    await hireController.fetchHireDetails(id);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<HireDetailsController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const HireDetailsSkeleton();
          }

          if (controller.hireDetails == null) {
            return Center(
              child: Text(
                "Hire details not available",
                style: AppTextStyle.sub_h3_regular_14(),
              ),
            );
          }

          final hireDetails = controller.hireDetails!;

          return SizedBox(
            width: size.width,
            height: size.height,
            child: Stack(
              children: [
                /// Background image
                Image.network(
                  hireDetails.thumbnail,
                  height: size.height * 0.48,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                /// Overlap card part
                Positioned(
                  top: size.height * 0.3,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: size.width,
                    decoration: BoxDecoration(
                      color: const Color(0xffFDFAF6),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          /// Handle indicator
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Container(
                                width: 50.w,
                                height: 5.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),

                          if (!_isClickedBookButton) ...[
                            /// Provider Info
                            ProviderInfo(
                              image: hireDetails.owner.profileUrl,
                              providerName: hireDetails.owner.fullName,
                              reviewCount: hireDetails.reviews.length,
                              onTapCall: () {},
                              onTapMessage: () {},
                            ),
                            SizedBox(height: 10.h),

                            /// Tabs
                            TabBar(
                              controller: tabController,
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.black,
                              labelStyle: AppTextStyle.sub_h3_medium_14(),
                              indicator: const BoxDecoration(
                                color: Color(0xffd6c24d),
                              ),
                              tabs: const [
                                Tab(text: "About"),
                                Tab(text: "Review"),
                              ],
                            ),

                            Expanded(
                              child: TabBarView(
                                controller: tabController,
                                children: [
                                  _aboutSection(hireDetails),
                                  ListView(children: [ReviewScreen(reviewList: hireDetails.reviews,)]),
                                ],
                              ),
                            ),

                            /// Selected item + Book Now
                            Padding(
                              padding: EdgeInsets.only(top: 10.h, bottom: 20.h),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      "\$${controller.totalSelectedPrice}",
                                      style: AppTextStyle.sub_h1_medium_18(
                                        color: AppColors.primary_1,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 30.w),
                                  Expanded(
                                    child: SizedBox(
                                      height: 60,
                                      child: ElevatedButton(
                                        onPressed:
                                        controller.totalSelectedPrice > 0
                                            ? () {
                                          setState(() {
                                            _isClickedBookButton =
                                            true;
                                          });
                                        }
                                            : null,
                                        style: ButtonStyle(
                                          backgroundColor:
                                          MaterialStateProperty.resolveWith<
                                              Color>((states) {
                                            if (states.contains(
                                              MaterialState.disabled,
                                            )) {
                                              return Colors.grey.shade300;
                                            }
                                            return AppColors.primary_1;
                                          }),
                                          foregroundColor:
                                          MaterialStateProperty.resolveWith<
                                              Color>((states) {
                                            if (states.contains(
                                              MaterialState.disabled,
                                            )) {
                                              return Colors.grey.shade600;
                                            }
                                            return Colors.white;
                                          }),
                                          textStyle: MaterialStateProperty.all(
                                            const TextStyle(fontSize: 16),
                                          ),
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                            ),
                                          ),
                                          elevation: MaterialStateProperty.all(
                                            4,
                                          ),
                                        ),
                                        child: const Text("Book Now"),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            /// Booking section
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "Selected Ski Item",
                                        style: AppTextStyle.sub_h1_medium_18(),
                                      ),
                                    ),

                                    /// Selected products
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                      NeverScrollableScrollPhysics(),
                                      itemCount: controller.hireDetails!.items
                                          .where(
                                            (item) =>
                                        controller.getQuantity(
                                          item.id,
                                        ) >
                                            0,
                                      )
                                          .length,
                                      gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 10,
                                        crossAxisSpacing: 10,
                                        childAspectRatio: 1.6,
                                      ),
                                      itemBuilder: (context, index) {
                                        final filteredItems = controller
                                            .hireDetails!
                                            .items
                                            .where(
                                              (item) =>
                                          controller.getQuantity(
                                            item.id,
                                          ) >
                                              0,
                                        )
                                            .toList();
                                        final item = filteredItems[index];

                                        return SelectedItem(
                                          productName: item.productName,
                                          productImg: item.productPhoto,
                                          quantity:
                                          controller.getQuantity(item.id),
                                          price: item.price,
                                        );
                                      },
                                    ),

                                    SizedBox(height: 20.h),

                                    /// Total price container
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color:
                                          Colors.grey.withOpacity(0.4),
                                        ),
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            /// Header Row
                                            Padding(
                                              padding:
                                              const EdgeInsets.only(
                                                left: 20,
                                                right: 20,
                                                top: 15,
                                                bottom: 10,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Product Name",
                                                    style: AppTextStyle
                                                        .sub_h3_medium_14(),
                                                  ),
                                                  Text(
                                                    "Unit",
                                                    style: AppTextStyle
                                                        .sub_h3_medium_14(),
                                                  ),
                                                  Text(
                                                    "Price",
                                                    style: AppTextStyle
                                                        .sub_h3_medium_14(),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            /// Selected items
                                            ...controller.hireDetails!.items
                                                .where(
                                                  (item) =>
                                              controller.getQuantity(
                                                item.id,
                                              ) >
                                                  0,
                                            )
                                                .map((item) {
                                              final qty = controller
                                                  .getQuantity(item.id);
                                              final price =
                                                  item.price * qty;
                                              return Padding(
                                                padding:
                                                const EdgeInsets
                                                    .symmetric(
                                                  horizontal: 20,
                                                  vertical: 4,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Text(
                                                      item.productName,
                                                      style: AppTextStyle
                                                          .sub_h3_regular_14(),
                                                    ),
                                                    Text(
                                                      qty.toString(),
                                                      style: AppTextStyle
                                                          .sub_h3_regular_14(),
                                                    ),
                                                    Text(
                                                      "\$$price",
                                                      style: AppTextStyle
                                                          .sub_h3_regular_14(),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            })
                                                .toList(),

                                            /// Total Row
                                            Padding(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 10,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Total",
                                                    style: AppTextStyle
                                                        .sub_h3_medium_14(),
                                                  ),
                                                  Text(
                                                    "\$${controller.totalSelectedPrice}",
                                                    style: AppTextStyle
                                                        .sub_h3_regular_14(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 10.h),

                                    /// Date selection card
                                    Card(
                                      color: Colors.white,
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.symmetric(
                                          vertical: 20,
                                          horizontal: 10,
                                        ),
                                        child: Column(
                                          children: [
                                            /// Start & End Date
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Text(
                                                        "Start Date & Time",
                                                        style: AppTextStyle
                                                            .sub_h3_medium_14()
                                                            .copyWith(
                                                          fontSize: 11.sp,
                                                        ),
                                                      ),
                                                      SizedBox(height: 6.h),
                                                      InkWell(
                                                        onTap: () =>
                                                            _datePicker(
                                                              isStart: true,
                                                            ),
                                                        child: Container(
                                                          width: 155.w,
                                                          height: 38,
                                                          decoration:
                                                          BoxDecoration(
                                                            border:
                                                            Border.all(
                                                              color:
                                                              Colors.grey,
                                                            ),
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                              8,
                                                            ),
                                                          ),
                                                          padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                            horizontal: 8,
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              icon.calendarDots
                                                                  .svg(
                                                                width: 20,
                                                                height: 20,
                                                              ),
                                                              SizedBox(
                                                                width: 5.w,
                                                              ),
                                                              Text(
                                                                startDate ==
                                                                    null
                                                                    ? "Date & Time"
                                                                    : "${startDate!.day.toString().padLeft(2, '0')}/${startDate!.month.toString().padLeft(2, '0')}/${startDate!.year} ${startDate!.hour.toString().padLeft(2, '0')}:${startDate!.minute.toString().padLeft(2, '0')}",
                                                                style: AppTextStyle
                                                                    .c_regular_10(),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: 20.w),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Text(
                                                        "End Date & Time",
                                                        style: AppTextStyle
                                                            .sub_h3_medium_14()
                                                            .copyWith(
                                                          fontSize: 11.sp,
                                                        ),
                                                      ),
                                                      SizedBox(height: 6.h),
                                                      InkWell(
                                                        onTap: () =>
                                                            _datePicker(
                                                              isStart: false,
                                                            ),
                                                        child: Container(
                                                          width: 155.w,
                                                          height: 38,
                                                          decoration:
                                                          BoxDecoration(
                                                            border:
                                                            Border.all(
                                                              color:
                                                              Colors.grey,
                                                            ),
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                              8,
                                                            ),
                                                          ),
                                                          padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                            horizontal: 8,
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              icon.calendarDots
                                                                  .svg(
                                                                width: 20,
                                                                height: 20,
                                                              ),
                                                              SizedBox(
                                                                width: 5.w,
                                                              ),
                                                              Text(
                                                                endDate == null
                                                                    ? "Date & Time"
                                                                    : "${endDate!.day.toString().padLeft(2, '0')}/${endDate!.month.toString().padLeft(2, '0')}/${endDate!.year} ${endDate!.hour.toString().padLeft(2, '0')}:${endDate!.minute.toString().padLeft(2, '0')}",
                                                                style: AppTextStyle
                                                                    .c_regular_10(),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(height: 20),

                                            /// Phone Field with IntlPhoneField
                                            IntlPhoneField(
                                              controller: numberController,
                                              decoration: InputDecoration(
                                                labelText: 'Phone Number',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(12),
                                                ),
                                                hintText: 'Enter phone number',
                                              ),
                                              initialCountryCode: 'BD',
                                              onChanged: (phone) {
                                                setState(() {
                                                  _phoneCountryCode =
                                                      phone.countryCode;
                                                });
                                                print(
                                                    'Complete: ${phone.completeNumber}');
                                              },
                                            ),

                                            SizedBox(height: 20),

                                            TextFormField(
                                              controller:
                                              addressTEController,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.black,
                                                  ),
                                                  borderRadius:
                                                  BorderRadius.circular(12),
                                                ),
                                                hintText: "Address",
                                                hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            /// Checkout button
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 10,
                              ),
                              child: GetBuilder<CreateBookingController>(
                                builder: (bookController) {
                                  return bookController.bookingProgress
                                      ? const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary_1,
                                    ),
                                  )
                                      : CustomButton(
                                    width: double.infinity,
                                    text: "Checkout",
                                    onTap: () async {

                                      if (_isProcessingPayment) return;

                                      /// ---------- VALIDATION ----------
                                      final phoneNumber = numberController.text.trim();
                                      final address = addressTEController.text.trim();

                                      if (!_isValidPhoneNumber(phoneNumber)) {
                                        _showError("Invalid Phone", "Enter valid phone number");
                                        return;
                                      }

                                      if (address.isEmpty || startDate == null || endDate == null) {
                                        _showError("Validation Error", "Fill all required fields");
                                        return;
                                      }

                                      setState(() => _isProcessingPayment = true);

                                      /// ---------- STRIPE PAYMENT ----------
                                      final PaymentResult paymentResult =
                                      await _paymentHelper.processPayment(
                                        context: context,
                                        amount: hireController.totalSelectedPrice.toDouble(),
                                        currency: "USD",
                                        description: "Hire Booking Payment",
                                        metadata: {
                                          "userId": authController.userModel?.id ?? "",
                                          "productId": id,
                                        },
                                      );

                                      setState(() => _isProcessingPayment = false);

                                      /// Wait a moment for the payment sheet to fully close
                                      await Future.delayed(const Duration(milliseconds: 500));

                                      /// ---------- CREATE BOOKING ----------
                                      final itemList = hireController.selectedItems.entries
                                          .map((e) => {
                                        "itemId": e.key,
                                        "quantity": e.value,
                                      })
                                          .toList();



                                      /// if payment succesfull

                                      if(paymentResult.isSuccess){

                                        final reqBody = {
                                          "userId": authController.userModel?.id ?? "",
                                          "productId": id,
                                          "bookingItems": itemList,
                                          "address": address,
                                          "phoneNumber": phoneNumber,
                                          "startDateAndTime": startDate!.toUtc().toIso8601String(),
                                          "endDateAndTime": endDate!.toUtc().toIso8601String(),
                                          "transactionId": paymentResult.paymentData?['transactionId'],
                                        };


                                        await _createBooking(reqBody);


                                      }





                                    },

                                  );
                                },
                              ),
                            )
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                /// Back button
                Positioned(
                  top: 20.h,
                  left: 20.w,
                  child: CustomBackButton(onTap: () => Get.back()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// About section
  Widget _aboutSection(hireDetails) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: GetBuilder<HireDetailsController>(
        builder: (controller) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.hireDetails!.items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.77,
            ),
            itemBuilder: (context, index) {
              final item = controller.hireDetails!.items[index];

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
      ),
    );
  }
}