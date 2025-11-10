import 'dart:developer';

import 'package:get/get_navigation/get_navigation.dart';
import 'package:harry_service_app/app/modules/provider/massage/views/add_massage_screen.dart';
import 'package:harry_service_app/app/modules/provider/pass/views/add_pass_screen.dart';
import 'package:harry_service_app/app/modules/provider/pass/views/provider_booking_details.dart';
import 'package:harry_service_app/app/modules/provider/register/views/provider_info_form.dart';
import 'package:harry_service_app/app/modules/provider/restaurant/views/add_restaurant_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/change_password_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/messaging_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/provider_account_information_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/provider_booking_request_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/provider_nav_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/provider_settings_screen.dart';
import 'package:harry_service_app/app/modules/provider/transport/views/add_transport_service.dart';
import 'package:harry_service_app/app/modules/role/views/role_selection_screen.dart';

import 'package:harry_service_app/app/modules/user/hire/views/hire_details_screen.dart';
import 'package:harry_service_app/app/modules/user/massage/views/booking_request.dart';
import 'package:harry_service_app/app/modules/user/massage/views/massage_details_screen.dart';
import 'package:harry_service_app/app/modules/user/pass/views/pass_details_screen.dart';
import 'package:harry_service_app/app/modules/user/restaurant/views/restaurantDetails.dart';
import 'package:harry_service_app/app/modules/user/trasnport/views/transport_details_screen.dart';

import '../core/bindings/app_bindings.dart';
import '../modules/auth/views/login_screen.dart';
import '../modules/auth/views/signup_screen.dart';
import '../modules/onboard/views/on_boarding_screen.dart';
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


    GetPage(name: Routes.providerSignUp,
        page: ()=>ProviderSignUp()
    ),


  /// shared provided
    GetPage(name: Routes.providerNavScreen,
        page: ()=>ProviderNavScreen()
    ),


    GetPage(name: Routes.messagingScreen,
        page: ()=>MessagingScreen()
     ),



    ///provider profile
    GetPage(name: Routes.providerInfoScreen,
        page: ()=>ProviderAccountInformationScreen()
     ),

  GetPage(name: Routes.providerSettingsScreen,
        page: ()=>ProviderSettingsScreen()
     ),

 GetPage(name: Routes.providerPassScreen,
        page: ()=>ProviderPassScreen()
     ),


    GetPage(name: Routes.role,
        page: ()=>RoleSelectionScreen()
     ),



    GetPage(name: Routes.providerBookingDetails,
        page: ()=>ProviderBookingDetails()
     ),


/// add pass service
    GetPage(name: Routes.addPassService,
        page: ()=>AddPassScreen()
     ),

/// add message service
    GetPage(name: Routes.addMessageService,
        page: ()=>AddMassageScreen()
     ),

/// add transport service
    GetPage(name: Routes.addTransportService,
        page: ()=>AddTransportScreen()
     ),


/// add  restaurant service
    GetPage(name: Routes.addRestaurantService,
        page: ()=>AddRestaurantScreen()
     ),
















  ];
}
