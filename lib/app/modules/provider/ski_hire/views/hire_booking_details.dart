import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/restaurant_details_shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/user_info.dart';
import '../controller/booking_item_controller.dart';

class HireBookingDetails extends StatefulWidget {
  const HireBookingDetails({super.key});

  @override
  State<HireBookingDetails> createState() => _HireBookingDetailsState();
}

class _HireBookingDetailsState extends State<HireBookingDetails> {
  final PanelController _panelController = PanelController();
  final ItemController itemController = Get.put(ItemController());

  late final String bookingId;

  @override
  void initState() {
    super.initState();
    // Fetch the booking by ID
    var arguments = Get.arguments;
    bookingId = arguments["bookingId"];

    if (bookingId.isNotEmpty) {
      itemController.fetchBookingById(bookingId);
    }
  }

  // Helper function to format ISO date
  String formatDate(String? isoDate) {
    if (isoDate == null) return "N/A";
    try {
      DateTime dateTime = DateTime.parse(isoDate).toLocal();
      return DateFormat('dd MMM yyyy, h:mm a').format(dateTime);
    } catch (e) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GetBuilder<ItemController>(
        builder: (controller) {
          // Show loading state
          if (controller.isLoading) {
            return RestaurantDetailsShimmer();
          }

          // Show error state
          if (controller.errorMessage != null) {
            return Center(child: Text(controller.errorMessage!));
          }

          final user = controller.user;
          final product = controller.product;
          final bookingItems = controller.bookingItems;

          return SlidingUpPanel(
            controller: _panelController,
            maxHeight: height * 0.67,
            minHeight: height * 0.52,
            parallaxEnabled: true,
            parallaxOffset: 0.2,
            borderRadius: BorderRadius.circular(20),
            panelBuilder: (ScrollController scController) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        controller: scController,
                        children: [
                          // User Contact Card
                          UserContactCard(
                            profileImageUrl: user?.profileUrl ?? "",
                            userName: user?.fullName ?? "N/A",
                            location: product?.serviceArea ?? "N/A",
                            onTapCall: () {},
                            onTapMessage: () {},
                          ),

                          const SizedBox(height: 12),

                          // Booking items list
                          if (bookingItems != null && bookingItems.isNotEmpty) ...[
                            Text(
                              "Items",
                              style: AppTextStyle.sub_h3_medium_14(),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 20,
                              runSpacing: 10,
                              children: bookingItems.map((element) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.network(
                                      element.item?.productPhoto ?? "",
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      element.item?.productName ?? "N/A",
                                      style: AppTextStyle.p_regular_12(),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),
                          ],

                          // Charges section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Extra Charge / Hour",
                                    style: AppTextStyle.sub_h3_medium_14(),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                          "assets/icons/CurrencyCircleDollar.svg"),
                                      const SizedBox(width: 6),
                                      Text(
                                        "${product?.extraChargePerHour ?? 0}",
                                        style: AppTextStyle.p_medium_12(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Total Price",
                                    style: AppTextStyle.sub_h3_medium_14(),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                          "assets/icons/CurrencyCircleDollar.svg"),
                                      const SizedBox(width: 6),
                                      Text(
                                        "${controller.totalPrice ?? 0}",
                                        style: AppTextStyle.p_medium_12(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Address and Phone
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Address",
                                    style: AppTextStyle.sub_h3_medium_14(),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.address ?? "N/A",
                                    style: AppTextStyle.p_medium_12(),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Phone Number",
                                    style: AppTextStyle.sub_h3_medium_14(),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.phoneNumber ?? "N/A",
                                    style: AppTextStyle.p_medium_12(),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Start and End Date
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Start Date & Time",
                                    style: AppTextStyle.sub_h3_medium_14(),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatDate(controller.hireItem?.data?.startDateAndTime),
                                    style: AppTextStyle.p_medium_12(),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "End Date & Time",
                                    style: AppTextStyle.sub_h3_medium_14(),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatDate(controller.hireItem?.data?.endDateAndTime),
                                    style: AppTextStyle.p_medium_12(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Approve Button
                    SafeArea(
                      child: SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text("Approve"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary_1,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            body: Column(
              children: [
                Container(
                  height: height * 0.5,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        product!.thumbnail!,
                        fit: BoxFit.cover,
                        height: height * 0.5,
                      ),
                      Positioned(
                        top: 66,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => Get.back(),
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: const BoxDecoration(
                                  color: Colors.black38,
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(7),
                                  child: SvgPicture.asset(
                                    "assets/icons/back_icon.svg",
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Request",
                                  style: AppTextStyle.h2_semibold_22(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Opacity(
                              opacity: 0,
                              child: Container(height: 40, width: 40),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
