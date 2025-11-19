import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/user/hire/contollers/hire_details_controller.dart';
import 'package:harry_service_app/app/modules/user/massage/views/review_screen.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/custome_back_button.dart';
import '../../../../core/widgets/custome_button.dart';
import '../../../../core/widgets/hire_card_item.dart';
import '../../../../core/widgets/provider_info.dart';

class HireDetailsScreen extends StatefulWidget {
  const HireDetailsScreen({super.key});

  @override
  State<HireDetailsScreen> createState() => _HireDetailsScreenState();
}

class _HireDetailsScreenState extends State<HireDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final hireController = Get.find<HireDetailsController>();
  late final String id;
  final icon = Assets.icons;
  final image = Assets.images;

  bool _isClickedBookButton = false;
  DateTime? startDate;
  DateTime? endDate;

  /// Pick date and time (for start or end)
  Future<void> _datePicker({required bool isStart}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
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

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);

    var argument = Get.arguments;
    id = argument["id"];

    /// call api
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    await hireController.fetchHireDetails(id);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<HireDetailsController>(builder: (controller) {
        // Loading state
        if (controller.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary_1),
          );
        }

        ///  Null check for hireDetails
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
              // Background image
              Image.network(
                hireDetails.thumbnail,
                height: size.height * 0.48,
                width: double.infinity,
                fit: BoxFit.cover,
              ),

              // Overlap card part
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
                            indicator:
                            const BoxDecoration(color: Color(0xffd6c24d)),
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

                          // Price + Book Now
                          Padding(
                            padding: EdgeInsets.only(top: 10.h, bottom: 20.h),
                            child: Row(
                              children: [
                                Text(
                                  "\$9.99",
                                  style: AppTextStyle.sub_h1_medium_18(
                                      color: AppColors.primary_1),
                                ),
                                SizedBox(width: 30.w),
                                Expanded(
                                  child: CustomButton(
                                    height: 44,
                                    onTap: () {
                                      setState(() {
                                        _isClickedBookButton = true;
                                      });
                                    },
                                    text: "Book Now",
                                    backgroundColor: AppColors.primary_1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Booking section
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "Ski Item",
                                    style: AppTextStyle.sub_h1_medium_18(),
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                SizedBox(
                                  width: 200,
                                  child: HireCardItem(
                                    productPrice: 20,
                                    productImg: "",
                                    itemName: "Apparel",
                                    addOnTap: () {},
                                    removeOnTap: () {},
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                // Total price container
                                Container(
                                  height: 160,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.4),
                                    ),
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                            top: 15,
                                            bottom: 10,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Product Name",
                                                  style: AppTextStyle
                                                      .sub_h3_medium_14()),
                                              Text("Unit",
                                                  style: AppTextStyle
                                                      .sub_h3_medium_14()),
                                              Text("Price",
                                                  style: AppTextStyle
                                                      .sub_h3_medium_14()),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 2),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Ski jacket",
                                                  style: AppTextStyle
                                                      .sub_h3_regular_14()),
                                              Text("1",
                                                  style: AppTextStyle
                                                      .sub_h3_regular_14()),
                                              Text("\$02",
                                                  style: AppTextStyle
                                                      .sub_h3_regular_14()),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Total",
                                                  style: AppTextStyle
                                                      .sub_h3_medium_14()),
                                              Text("\$200",
                                                  style: AppTextStyle
                                                      .sub_h3_regular_14()),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                // Date selection card
                                Card(
                                  color: Colors.white,
                                  child: SizedBox(
                                    height: 100.h,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            // Start Date
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Start Date & Time",
                                                    style: AppTextStyle
                                                        .sub_h3_medium_14()
                                                        .copyWith(fontSize: 11.sp),
                                                  ),
                                                  SizedBox(height: 6.h),
                                                  InkWell(
                                                    onTap: () =>
                                                        _datePicker(isStart: true),
                                                    child: Container(
                                                      width: 155.w,
                                                      height: 38,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.grey),
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                      ),
                                                      padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 8),
                                                      child: Row(
                                                        children: [
                                                          icon.calendarDots
                                                              .svg(width: 20, height: 20),
                                                          SizedBox(width: 5.w),
                                                          Text(
                                                            startDate == null
                                                                ? "Date & Time"
                                                                : "${startDate!.day.toString().padLeft(2, '0')}/"
                                                                "${startDate!.month.toString().padLeft(2, '0')}/"
                                                                "${startDate!.year} "
                                                                "${startDate!.hour.toString().padLeft(2, '0')}:"
                                                                "${startDate!.minute.toString().padLeft(2, '0')}",
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
                                            // End Date
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "End Date & Time",
                                                    style: AppTextStyle
                                                        .sub_h3_medium_14()
                                                        .copyWith(fontSize: 11.sp),
                                                  ),
                                                  SizedBox(height: 6.h),
                                                  InkWell(
                                                    onTap: () =>
                                                        _datePicker(isStart: false),
                                                    child: Container(
                                                      width: 155.w,
                                                      height: 38,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.grey),
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                      ),
                                                      padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 8),
                                                      child: Row(
                                                        children: [
                                                          icon.calendarDots
                                                              .svg(width: 20, height: 20),
                                                          SizedBox(width: 5.w),
                                                          Text(
                                                            endDate == null
                                                                ? "Date & Time"
                                                                : "${endDate!.day.toString().padLeft(2, '0')}/"
                                                                "${endDate!.month.toString().padLeft(2, '0')}/"
                                                                "${endDate!.year} "
                                                                "${endDate!.hour.toString().padLeft(2, '0')}:"
                                                                "${endDate!.minute.toString().padLeft(2, '0')}",
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
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 10),
                            child: CustomButton(
                              width: double.infinity,
                              text: "Checkout",
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // AppBar back button
              CustomBackButton(
                onTap: () {
                  Get.back();
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  /// About section
  Widget _aboutSection(hireDetails) {
    final icon = Assets.icons;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: hireDetails.items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, index) {
              final item = hireDetails.items[index];
              return HireCardItem(
                productImg: item.productPhoto,
                itemName: item.productName,
                addOnTap: () {},
                removeOnTap: () {},
                productPrice: item.price,
              );
            },
          ),
        ],
      ),
    );
  }
}
