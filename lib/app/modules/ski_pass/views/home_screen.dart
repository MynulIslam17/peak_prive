import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/item_card.dart';
import 'package:harry_service_app/app/core/widgets/make_clickable.dart';
import '../../../../gen/assets.gen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/category_list.dart';
import '../../../core/widgets/category_title.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Asset references
  final icon = Assets.icons;
  final image = Assets.images;

  /// Search Text Controller
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          /// Background Gradient
          Container(
            height: 160,
            decoration: BoxDecoration(gradient: AppColors.appBarBackground),
          ),

          /// Main Scrollable Content
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            children: [
              /// Custom AppBar
              _buildCustomAppBar(),

              SizedBox(height: 20.h),

              /// Search + Filter Row
              Row(
                children: [
                  Expanded(child: _buildSearchBar()),
                  SizedBox(width: 10.w),
                  Container(
                    height: 44.h,
                    width: 44.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: icon.faders.svg(width: 30, height: 30),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              /// Category Section
              CategoryTitle(title: "Category", text: "See All", onClick: () {}),
              SizedBox(height: 10.h),
              CategoryList(
                titles: ["Pass1", "Pass2", "Pass3", "Pass4", "Pass5"],
                icons: [
                  icon.ticket,
                  icon.ticket,
                  icon.ticket,
                  icon.ticket,
                  icon.ticket,
                ],
              ),

              SizedBox(height: 20.h),

              /// Top Ski Pass Section
              CategoryTitle(
                title: "Top Ski Passes",
                text: "See All",
                onClick: () {},
              ),
              SizedBox(height: 10.h),

              /// Ski Pass Cards list
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 6,
                itemBuilder: (context, index) {

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),

                    child: ItemCard(
                      image: image.skiPass9,
                      title: "Season Best Ski Pass",
                      price: "\$12/Day",
                      rating: 4.9,
                      reviewCount: "(150+)",
                      location: "Bymountain",
                      fromSkiPasses: true,
                      skiPassType: "Vip",
                      onTap: (){

                       Get.toNamed(Routes.ski_pass_details);

                      },
                    ),
                  );




                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// =========================
  /// Custom AppBar with profile and notification
  /// =========================
  Widget _buildCustomAppBar() {
    return Row(
      children: [
        /// Profile Image
        CircleAvatar(radius: 20, backgroundImage: image.profile.provider()),

        SizedBox(width: 10.w),

        /// Location Info
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Select Location", style: AppTextStyle.c_regular_12()),
                icon.arrowBottom.svg(),
              ],
            ),
            Row(
              children: [
                icon.loacation.svg(),
                SizedBox(width: 10.w),
                Text("Bonanni, 1208", style: AppTextStyle.c_regular_12()),
              ],
            ),
          ],
        ),

        const Spacer(),

        /// Notification
        MakeClickable(
          onTap: () {},
          child: Container(
            width: 40.w,
            height: 40.h,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: icon.bellRinging.svg(),
            ),
          ),
        ),
      ],
    );
  }

  /// =========================
  /// Search TextField
  /// =========================
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Search...',
        hintStyle: const TextStyle(color: Colors.grey),

        /// Prefix Icon
        prefixIcon: const Padding(
          padding: EdgeInsets.all(10.0),
          child: Icon(Icons.search, size: 30, color: Colors.grey),
        ),

        /// Suffix Icon (clear)
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: icon.cancel.svg(width: 20),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              )
            : null,

        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
