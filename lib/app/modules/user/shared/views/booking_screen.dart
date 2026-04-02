import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  late final List<ScrollController> _scrollControllers;

  final _navController = Get.find<NavController>();
  final GetMyBookingController _bookingController = Get.find();
  final ratingController = Get.find<HireRatingController>();

  /// Local flag to debounce scroll events for pagination
  bool _isFetchingMore = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    // Initialize ScrollControllers for each tab and attach listener
    _scrollControllers = List.generate(
      3,
          (_) => ScrollController()..addListener(_scrollListener),
    );

    // Load the first tab (Active) initially
    _bookingController.getMyBooking('Active');

    // Fetch data for tabs when switched (if not already fetched)
    _tabController.addListener(_onTabChanged);
  }

  /// Handle tab changes and fetch data if the tab hasn't been loaded yet
  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    final statuses = ['Active', 'Completed', 'Cancelled'];
    final status = statuses[_tabController.index];

    if (!_bookingController.isFetchedFor(status)) {
      _bookingController.getMyBooking(status);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    for (final sc in _scrollControllers) {
      sc.dispose();
    }
    super.dispose();
  }

  /// Scroll listener for infinite scroll pagination
  void _scrollListener() {
    if (_isFetchingMore) return;
    final statuses = ['Active', 'Completed', 'Cancelled'];

    for (int i = 0; i < _scrollControllers.length; i++) {
      final sc = _scrollControllers[i];
      if (sc.hasClients &&
          sc.position.pixels >= sc.position.maxScrollExtent - 200) {
        final status = statuses[i];
        if (!_bookingController.isMoreLoadingFor(status) &&
            _bookingController.hasMoreFor(status)) {
          _isFetchingMore = true;
          _bookingController.loadMoreBookings(status).whenComplete(() {
            _isFetchingMore = false;
          });
        }
        break;
      }
    }
  }

  /// Format booking time for display
  String _formatBookingTime(booking) {
    if (_navController.getServiceType == "massage") {
      if (booking.dateString.isNotEmpty && booking.timeString.isNotEmpty) {
        try {
          String datePart =
          booking.dateString.contains('T') ? booking.dateString.split('T')[0] : booking.dateString;
          DateTime date = DateTime.parse(datePart);
          String formattedDate =
              "${date.day} ${_getMonthName(date.month)} ${date.year}";
          String formattedTime = _formatTime(booking.timeString);
          return "$formattedDate, $formattedTime";
        } catch (e) {
          return booking.timeLabel;
        }
      }
      return booking.timeLabel;
    } else {
      return booking.timeLabel;
    }
  }

  /// Helper to convert month number to short name
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }

  /// Convert 24h time string to 12h format with AM/PM
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

  /// Show rating dialog for completed bookings
  void _showDialog(String productId) {
    double _rating = 0;
    TextEditingController feedbackTEController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                            Text(
                              "Rate Your Stay!",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                                shadows: [
                                  Shadow(
                                    color: Colors.deepPurpleAccent.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            RatingBar.builder(
                              initialRating: _rating,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 36,
                              ),
                              onRatingUpdate: (rating) {
                                setState(() => _rating = rating);
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: feedbackTEController,
                              maxLines: 4,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.deepPurple.withOpacity(0.05),
                                hintText: "Write your feedback...",
                                hintStyle: TextStyle(color: Colors.deepPurpleAccent),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                              ),
                            ),
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 110,
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary_1,
                                      backgroundColor: Colors.white,
                                      side: BorderSide(color: AppColors.primary_1, width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    child: Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                SizedBox(width: 15),
                                GetBuilder<HireRatingController>(
                                  builder: (controller) {
                                    return controller.isLoading
                                        ? Center(child: CircularProgressIndicator(color: AppColors.primary_1))
                                        : SizedBox(
                                      width: 110,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          Map<String, dynamic> body = {
                                            "rating": _rating,
                                            "comment": feedbackTEController.text,
                                          };
                                          await ratingController.sendRating(productId, body);
                                          Navigator.of(context).pop();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.deepPurple,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: EdgeInsets.symmetric(vertical: 14),
                                          elevation: 3,
                                          shadowColor: Colors.deepPurpleAccent.withOpacity(0.3),
                                        ),
                                        child: Text("Submit", style: TextStyle(fontWeight: FontWeight.bold)),
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

  /// Build booking list for each tab with loading, empty state, and pagination
  Widget _buildBookingList(String status, ScrollController scrollController) {
    return GetBuilder<GetMyBookingController>(
      builder: (controller) {
        final bool isLoading = controller.isLoadingFor(status);
        final bool isFetched = controller.isFetchedFor(status);
        final filteredBookings = controller.bookingsFor(status);

        // Pull-to-refresh wrapper
        return RefreshIndicator(
          color: AppColors.primary_1,
          onRefresh: () async {
            await controller.getMyBooking(status);
          },
          child: () {
            // Show shimmer while loading
            if (isLoading || !isFetched) {
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                children: const [
                  BookingCardSkeleton(),
                  SizedBox(height: 5),
                  BookingCardSkeleton(),
                  SizedBox(height: 5),
                  BookingCardSkeleton(),
                ],
              );
            }

            // Empty state
            if (filteredBookings.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(), // Important to allow pull-to-refresh
                children: [
                  SizedBox(height: 100),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 50, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("No $status bookings found",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              );
            }

            final bool showLoadMoreIndicator = controller.isMoreLoadingFor(status);

            // Booking list
            return ListView.builder(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(), // Important
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemCount: filteredBookings.length + (showLoadMoreIndicator ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= filteredBookings.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                        child:SpinKitCircle(
                            color: AppColors.primary_1,
                          size: 30,
                        ),


                    ),
                  );
                }

                final booking = filteredBookings[index];
                final product = booking.product;

                double safePrice = (booking.totalPrice != null && booking.totalPrice >= 0)
                    ? booking.totalPrice
                    : 0;
                String displayPrice = "\$${safePrice.toStringAsFixed(2)}";

                if (_navController.getServiceType == "ski_pass") {
                  return BookingCard(
                    image: product.thumbnail,
                    personCount: booking.bookingItems.isNotEmpty
                        ? booking.bookingItems.fold<int>(0,
                            (sum, item) => sum + (item.quantity ?? 0))
                        : 1,
                    passType: product?.title ?? "Default",
                    location: product?.serviceArea ?? "-",
                    date: booking.startDateAndTime != null
                        ? "${booking.startDateAndTime!.day}-${booking.startDateAndTime!.month}-${booking.startDateAndTime!.year}"
                        : "",
                    time: booking.startDateAndTime != null
                        ? "${booking.startDateAndTime!.hour}:${booking.startDateAndTime!.minute}"
                        : "",
                    buttonIcon: status == "Active" ? Icons.info_outline : Icons.rate_review,
                    onTap: () {
                      if (status == "Active") {
                        Get.toNamed(Routes.userPassBookingDetails,
                            arguments: {"bookingId": booking.id});
                      } else {
                        _showDialog(product.id);
                      }
                    },
                  );
                } else {
                  return BookingCardItem(
                    image: product.thumbnail,
                    buttonIcon: status == "Active" ? Icons.info_outline : Icons.rate_review,
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
                      } else if (status == "Active") {
                        _navigateToDetails(booking.id);
                      }
                    },
                  );
                }
              },
            );
          }(),
        );
      },
    );
  }

  /// Navigate to booking details based on service type
  void _navigateToDetails(String bookingId) {
    String type = _navController.getServiceType;
    String route;

    switch (type) {
      case "ski_hire":
        route = Routes.userHireBookingDetails;
        break;
      case "transport":
        route = Routes.userTransportBookingDetails;
        break;
      case "restaurant":
        route = Routes.userRestaurantBookingDetails;
        break;
      default:
        route = Routes.userMassageBookingDetails;
    }

    Get.toNamed(route, arguments: {"bookingId": bookingId});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xffFDFAF6),
        elevation: 0,
        title: Text("Bookings", style: AppTextStyle.sub_h2_medium_16()),
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
          _buildBookingList("Active", _scrollControllers[0]),
          _buildBookingList("Completed", _scrollControllers[1]),
          _buildBookingList("Cancelled", _scrollControllers[2]),
        ],
      ),
    );
  }

  /// Build the top tab bar
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

  /// Build individual tab
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