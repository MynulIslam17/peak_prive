import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/widgets/booking_card.dart';
import 'package:harry_service_app/app/core/widgets/booking_card_item.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/booking_Item_shimmer.dart';
import 'package:harry_service_app/app/modules/user/shared/controllers/get_my_booking_controller.dart';
import 'package:harry_service_app/app/modules/user/shared/controllers/hire_rating_controller.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/controllers/nav_controller.dart';
import '../../../../routes/app_routes.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  ///finds controllers
  final _navController = Get.find<NavController>();
  final GetMyBookingController _bookingController = Get.find();
  final ratingController = Get.find<HireRatingController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchBookings();
  }

  /// call api
  Future<void> _fetchBookings() async {
    await _bookingController.getMyBooking();
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Format datetime for display
  String _formatBookingTime(booking) {
    if (_navController.getServiceType == "massage") {
      // For massage, use the new dateString and timeString fields
      if (booking.dateString.isNotEmpty && booking.timeString.isNotEmpty) {
        try {
          // Parse the date
          String datePart = booking.dateString.contains('T')
              ? booking.dateString.split('T')[0]
              : booking.dateString;
          DateTime date = DateTime.parse(datePart);

          // Format: "15 Jan 2024, 10:30 AM"
          String formattedDate =
              "${date.day} ${_getMonthName(date.month)} ${date.year}";
          String formattedTime = _formatTime(booking.timeString);

          return "$formattedDate, $formattedTime";
        } catch (e) {
          return booking.timeLabel; // Fallback
        }
      }
      return booking.timeLabel;
    } else {
      // For other services (ski_pass, hire), use timeLabel
      return booking.timeLabel;
    }
  }

  /// Get month name
  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  /// Format time string (HH:mm to 12-hour format)
  String _formatTime(String timeString) {
    try {
      List<String> parts = timeString.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      String period = hour >= 12 ? 'PM' : 'AM';
      hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period";
    } catch (e) {
      return timeString;
    }
  }

  /// show a dialog for rating
  void _showDialog(String productId) {
    double _rating = 0;
    TextEditingController feedbackTEController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          backgroundColor: Colors.white,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxHeight = MediaQuery.of(context).size.height * 0.7;

              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 20,
                    ),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Top Icon
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                "assets/images/review.png",
                                width: 50,
                                height: 50,
                              ),
                            ),
                            SizedBox(height: 10),

                            // Title
                            Text(
                              "Rate Your Stay!",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                                shadows: [
                                  Shadow(
                                    color: Colors.deepPurpleAccent.withOpacity(
                                      0.2,
                                    ),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),

                            /// Rating Stars
                            RatingBar.builder(
                              initialRating: _rating,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding: EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 36,
                              ),
                              onRatingUpdate: (rating) {
                                setState(() {
                                  _rating = rating;
                                });
                              },
                            ),
                            SizedBox(height: 10),

                            /// Feedback TextField
                            TextFormField(
                              controller: feedbackTEController,
                              maxLines: 4,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.deepPurple.withOpacity(0.05),
                                hintText: "Write your feedback...",
                                hintStyle: TextStyle(
                                  color: Colors.deepPurpleAccent,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 15,
                                ),
                              ),
                            ),
                            SizedBox(height: 15),

                            // Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                /// Cancel
                                SizedBox(
                                  width: 110,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary_1,
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                        color: AppColors.primary_1,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 15),

                                /// Submit
                                GetBuilder<HireRatingController>(
                                  builder: (controller) {
                                    return controller.isLoading
                                        ? Center(
                                            child: CircularProgressIndicator(
                                              color: AppColors.primary_1,
                                            ),
                                          )
                                        : SizedBox(
                                            width: 110,
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                double rating = _rating;
                                                String feedback =
                                                    feedbackTEController.text;

                                                Map<String, dynamic> body = {
                                                  "rating": rating,
                                                  "comment": feedback,
                                                };

                                                bool success =
                                                    await ratingController
                                                        .sendRating(
                                                          productId,
                                                          body,
                                                        );

                                                if (success) {
                                                  print(
                                                    "=>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>success",
                                                  );
                                                }

                                                Navigator.of(context).pop();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.deepPurple,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 14,
                                                ),
                                                elevation: 3,
                                                shadowColor: Colors
                                                    .deepPurpleAccent
                                                    .withOpacity(0.3),
                                              ),
                                              child: Text(
                                                "Submit",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          );
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// booking list method
  Widget _buildBookingList(String status) {
    // Show shimmer loader
    if (_bookingController.isLoading) {
      return ListView(
        children: const [
          BookingCardSkeleton(),
          SizedBox(height: 5),
          BookingCardSkeleton(),
          SizedBox(height: 5),
          BookingCardSkeleton(),
          SizedBox(height: 5),
          BookingCardSkeleton(),
          SizedBox(height: 5),
          BookingCardSkeleton(),
        ],
      );
    }

    // Filter bookings by status
    final filteredBookings = _bookingController.bookingsByStatus(status);

    // If empty
    if (filteredBookings.isEmpty) {
      return Center(child: Text("No $status bookings"));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      itemCount: filteredBookings.length,
      itemBuilder: (context, index) {
        final booking = filteredBookings[index];
        final product = booking.product;

        // Clamp totalPrice to prevent negative
        double safePrice =
            (booking.totalPrice != null && booking.totalPrice >= 0)
            ? booking.totalPrice
            : 0;

        String displayPrice = "\$${safePrice.toStringAsFixed(2)}";

        return _navController.getServiceType == "ski_pass"
            ? BookingCard(
                /// working only for pass
                image: product.thumbnail,
                personCount: booking.bookingItems.isNotEmpty
                    ? booking.bookingItems.fold<int>(
                        0,
                        (sum, item) => sum + (item.quantity ?? 0),
                      )
                    : 1,
                passType: product?.title ?? "Default",
                location: product?.serviceArea ?? "-",
                date: booking.startDateAndTime != null
                    ? "${booking.startDateAndTime!.day}-${booking.startDateAndTime!.month}-${booking.startDateAndTime!.year}"
                    : "",
                time: booking.startDateAndTime != null
                    ? "${booking.startDateAndTime!.hour}:${booking.startDateAndTime!.minute}"
                    : "",
                buttonIcon: status == "Active"
                    ? Icons.info_outline
                    : Icons.rate_review,
                onTap: () {
                  if (status == "Active") {
                    Get.toNamed(
                      Routes.userPassBookingDetails,
                      arguments: {"bookingId": booking.id},
                    );
                  } else {
                    _showDialog(product.id);
                  }
                },
              )
            : BookingCardItem(
                image: product.thumbnail,
                buttonIcon: status == "Active"
                    ? Icons.info_outline
                    : Icons.rate_review,
                borderColor: status == "Active"
                    ? Colors.yellow
                    : status == "Completed"
                    ? Colors.green
                    : Colors.red,
                title: product.title,
                timeLabel: _formatBookingTime(booking),
                price: displayPrice,
                buttonText: status == "Active"
                    ? "Details"
                    : status == "Completed"
                    ? "Give Review"
                    : null,
                onButtonTap: () {
                  if (status == "Completed") {
                    _showDialog(product.id);
                  }
                  if (status == "Active") {
                    String type = _navController.getServiceType;

                    if (type == "ski_hire") {
                      Get.toNamed(
                        Routes.userHireBookingDetails,
                        arguments: {"bookingId": booking.id},
                      );
                    }else if(type=="transport"){

                      Get.toNamed(
                        Routes.userTransportBookingDetails,
                        arguments: {"bookingId": booking.id},
                      );
                    }else if(type=="restaurant"){

                      Get.toNamed(
                        Routes.userRestaurantBookingDetails,
                        arguments: {"bookingId": booking.id},
                      );

                    }else{
                      Get.toNamed(
                        Routes.userMassageBookingDetails,
                        arguments: {"bookingId": booking.id},
                      );

                    }





                  }
                },
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFDFAF6),
      appBar: AppBar(
        backgroundColor: const Color(0xffFDFAF6),
        elevation: 0,
        title: Text("Bookings", style: AppTextStyle.sub_h1_medium_18()),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => _navController.changeIndex(0),
          icon: Assets.icons.caretLeft.svg(
            color: Colors.black,
            width: 30.w,
            height: 30.h,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(65.h),
          child: _buildTabBar(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList("Active"),
          _buildBookingList("Completed"),
          _buildBookingList("Cancelled"),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 52.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        labelStyle: AppTextStyle.sub_h3_medium_14(),
        unselectedLabelColor: Colors.black,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelPadding: EdgeInsets.symmetric(horizontal: 2.w),
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xffE2C97A), Color(0xffD4B960)],
          ),
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xffE2C97A).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        tabs: [
          _buildTab("Active", Icons.access_time),
          _buildTab("Completed", Icons.check_circle_outline),
          _buildTab("Cancelled", Icons.cancel_outlined),
        ],
      ),
    );
  }

  Widget _buildTab(String label, IconData iconData) {
    return Tab(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, size: 14.sp),
            SizedBox(width: 4.w),
            Text(label),
          ],
        ),
      ),
    );
  }
}
