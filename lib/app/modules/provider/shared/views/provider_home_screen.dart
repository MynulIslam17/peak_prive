import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/category_title.dart';
import 'package:harry_service_app/app/core/widgets/custom_search_bar.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/widgets/my_service_card.dart';
import '../../../../core/widgets/provider_booking_card.dart';
import '../../../../core/widgets/provider_profile.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  final images = Assets.images;
  final icons = Assets.icons;

  final List<Map<String, dynamic>> _requestPending = [
    {"Today booking": 06},
    {"Booking request": 33},
    {"Amount": "20K"},
  ];

  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                SizedBox(height: 20),
          
                /// profile section
                ProviderProfile(image: images.user2,role: "Ski Pass Provider",name: "Azzan Mahmud",icon:icons.notificaton,),


          
                SizedBox(height: 20),
          
                /// search bar
                CustomSearchBar(
                  controller: _searchController,
                  filledColor: Colors.grey.shade100,
                  borderColor: Colors.grey.shade200,

          
                  onClear: () {
                    _searchController.clear();
                    setState(() {});
                  },
          
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
          
                SizedBox(height: 20),
          
                ///pending service booking request section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // evenly spaced
                  children: _requestPending.map((request) {
                    final title = request.keys.first;
                    final value = request.values.first;

                    return Expanded( /// makes all cards equal width
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 85,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FittedBox(
                              child: Text(
                                "$title",
                                textAlign: TextAlign.center,
                                style: AppTextStyle.sub_h2_medium_16().copyWith(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$value",
                              textAlign: TextAlign.center,
                              style: AppTextStyle.h3_semibold_20().copyWith(
                                color: AppColors.primary_1,
                                fontSize: 17
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),


                SizedBox(height: 20),
          
                /// my service
                CategoryTitle(
                  title: "My service",
                  text: "See All",
                  onClick: () {},
                ),
          
                SizedBox(height: 11),

              SizedBox(
                height: 255,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {

                    return Padding(
                      padding: const EdgeInsets.only(right: 10), // space between cards
                      child: SizedBox(
                        width: 300,
                        child: MyServiceCard(
                          image: images.skiDetails,
                          title: "service.title",
                          price: "service.price",
                          rating: 3,
                          reviews: 23,
                          location: "service.location",
                          onDelete: () {},
                          onEdit: () {},
                          packageType: "Premium",
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20),
          
                /// My booking
                CategoryTitle(
                  title: "Booking management",
                  text: "See All",
                  onClick: () {},
                ),
        
        
                ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 2,
                    itemBuilder: (context, index) {
        
                      return ProviderBookingCard(images: images.skiPass9, onTap: () {  },);
        
                    }
        
                ),
        
          
          
          
          
          
              ],
            ),
          ),
        ),
      ),
    );
  }
}








