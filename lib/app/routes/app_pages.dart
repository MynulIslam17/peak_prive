import 'dart:developer';

import 'package:get/get_navigation/get_navigation.dart';
import 'package:harry_service_app/app/modules/provider/register/views/provider_personal_info.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/provider_nav_screen.dart';
import 'package:harry_service_app/app/modules/user/auth/views/login_screen.dart';
import 'package:harry_service_app/app/modules/user/auth/views/signup_screen.dart';
import 'package:harry_service_app/app/modules/user/hire/views/hire_details_screen.dart';
import 'package:harry_service_app/app/modules/user/massage/views/booking_request.dart';
import 'package:harry_service_app/app/modules/user/massage/views/massage_details_screen.dart';
import 'package:harry_service_app/app/modules/user/onboard/views/on_boarding_screen.dart';
import 'package:harry_service_app/app/modules/user/pass/views/pass_details_screen.dart';
import 'package:harry_service_app/app/modules/user/restaurant/views/restaurantDetails.dart';
import 'package:harry_service_app/app/modules/user/trasnport/views/transport_details_screen.dart';

import '../core/bindings/app_bindings.dart';
import '../modules/user/all_service/views/AllServiceScreen.dart';

import '../modules/user/shared/views/bottom_nav_screen.dart';

import '../modules/user/pass/views/set_information.dart';
import 'app_routes.dart';

abstract class AppPages {
  /// for initial screen
  static const initialRoutes = Routes.onBoarding;

  /// all the screen as list
  static final routes = [
    /// auth
    GetPage(name: Routes.login, page: () => LoginScreen()),
    GetPage(name: Routes.signup, page: () => SignupScreen()),

    /// user section==================================================
    GetPage(
      /// all service
      name: Routes.service,
      page: () => AllServiceScreen(),
    ),

    /// pass
    GetPage(name: Routes.passCardDetails, page: () => PassDetailsScreen()),

    GetPage(
      /// booking details
      name: Routes.passInformation,
      page: () => SetInformation(),
    ),

    ///bottom nav
    GetPage(name: Routes.bottomNav, page: () => BottomNavScreen()),

    /// transport
    GetPage(
      name: Routes.transportDetails,
      page: () => TransportDetailsScreen(),
    ),

    /// message
    GetPage(name: Routes.massageDetails, page: () => MassageDetailsScreen()),

    GetPage(name: Routes.bookingRequest, page: () => BookingRequest()),

    /// hire
    GetPage(name: Routes.hireDetails, page: () => HireDetailsScreen()),

    /// restaurant
    GetPage(name: Routes.restaurantDetails, page: () => RestaurantDetails()),

    GetPage(name: Routes.onBoarding, page: () => OnBoardingScreen()),






    /// provider section ========================================


    GetPage(name: Routes.providerInfo,
        page: ()=>ProviderPersonalInfo()
    ),


  /// shared provided
    GetPage(name: Routes.providerNavScreen,
        page: ()=>ProviderNavScreen()
    )











  ];
}
