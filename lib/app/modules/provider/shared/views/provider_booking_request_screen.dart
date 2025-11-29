
 import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/category_title.dart';
import 'package:harry_service_app/app/core/widgets/custom_search_bar.dart';
import 'package:harry_service_app/app/core/widgets/provider_booking_card.dart';
import 'package:harry_service_app/app/core/widgets/provider_profile.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/widgets/my_service_card.dart';
import '../../../../data/models/booking_details_model.dart';
import '../../../../routes/app_routes.dart';

class ProviderBookingRequestScreen extends StatefulWidget {
   const ProviderBookingRequestScreen({super.key});

   @override
   State<ProviderBookingRequestScreen> createState() => _ProviderBookingRequestScreenState();
 }

 class _ProviderBookingRequestScreenState extends State<ProviderBookingRequestScreen> {


  final images=Assets.images;
  final icons=Assets.icons;

  final _searchTEController=TextEditingController();

   @override
   Widget build(BuildContext context) {

     return Scaffold(
       backgroundColor: Colors.white,

       body: SafeArea(
         child: SingleChildScrollView(
           child: Padding(
             padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 20),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
           
           
                 /// provider profile
                 ProviderProfile(image: images.user2, name: "Azaan Mahmud", role: "Ski Pass Provider",icon: icons.notificaton, onTap: () {  },),
           
                 SizedBox(height: 18,),
           
           
                 /// search bar
           
                 CustomSearchBar(controller: _searchTEController,
                 filledColor: Colors.grey.shade100,
                 onChanged: (value){
                   setState(() {
           
                   });
                 },
           
                   onClear: (){
           
                   _searchTEController.clear();
                   setState(() {
           
                   });
                   },
           
           
                 ),
           
                 SizedBox(height: 20,),
           
           
                /// all booking list
                Text("All Bookings",style: AppTextStyle.sub_h2_medium_16(),),
           
                 SizedBox(height: 15,),
           
           
                 ListView.builder(
           
                    shrinkWrap: true,
                     physics: NeverScrollableScrollPhysics(),
                     itemCount: 12,
                     scrollDirection: Axis.vertical,
                     itemBuilder: (context,index){
           
                       return ProviderBookingCard(images: images.skiAccories3,
                         onTap: () {

                         print("af");

                         Get.toNamed(Routes.providerBookingDetails,
                           arguments: [
                             BookingDetailItem(label: "Service Type", value: "VIP Ski Pass",iconPath: icons.ticket),
                             BookingDetailItem(label: "Date & Time", value: "12 Nov, 09:45 AM",iconPath: icons.calendarDots),
                             BookingDetailItem(label: "Location", value: "Snowy Mountain Resort",iconPath: icons.mapPinSimpleArea),
                             BookingDetailItem(label: "Special Offer", value: "2 Free Lessons",iconPath: icons.mail),
                           ]
                         );


                         },);
           
           
                     }),
           
           
           
           
           
           
           
             ],
           
             ),
           ),
         ),
       ),





     );
   }
 }
