import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/my_service_card.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/widgets/provider_profile.dart';
import '../../../../routes/app_routes.dart';

class ProviderServiceScreen extends StatefulWidget {
  const ProviderServiceScreen({super.key});

  @override
  State<ProviderServiceScreen> createState() => _ProviderServiceScreenState();
}

class _ProviderServiceScreenState extends State<ProviderServiceScreen> {

  final images=Assets.images;
  final icons=Assets.icons;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(

        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 20),
            child: Column(
              children: [
          
          
                /// provider profile
                ProviderProfile(
                  image: images.user2,
                  name: "Azaan Mahmud",
                  role: "Ski Pass Provider",
                  icon: icons.notificaton,
                ),
          
                SizedBox(height: 24,),
          
                ///my service
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    
                    Text("My service",style: AppTextStyle.sub_h2_medium_16(),),
          
          
          
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {

                        /// go for add ing new pass

                        Get.toNamed(Routes.addRestaurantService);

                      },
                      splashColor: Colors.white24,
                      child: Ink(
                        decoration: BoxDecoration(
                          color: AppColors.primary_1,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.white,size: 15,),
                            SizedBox(width: 4),
                            Text(
                              "Add",
                              style: AppTextStyle.p_medium_12(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    )
          
          
          
          
          
                  ],
                ), /// service titile
          
                SizedBox(height: 17,),
          
          
                ListView.builder(
          
                  shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
          
                    itemCount: 4,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context,index){
          
                      return    Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: MyServiceCard(
                          image: Assets.images.skiPass9,
                          title: "Season Best Ski Pass",
                          price: "\$12/Day",
                          rating: 4.9,
                          reviews: 150,
                          location: "Bymountain",
                          packageType: "Basic", // optional
                          onDelete: () => print("Delete clicked"),
                          onEdit: () => print("Edit clicked"),
                        ),
                      );
          
          
                    }),
          
          
          
          
          
              ],
            ),
          ),
        ),
      ),

    );
  }
}
