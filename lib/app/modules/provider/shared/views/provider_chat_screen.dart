
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/appbar_with_title.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/chats_container.dart';
import '../../../../routes/app_routes.dart';

class ProviderChatScreen extends StatefulWidget {
  const ProviderChatScreen({super.key});

  @override
  State<ProviderChatScreen> createState() => _ProviderChatScreenState();
}

class _ProviderChatScreenState extends State<ProviderChatScreen> {


  final icons=Assets.icons;
  final images=Assets.images;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBarWithTitle(icons: icons, onTap: (){},title: "Messages",),


       body: Padding(
         padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 24),
         child: Column(
           children: [


             /// search bar
             Container(
               width: double.infinity,
               height: 52,
               decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(16),
                 color: Colors.white,
                 boxShadow: [
                   BoxShadow(
                     color: Colors.grey.withOpacity(0.15),
                     blurRadius: 8,
                     offset: const Offset(1, 3),
                   ),
                 ],
               ),
               child: TextField(
                 cursorColor: AppColors.primary_1,
                 decoration: InputDecoration(
                   hintText: "Search by name...",
                   hintStyle: AppTextStyle.sub_h3_medium_14(color: Colors.grey),
                   prefixIcon: Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 12),
                     child: Icon(Icons.search, color: Colors.grey.shade600),
                   ),
                   prefixIconConstraints: const BoxConstraints(minWidth: 35),
                   contentPadding:
                   const EdgeInsets.symmetric(horizontal: 10, vertical: 14),

                   border: InputBorder.none,
                   enabledBorder: InputBorder.none,
                   focusedBorder: InputBorder.none,
                 ),
               ),
             ),


             SizedBox(height: 16,),

             /// recent chat list
             Expanded(
               child: ListView.builder(
               
                   itemCount: 4,
                   itemBuilder: (context,index){
               
                 return Padding(
                   padding: const EdgeInsets.symmetric(vertical: 10),
                   child: ChatsContainer(images: images,onTap: (){

                     Get.toNamed(Routes.messagingScreen);

                   },),
                 );
               
               
               }),
             )




           ],
         ),
       ),

    );
  }
}


