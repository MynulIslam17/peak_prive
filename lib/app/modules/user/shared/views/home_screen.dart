import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/controllers/nav_controller.dart';
import 'package:harry_service_app/app/core/widgets/custom_search_bar.dart';
import 'package:harry_service_app/app/core/widgets/item_card.dart';
import 'package:harry_service_app/app/core/widgets/category_list.dart';
import 'package:harry_service_app/app/core/widgets/category_title.dart';
import 'package:harry_service_app/app/core/widgets/userProfileSection.dart';
import 'package:harry_service_app/gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final icon = Assets.icons;
  final image = Assets.images;
  final navController = Get.find<NavController>();
  final TextEditingController _searchController = TextEditingController();

  /// Dummy pass types
  final List<String> passTypeList = ["VIP", "Semi-VIP", "Gold", "Student"];

  /// Category data
  final Map<String, List<Map<String, dynamic>>> categoryData = {
    "pass": [
      {"title": "Pass1", "image": Assets.icons.ticket},
      {"title": "Pass2", "image": Assets.icons.ticket},
      {"title": "Pass3", "image": Assets.icons.ticket},
    ],
    "transport": [
      {"title": "BMW", "image": Assets.icons.bmw},
      {"title": "Suzuki", "image": Assets.icons.suzuki},
      {"title": "Honda", "image": Assets.icons.honda},
    ],
    "restaurant": [
      {"title": "Thai", "image": Assets.icons.foodCat},
      {"title": "Italian", "image": Assets.icons.foodCat},
      {"title": "Fast Food", "image": Assets.icons.foodCat},
    ],
    "hire": [
      {"title": "Ski Essential ", "image": Assets.icons.skiApparel},
      {"title": "ski gear", "image": Assets.icons.skiEssential},
      {"title": "Ski Accessories", "image": Assets.icons.skiGare},
    ],

    "massage": [
      {"title": "Thai", "image": Assets.icons.massage},
      {"title": "Italian", "image": Assets.icons.massage},
      {"title": "Fast Food", "image": Assets.icons.massage},
    ],
  };

  /// Service list data
  final Map<String, List<Map<String, dynamic>>> serviceListData = {
    "pass": [
      {
        "image": Assets.images.skiPass9,
        "title": "Season Best Ski Pass",
        "price": "\$12/Day",
        "rating": 4.9,
        "reviewCount": "(150+)",
        "location": "Bymountain",
        "tag": "VIP",
      },
    ],
    "transport": [
      {
        "image": Assets.images.carImg1,
        "title": "BMW X5",
        "price": "\$200/Day",
        "rating": 4.8,
        "reviewCount": "(50+)",
        "location": "City Center",
        "tag": "Premium",
      },
    ],
    "restaurant": [
      {
        "image": Assets.images.restu1,
        "title": "Thai Delight",
        "price": "\$200/Day",
        "rating": 4.8,
        "reviewCount": "(50+)",
        "location": "City Center",
        "tag": "Premium",
      },
      {
        "image": Assets.images.restu2,
        "title": "Italian Bistro",
        "price": "\$200/Day",
        "rating": 4.8,
        "reviewCount": "(50+)",
        "location": "City Center",
        "tag": "Premium",
      },
    ],

      "hire": [
      {
        "image": Assets.images.skiAccories3,
        "title": "Ski Essential",
        "price": "\$200/Day",
        "rating": 4.8,
        "reviewCount": "(50+)",
        "location": "City Center",
        "tag": "Premium",
      },
      {
        "image": Assets.images.skiPass9,
        "title": "ski gear",
        "price": "\$200/Day",
        "rating": 4.8,
        "reviewCount": "(50+)",
        "location": "City Center",
        "tag": "Premium",
      },
    ],


      "massage": [
      {
        "image": Assets.images.message,
        "title": "Relaxing Massage",
        "price": "\$200/Day",
        "rating": 4.8,
        "reviewCount": "(50+)",
        "location": "City Center",
        "tag": "Premium",
      },
      {
        "image": Assets.images.message,
        "title": "Relaxing Massage",
        "price": "\$200/Day",
        "rating": 4.8,
        "reviewCount": "(50+)",
        "location": "City Center",
        "tag": "Premium",
      },
    ],






  };

  @override
  Widget build(BuildContext context) {
    final serviceType = navController.getServiceType;

    /// Corrected title logic
    String titleOfService = serviceType == "pass"
        ? "Top Ski Pass"
        : serviceType == "transport"
        ? "Top Cars In Town"
        : serviceType == "restaurant"
        ? "Top Restaurant Provider"
        : serviceType=="hire"
        ?"Top Ski Accessories"
        : serviceType=="massage"
        ? "Top Massage’s Provider"
        : "";

    final categories = categoryData[serviceType] ?? [];
    final services = serviceListData[serviceType] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          /// AppBar + Search
          Container(
            width: double.infinity,
            decoration: BoxDecoration(gradient: AppColors.appBarBackground),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              child: Column(
                children: [
                  UserProfileSection(
                    image: image.user2,
                    location: 'Bonani,1208',
                    onTap: () {},
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Expanded(
                        child: CustomSearchBar(
                          controller: _searchController,
                          onClear: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Container(
                        height: 35.h,
                        width: 35.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: icon.faders.svg(width: 20, height: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),

          /// Category Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                CategoryTitle(
                  title: serviceType == "transport" ? "Top Brand" : "Category",
                  text: "See All",
                  onClick: () {},
                ),
                SizedBox(height: 10.h),
                CategoryList(
                  titles: categories.map((e) => e["title"] as String).toList(),
                  icons: categories.map((e) => e["image"]).toList(),
                  onTap: () {},
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),

          /// Service List Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                CategoryTitle(title: titleOfService, text: "See All", onClick: () {}),
                SizedBox(height: 10.h),

                /// Service cards
                Column(
                  children: List.generate(services.length, (index) {
                    final item = services[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: ItemCard(
                        image: item["image"],
                        title: item["title"],
                        price: item["price"],
                        rating: item["rating"] ?? 0.0,
                        reviewCount: item["reviewCount"] ?? "",
                        location: item["location"] ?? "",
                        fromSkiPasses: serviceType == "pass",
                        skiPassType: item["tag"] ?? "",
                        onTap: () {
                          if (serviceType == "pass") {
                            Get.toNamed(Routes.passCardDetails);
                          } else if (serviceType == "transport") {
                            Get.toNamed(Routes.transportDetails);
                          } else if (serviceType == "restaurant") {
                            Get.toNamed(Routes.passCardDetails);
                          }else if(serviceType == "massage"){
                            Get.toNamed(Routes.massageDetails);
                          }else if(serviceType=="hire"){
                            Get.toNamed(Routes.hireDetails);
                          }
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
