import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/booking_Item_shimmer.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/provider/provider_booking_shimmer.dart';
import 'package:harry_service_app/app/modules/user/itinerary/controllers/get_all_itinerary_controller.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/itinerary_pass_card.dart';
import '../../../../core/widgets/service_itinerary_card.dart';
import '../../../../routes/app_routes.dart';
import '../models/my_itineraray_model.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  final ScrollController scrollController=ScrollController();
  final GetAllItineraryController controller =
      Get.find<GetAllItineraryController>();

  @override
  void initState() {
    super.initState();
    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getMyItinerary();
    });

    scrollController.addListener(() {
      // Check if user is near the bottom
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        controller.getMyItinerary(isLoadMore: true);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose(); // Always dispose to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xffFDFAF6),
        elevation: 0,
        title: Text("Itinerary", style: AppTextStyle.sub_h1_medium_18()),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Assets.icons.caretLeft.svg(
            color: Colors.black,
            width: 30.w,
            height: 30.h,
          ),
        ),
      ),

      body: GetBuilder<GetAllItineraryController>(
        builder: (controller) {
          /// 1. Initial Full Screen Loading (Shimmer)
          if (controller.isLoading) {
            return showShimmer();
          }

          /// 2. Error State
          if (controller.errorMessage != null && controller.itineraryList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(controller.errorMessage!),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => controller.getMyItinerary(),
                    child: const Text("Retry"),
                  )
                ],
              ),
            );
          }

          /// 3. Empty State
          if (controller.itineraryList.isEmpty) {
            return const Center(child: Text("No itinerary found"));
          }

          /// 4. Success State with List & Pagination
          return RefreshIndicator(
            color: AppColors.primary_1,
            onRefresh: () => controller.getMyItinerary(),
            child: ListView.separated(
              controller: scrollController, // Attached for pagination
              physics: const AlwaysScrollableScrollPhysics(), // Ensures refresh works even if list is short
              itemCount: controller.itineraryList.length + (controller.isMoreLoading ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {

                // Show loader at the bottom if isMoreLoading is true
                if (index == controller.itineraryList.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: AppColors.primary_1,))),
                  );
                }

                final item = controller.itineraryList[index];

                /// Category: Ski_Pass
                if (item.category == "Ski_Pass") {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ItinerarySkiPass(
                      image: item.product?.thumbnail ?? "",
                      persons: item.personCount?.toString() ?? "0",
                      duration: item.duration ?? "1 Day",
                      dateTime: "${item.date ?? ""} | ${item.time ?? ""}",
                      location: item.product?.serviceArea ?? "",
                      onDetailsPressed: () {
                        Get.toNamed(
                          Routes.userPassBookingDetails,
                          arguments: {"bookingId": item.id},
                        );
                      },
                    ),
                  );
                }

                /// Other Categories (Transport, Restaurant, etc.)
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ServiceItineraryCard(
                    title: item.product?.title ?? "",
                    price: item.totalPrice.toString(),
                    imageUrl: item.product?.thumbnail ?? "",
                    middleIcon: _buildIcon(item),
                    middleText: _buildLabel(item),
                    onDetailsPressed: () {
                      _navigateToDetails(item);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }



  void _navigateToDetails(ItineraryItem item) {
    String route;
    switch (item.category) {
      case "Transport":
        route = Routes.userTransportBookingDetails;
        break;
      case "Restaurant":
        route = Routes.userRestaurantBookingDetails;
        break;
      case "Massage":
        route = Routes.userMassageBookingDetails;
        break;
      case "Ski_Hire":
        route = Routes.userHireBookingDetails;
        break;
      default:
        return; // Or show an error
    }
    Get.toNamed(route, arguments: {"bookingId": item.id});
  }

  //--- helper widget to get label
  String _buildLabel(ItineraryItem item) {
    switch (item.category) {
      case "Transport":
        return item.timeLabel ?? "_";

      case "Restaurant":
        return item.bookingSeatCount?.toString() ?? "_";
      case "Massage":
        return item.duration ?? "_";

      default:
        return item.timeLabel ?? "_";
    }
  }

  //--- helper widget to get icon
  IconData _buildIcon(ItineraryItem item) {
    switch (item.category) {
      case "Transport":
      case "Massage":
      case "Ski_Hire":
        return Icons.watch_later_outlined;

      case "Restaurant":
        return Icons.event_seat;

      default:
        return Icons.info_outline;
    }
  }

  Widget showShimmer() {
    return ListView(
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    /// Image placeholder
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// Text placeholders
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 14, width: 140, color: Colors.grey),
                          const SizedBox(height: 10),
                          Container(height: 12, width: 100, color: Colors.grey),
                          const SizedBox(height: 10),
                          Container(height: 12, width: 60, color: Colors.grey),
                        ],
                      ),
                    ),

                    /// Button placeholder
                    Container(
                      height: 30,
                      width: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
