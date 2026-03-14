import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/modules/user/itinerary/controllers/get_all_itinerary_controller.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/widgets/itinerary_pass_card.dart';
import '../../../../core/widgets/service_itinerary_card.dart';
import '../../../../routes/app_routes.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {

  final GetAllItineraryController controller =
  Get.put(GetAllItineraryController());

  @override
  void initState() {
    super.initState();
    controller.getMyItinerary();
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

          /// Loading
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          /// Error
          if (controller.errorMessage != null) {
            return Center(child: Text(controller.errorMessage!));
          }

          /// API List
          final list = controller.myItinerary?.data.result ?? [];

          if (list.isEmpty) {
            return const Center(child: Text("No itinerary found"));
          }

          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {

              final item = list[index];

              /// If category is Ski_Pass show Pass Card
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
                      Get.toNamed(Routes.itineraryDetails);
                    },
                  ),
                );
              }

              /// Otherwise show Service Card
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ServiceItineraryCard(
                  title: item.product?.title ?? "",
                  price: item.totalPrice.toString(),
                  imageUrl: item.product?.thumbnail ?? "",
                  middleIcon: Icons.location_on,
                  middleText: item.product?.serviceArea ?? "",
                  onDetailsPressed: () {
                    Get.toNamed(Routes.itineraryDetails);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}