import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/widgets/booking_card.dart';
import 'package:harry_service_app/app/modules/user/shared/controllers/get_my_booking_controller.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/controllers/nav_controller.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final NavController _navController = Get.find();
  final GetMyBookingController _bookingController = Get.find();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    await _bookingController.getMyBooking();
    setState(() {}); // Refresh UI after fetching
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildBookingList(String status) {
    if (_bookingController.bookingProgress) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary_1),
      );
    }

    final filteredProducts = _bookingController.productsByStatus(status);

    if (filteredProducts.isEmpty) {
      return Center(child: Text("No $status bookings"));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];

        /// Find the corresponding booking
        final booking = _bookingController.bookings.firstWhere(
              (b) => b.product?.id == product.id,
          orElse: () => _bookingController.bookings[index],
        );

        return BookingCard(
          image: product.thumbnail ?? "",
          personCount: booking.personCount ?? 1,
          passType: product.skiPassType ?? "Default",
          location: product.serviceArea ?? "-",
          date: booking.date != null
              ? "${booking.date!.day}-${booking.date!.month}"
              : "",
          time: booking.time ?? "",
          onTap: () {
            // Optional: show menu or navigate to details
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
        title: Text(
          "Bookings",
          style: AppTextStyle.sub_h1_medium_18(),
        ),
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
