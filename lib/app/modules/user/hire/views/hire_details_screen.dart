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
import '../../../../core/widgets/provider_info.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class HireDetailsScreen extends StatefulWidget {
  const HireDetailsScreen({super.key});

  @override
  State<HireDetailsScreen> createState() => _HireDetailsScreenState();
}

class _HireDetailsScreenState extends State<HireDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  /// Selected address & location
  String? _selectedAddress;
  double? _selectedLat;
  double? _selectedLng;

  /// Map toggle and markers
  bool showMap = false;
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;

  /// textEditing Controlller
  final addressTEController = TextEditingController();
  final numberController = TextEditingController();

  final bookingController = Get.put(PassBookingController());

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

    setState(() {
      if (isStart) {
        startDate = combined;
      } else {
        endDate = combined;
      }
    });
  }

  /// Check location permission
  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        "Permission Required",
        "Please enable location permission from settings",
      );
      return false;
    }

    return true;
  }

  /// create new booking

  Future<void> _createBooking(Map<String, dynamic> reqBody) async {
    bool success = await bookingController.proceedBooking(reqBody);

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




     await Future.delayed(Duration(seconds: 1));

      if(mounted){
        Navigator.of(context).pop();/// close the dilaog
        Get.back(); /// back to previous screen
      }







    }
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);

    var argument = Get.arguments;
    id = argument["id"];

    /// Call API
    _fetchDetails();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    tabController.dispose();
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
          // Loading state
          if (controller.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary_1),
            );
          }

          // Null check for hireDetails
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
                          // Line image
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: image.line.image(width: 87.w, height: 9.h),
                            ),
                          ),
                          SizedBox(height: 20.h),

                          if (!_isClickedBookButton) ...[
                            // Provider Info
                            ProviderInfo(
                              image: hireDetails.owner.profileUrl,
                              providerName: hireDetails.owner.fullName,
                              reviewCount: hireDetails.reviews.length,
                              onTapCall: () {},
                              onTapMessage: () {},
                            ),
                            SizedBox(height: 10.h),

                            // Tabs
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
                                  ListView(children: [ReviewScreen()]),
                                ],
                              ),
                            ),

                            /// Selected item + Book Now
                            Padding(
                              padding: EdgeInsets.only(top: 10.h, bottom: 20.h),
                              child: Row(
                                children: [
                                  Text(
                                    "\$${controller.totalSelectedPrice}",
                                    style: AppTextStyle.sub_h1_medium_18(
                                      color: AppColors.primary_1,
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
                                                  _isClickedBookButton = true;
                                                  Map<String, int>
                                                  selectedItems =
                                                      controller.selectedItems;
                                                  print(selectedItems);
                                                });
                                              }
                                            : null,
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.resolveWith<
                                                Color
                                              >((states) {
                                                if (states.contains(
                                                  MaterialState.disabled,
                                                )) {
                                                  return Colors.grey.shade300;
                                                }
                                                return AppColors.primary_1;
                                              }),
                                          foregroundColor:
                                              MaterialStateProperty.resolveWith<
                                                Color
                                              >((states) {
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
                                      physics: NeverScrollableScrollPhysics(),
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
                                          quantity: controller.getQuantity(
                                            item.id,
                                          ),
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
                                          color: Colors.grey.withOpacity(0.4),
                                        ),
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            // Header Row
                                            Padding(
                                              padding: const EdgeInsets.only(
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
                                                    style:
                                                        AppTextStyle.sub_h3_medium_14(),
                                                  ),
                                                  Text(
                                                    "Unit",
                                                    style:
                                                        AppTextStyle.sub_h3_medium_14(),
                                                  ),
                                                  Text(
                                                    "Price",
                                                    style:
                                                        AppTextStyle.sub_h3_medium_14(),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Selected items
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
                                                        const EdgeInsets.symmetric(
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
                                                          style:
                                                              AppTextStyle.sub_h3_regular_14(),
                                                        ),
                                                        Text(
                                                          qty.toString(),
                                                          style:
                                                              AppTextStyle.sub_h3_regular_14(),
                                                        ),
                                                        Text(
                                                          "\$$price",
                                                          style:
                                                              AppTextStyle.sub_h3_regular_14(),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                })
                                                .toList(),

                                            // Total Row
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
                                                    style:
                                                        AppTextStyle.sub_h3_medium_14(),
                                                  ),
                                                  Text(
                                                    "\$${controller.totalSelectedPrice}",
                                                    style:
                                                        AppTextStyle.sub_h3_regular_14(),
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
                                        padding: const EdgeInsets.symmetric(
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
                                                        style:
                                                            AppTextStyle.sub_h3_medium_14()
                                                                .copyWith(
                                                                  fontSize:
                                                                      11.sp,
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
                                                          decoration: BoxDecoration(
                                                            border: Border.all(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          padding:
                                                              const EdgeInsets.symmetric(
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
                                                                style:
                                                                    AppTextStyle.c_regular_10(),
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
                                                        style:
                                                            AppTextStyle.sub_h3_medium_14()
                                                                .copyWith(
                                                                  fontSize:
                                                                      11.sp,
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
                                                          decoration: BoxDecoration(
                                                            border: Border.all(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          padding:
                                                              const EdgeInsets.symmetric(
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
                                                                style:
                                                                    AppTextStyle.c_regular_10(),
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

                                            /// Phone Field
                                            IntlPhoneField(
                                              controller: numberController,
                                              decoration: InputDecoration(
                                                labelText: 'Phone Number',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              initialCountryCode: 'BD',
                                              onChanged: (phone) =>
                                                  print(phone.completeNumber),
                                            ),

                                            SizedBox(height: 20),

                                            // /// Location Picker
                                            // Text(
                                            //   "Pick Your Location",
                                            //   style: AppTextStyle.sub_h3_medium_14(),
                                            // ),
                                            // SizedBox(height: 8),
                                            // showMap
                                            //     ? SizedBox(
                                            //   height: 300,
                                            //   child: GoogleMap(
                                            //     initialCameraPosition: const CameraPosition(
                                            //       target: LatLng(23.779112538236312, 90.4234655498775),
                                            //       zoom: 15,
                                            //     ),
                                            //     markers: _markers,
                                            //     onMapCreated: (controller) {
                                            //       _mapController = controller;
                                            //     },
                                            //     onTap: (LatLng pos) async {
                                            //       // Animate camera to tapped position
                                            //       _mapController?.animateCamera(
                                            //         CameraUpdate.newLatLngZoom(pos, 15),
                                            //       );
                                            //
                                            //       setState(() {
                                            //         _selectedLat = pos.latitude;
                                            //         _selectedLng = pos.longitude;
                                            //
                                            //         // Add marker at tapped position
                                            //         _markers = {
                                            //           Marker(
                                            //             markerId: const MarkerId('selected_location'),
                                            //             position: pos,
                                            //             infoWindow: InfoWindow(
                                            //               title: 'Selected Location',
                                            //               snippet: '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}',
                                            //             ),
                                            //           ),
                                            //         };
                                            //       });
                                            //
                                            //       try {
                                            //         List<Placemark> place = await placemarkFromCoordinates(
                                            //           pos.latitude,
                                            //           pos.longitude,
                                            //         );
                                            //
                                            //         setState(() {
                                            //           _selectedAddress =
                                            //           "${place.first.street}, ${place.first.locality}, ${place.first.country}";
                                            //         });
                                            //
                                            //         Get.snackbar("Location Picked", _selectedAddress ?? "");
                                            //       } catch (e) {
                                            //         Get.snackbar("Error", "Failed to get address");
                                            //       }
                                            //     },
                                            //   ),
                                            // )
                                            //     : GestureDetector(
                                            //   onTap: () async {
                                            //     if (await _checkLocationPermission()) {
                                            //       setState(() => showMap = true);
                                            //     }
                                            //   },
                                            //   child: Container(
                                            //     width: double.infinity,
                                            //     padding: const EdgeInsets.all(12),
                                            //     decoration: BoxDecoration(
                                            //       border: Border.all(color: Colors.grey.shade400),
                                            //       borderRadius: BorderRadius.circular(8),
                                            //     ),
                                            //     child: Row(
                                            //       children: [
                                            //         const Icon(Icons.map, color: Colors.blue),
                                            //         SizedBox(width: 8.w),
                                            //         Expanded(
                                            //           child: Text(
                                            //             _selectedAddress ?? "Tap to pick your location on map",
                                            //             style: AppTextStyle.sub_h3_regular_14(),
                                            //           ),
                                            //         ),
                                            //       ],
                                            //     ),
                                            //   ),
                                            // ),
                                            TextFormField(
                                              controller: addressTEController,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.black,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                hint: Text(
                                                  "Address",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                  ),
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

                            /// create booking  button
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 10,
                              ),
                              child: GetBuilder<PassBookingController>(
                                builder: (controller) {
                                  return controller.bookingProgress
                                      ? const Center(
                                    child: CircularProgressIndicator(color: AppColors.primary_1),
                                  )
                                      : CustomButton(
                                    width: double.infinity,
                                    text: "Checkout",
                                    onTap: () async {
                                      // Take phone number and address
                                      String phoneNumber = numberController.text.trim();
                                      String address = addressTEController.text.trim();

                                      // Validation checks
                                      if (phoneNumber.isEmpty) {
                                        Get.snackbar(
                                          "Validation Error",
                                          "Phone number cannot be empty",
                                          backgroundColor: Colors.red,
                                          colorText: Colors.black,
                                        );
                                        return;
                                      }

                                      if (address.isEmpty) {
                                        Get.snackbar(
                                          "Validation Error",
                                          "Address cannot be empty",
                                          backgroundColor: Colors.red,
                                          colorText: Colors.black,
                                        );
                                        return;
                                      }

                                      // Date validation
                                      if (startDate == null) {
                                        Get.snackbar(
                                          "Validation Error",
                                          "Please select start date & time",
                                          backgroundColor: Colors.red,
                                          colorText: Colors.black,
                                        );
                                        return;
                                      }

                                      if (endDate == null) {
                                        Get.snackbar(
                                          "Validation Error",
                                          "Please select end date & time",
                                          backgroundColor: Colors.red,
                                          colorText: Colors.black,
                                        );
                                        return;
                                      }

                                      if (endDate!.isBefore(startDate!)) {
                                        Get.snackbar(
                                          "Validation Error",
                                          "End date & time must be after start date & time",
                                          backgroundColor: Colors.red,
                                          colorText: Colors.black,
                                        );
                                        return;
                                      }

                                      // Prepare selected items
                                      final itemList = hireController.selectedItems.entries
                                          .map((e) => {
                                        "itemId": e.key,
                                        "quantity": e.value,
                                      })
                                          .toList();

                                      // Prepare request body with ISO 8601 dates
                                      final reqBody = {
                                        "userId": authController.userModel?.id ?? "",
                                        "productId": id,
                                        "bookingItems": itemList,
                                        "address": address,
                                        "phoneNumber": phoneNumber,
                                        "startDateAndTime": startDate!.toUtc().toIso8601String(),
                                        "endDateAndTime": endDate!.toUtc().toIso8601String(),
                                      };

                                      // If everything is ok, create booking
                                      _createBooking(reqBody);
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
                CustomBackButton(onTap: () => Get.back()),
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
