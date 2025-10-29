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
  const BookingScreen({super.key,
    required this.productList});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
  late TabController tabController;

  final navController=Get.find<NavController>();


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
        .where((product) => product['status'] == status && product["type"]==navController.getServiceType)
        .toList();

    return ListView.builder(
      itemCount: filteredList.length,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      itemBuilder: (context, index) {
        var product = filteredList[index];
        return navController.getServiceType=="pass" ?BookingCard(onTap: (){}) : BookingCardItem(
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
                PopupMenuItem(value: "View Details", child: Text("View Details")),
                PopupMenuItem(value: "Cancel", child: Text("Cancel booking")),
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

  final icon=Assets.icons;
  final image=Assets.images;
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text("Bookings"),
        centerTitle: true,
        leading: IconButton(onPressed: (){

          navController.changeIndex(0);

        },
            icon: icon.caretLeft.svg(color: Colors.black,width: 30.w,height: 30.h)),
        bottom: TabBar(
          controller: tabController,
           labelColor: Colors.blue,
          labelStyle: AppTextStyle.sub_h3_medium_14(),
           unselectedLabelColor: Colors.black,

           indicatorSize: TabBarIndicatorSize.tab,

          indicator: BoxDecoration(


            color: Color(0xffE2C97A).withOpacity(0.3), // Background color for selected tab
            borderRadius: BorderRadius.circular(8), // Rounded corners

          ),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
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
