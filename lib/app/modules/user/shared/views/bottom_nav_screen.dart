import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/modules/user/shared/views/profile_screen.dart';


import '../../../../../gen/assets.gen.dart';
import '../../../../core/controllers/nav_controller.dart';

import 'booking_screen.dart';
import 'home_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {

  List<Map<String, dynamic>> productList = [

    /// pass date

    {
      "type":"ski_pass",
      'product': 'body message',
      'price': '\$300',
      'status': 'Cancelled',
      'image': Assets.images.message,
    }

    ,{
      "type":"ski_pass",
      'product': 'body message',
      'price': '\$300',
      'status': 'Active',
      'image': Assets.images.message,
    },

    {
      "type":"ski_pass",
      'product': 'body message',
      'price': '\$300',
      'status': 'Completed',
      'image': Assets.images.message,
    },


    /// transport data

    {
      "type":"transport",
      'product': 'BMW 1200',
      'price': '\$200',
      'status': 'Active',
      'image': Assets.images.carImg1,
    },
    {
      "type":"transport",
      'product': 'Mercedes Benz',
      'price': '\$500',
      'status': 'Completed',
      'image': Assets.images.carImg2,
    },
    {
      "type":"transport",
      'product': 'Audi A4',
      'price': '\$300',
      'status': 'Cancelled',
      'image': Assets.images.carImg3,
    },

    /// message data
    {  "type":"massage",
      'product': 'hand massage',
      'price': '\$200',
      'status': 'Active',
      'image': Assets.images.message,
    },
    {
      "type":"massage",
      'product': 'thai massage',
      'price': '\$500',
      'status': 'Completed',
      'image': Assets.images.message,
    },
    {
      "type":"massage",
      'product': 'body message',
      'price': '\$300',
      'status': 'Cancelled',
      'image': Assets.images.message,
    },


    /// hire data

    {
      "type":"massage",
      'product': 'Ski Apearal',
      'price': '\$200',
      'status': 'Active',
      'image': Assets.images.skiAccories3,
    },
    {
      "type":"massage",
      'product': 'Ski Gear',
      'price': '\$200',
      'status': 'Completed',
      'image': Assets.images.skiDetails,
    },
    {
      "type":"massage",
      'product': 'ski jacket',
      'price': '\$300',
      'status': 'Cancelled',
      'image': Assets.images.skiPass9,
    },

/// resturant data

    {
      "type":"restaurant",
      'product': 'thai food',
      'price': '\$200',
      'status': 'Active',
      'image': Assets.images.food,
    },
    {
      "type":"restaurant",
      'product': 'italian',
      'price': '\$200',
      'status': 'Completed',
      'image': Assets.images.food,
    },
    {
      "type":"restaurant",
      'product': 'turkish',
      'price': '\$300',
      'status': 'Cancelled',
      'image': Assets.images.food,
    },





  ];



  final navController=Get.find<NavController>();
  final icon=Assets.icons;

  late final List<Widget> _screens=[
    //TransportHomeScreen(),
      HomeScreen(),
      BookingScreen(),
      ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(


        body: GetBuilder<NavController>(

            builder: (controller){

              return _screens[controller.getIndex];
            }),


        bottomNavigationBar:GetBuilder<NavController>(
          

            builder: (controller){

              return  BottomNavigationBar(
                
                backgroundColor: Color(0xffFBF7EB),


                  currentIndex: controller.getIndex,

                  onTap: (index){
                    navController.changeIndex(index);
                  },


                  items: [


                    BottomNavigationBarItem(icon: Icon(Icons.home),label: "Home"),
                    BottomNavigationBarItem(icon: Icon(Icons.calendar_month),label: "Booking"),
                    BottomNavigationBarItem(icon: icon.user.svg(),label: "Profile"),
                  ]

              );

            })
    );
  }
}
