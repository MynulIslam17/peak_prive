import 'dart:developer';

import 'package:get/get_navigation/get_navigation.dart';
import 'package:harry_service_app/app/modules/user/hire/views/hire_details_screen.dart';
import 'package:harry_service_app/app/modules/user/massage/views/booking_request.dart';
import 'package:harry_service_app/app/modules/user/massage/views/massage_details_screen.dart';
import 'package:harry_service_app/app/modules/user/pass/views/pass_details_screen.dart';
import 'package:harry_service_app/app/modules/user/trasnport/views/transport_details_screen.dart';

import '../core/bindings/app_bindings.dart';
import '../modules/user/all_service/views/AllServiceScreen.dart';

import '../modules/user/shared/views/bottom_nav_screen.dart';


import '../modules/user/pass/views/set_information.dart';
import 'app_routes.dart';

abstract class AppPages {
  /// for initial screen
  static const initialRoutes = Routes.service;

  /// all the screen as list
  static final routes = [
    /// all service
    GetPage(
        name: Routes.service,
        page: () => AllServiceScreen()
    ),

    GetPage(
      /// booking details
      name: Routes.passCardDetails,
      page: () => PassDetailsScreen(),
    ),

    GetPage(
      /// booking details
      name: Routes.passInformation,
      page: () => SetInformation(),
    ),

    GetPage(
        name: Routes.bottomNav,
        page: () => BottomNavScreen()
    ),

    GetPage(
        name: Routes.transportDetails,
        page: () => TransportDetailsScreen()
    ),


   GetPage(
        name: Routes.massageDetails,
        page: () => MassageDetailsScreen()
    ),


    GetPage(name: Routes.bookingRequest,
        page: ()=> BookingRequest()
    ),

    GetPage(name: Routes.hireDetails,
        page: ()=>HireDetailsScreen()
    )





  ];
}
