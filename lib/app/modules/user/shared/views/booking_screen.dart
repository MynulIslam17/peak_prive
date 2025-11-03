import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/widgets/booking_card.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/controllers/nav_controller.dart';
import '../../../../core/widgets/booking_card_item.dart';
import '../../../../core/widgets/cancel_dialog.dart';

class BookingScreen extends StatefulWidget {
  final List<Map<String, dynamic>> productList;
  const BookingScreen({super.key, required this.productList});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  final navController = Get.find<NavController>();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Widget _bookingList(String status) {
    List<Map<String, dynamic>> filteredList = widget.productList
        .where((product) =>
    product['status'] == status &&
        product["type"] == navController.getServiceType)
        .toList();

    return ListView.builder(
      itemCount: filteredList.length,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      itemBuilder: (context, index) {
        var product = filteredList[index];
        return navController.getServiceType == "pass"
            ? BookingCard(onTap: () {})
            : BookingCardItem(
          borderColor: status == "Completed"
              ? Colors.green.withOpacity(0.4)
              : status == "Cancelled"
              ? Colors.red.withOpacity(0.4)
              : Colors.white,
          showMenu: status != "Completed" && status != "Cancelled",
          onMenuTap: () {
            showMenu(
              context: context,
              position: const RelativeRect.fromLTRB(300, 200, 20, 0),
              items: [
                PopupMenuItem(
                    value: "View Details", child: Text("View Details")),
                PopupMenuItem(
                    value: "Cancel", child: Text("Cancel booking")),
              ],
            ).then((value) {
              if (value == "Cancel") {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      insetPadding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      child: CancelDialog(onTap: () {}),
                    );
                  },
                );
              }
            });
          },
          image: product['image'],
          title: product['product'],
          price: product['price'],
          buttonText: status == "Completed"
              ? "Give Review"
              : status == "Cancelled"
              ? "Book Again"
              : "View Details",
          onButtonTap: () {},
          dueTime: status == "Active" ? 2 : null,
        );
      },
    );
  }

  final icon = Assets.icons;
  final image = Assets.images;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFDFAF6),
      appBar: AppBar(
        backgroundColor: Color(0xffFDFAF6),
        elevation: 0,
        title: Text(
          "Bookings",
          style: AppTextStyle.sub_h1_medium_18(),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            navController.changeIndex(0);
          },
          icon: icon.caretLeft.svg(
            color: Colors.black,
            width: 30.w,
            height: 30.h,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(65.h),
          child: Container(
            height: 52.h,
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: tabController,
              labelColor: Colors.white,
              labelStyle: AppTextStyle.sub_h3_medium_14(),
              unselectedLabelColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelPadding: EdgeInsets.symmetric(horizontal: 2.w),
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xffE2C97A),
                    Color(0xffD4B960),
                  ],
                ),
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xffE2C97A).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              indicatorPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              tabs: [
                Tab(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time, size: 14.sp),
                        SizedBox(width: 4.w),
                        Text('Active'),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 14.sp),
                        SizedBox(width: 4.w),
                        Text('Completed'),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel_outlined, size: 14.sp),
                        SizedBox(width: 4.w),
                        Text('Cancelled'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _bookingList("Active"),
          _bookingList("Completed"),
          _bookingList("Cancelled"),
        ],
      ),
    );
  }
}