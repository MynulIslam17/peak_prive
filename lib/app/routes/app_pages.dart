

 import 'dart:developer';

import 'package:get/get_navigation/get_navigation.dart';
import 'package:harry_service_app/app/modules/service/views/AllServiceScreen.dart';
import 'package:harry_service_app/app/modules/ski_pass/bingings/pass_bingings.dart';
import 'package:harry_service_app/app/modules/ski_pass/controllers/nav_controller.dart';
import 'package:harry_service_app/app/modules/ski_pass/views/details_screen.dart';
import 'package:harry_service_app/app/modules/ski_pass/views/main_nav_screen.dart';


import 'app_routes.dart';

abstract class AppPages{

/// for initial screen
  static const initialRoutes=Routes.service;


/// all the screen as list
  static final routes=[

    GetPage(name: Routes.service,
        page: ()=>AllServiceScreen()
    ),

    GetPage(
        name: Routes.pass_nav_screen,
        page: ()=>PassNavScreen(),
      binding: PassBindings()
    ),

GetPage(
        name: Routes.ski_pass_details,
        page: ()=>DetailsScreen(),
      binding: PassBindings()
    )






  ];




 }