import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/custom_search_bar.dart';

import '../../../../../gen/assets.gen.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  final images = Assets.images;
  final icons = Assets.icons;

  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SizedBox(height: 20),

              /// profile section
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: images.profile.provider(),
                    radius: 26,
                  ),

                  SizedBox(width: 10.w),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Ankon Akash", style: AppTextStyle.h3_semibold_20()),

                      ///provider name
                      Text(
                        "Ski Pass provider",
                        style: AppTextStyle.c_regular_12(),
                      ),

                      /// provider service type
                    ],
                  ),

                  Spacer(),

                  icons.notificaton.svg(width: 25, height: 25),
                ],
              ),

              SizedBox(height: 20),

              /// search bar
              CustomSearchBar(controller: _searchController,
                filledColor: Colors.grey.shade100,
                onClear: (){
                 _searchController.clear();
                 setState(() {

                 });
                },

                onChanged: (value){
                  setState(() {

                  });
                },

              ),

              SizedBox(height: 20,),



            ],
          ),
        ),
      ),
    );
  }
}
