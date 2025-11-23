import 'dart:developer';

import 'package:get/get_navigation/get_navigation.dart';
import 'package:harry_service_app/app/modules/auth/bindings/email_verify_bindings.dart';
import 'package:harry_service_app/app/modules/auth/bindings/login_bindings.dart';
import 'package:harry_service_app/app/modules/auth/bindings/otp_bindings.dart';
import 'package:harry_service_app/app/modules/auth/bindings/pass_reset_bindings.dart';
import 'package:harry_service_app/app/modules/auth/bindings/signup_bindings.dart';
import 'package:harry_service_app/app/modules/auth/views/email_verify_screen.dart';

import 'package:harry_service_app/app/modules/auth/views/pass_reset_screen.dart';
import 'package:harry_service_app/app/modules/provider/massage/views/add_massage_screen.dart';
import 'package:harry_service_app/app/modules/provider/pass/views/add_pass_screen.dart';
import 'package:harry_service_app/app/modules/provider/pass/views/provider_booking_details.dart';
import 'package:harry_service_app/app/modules/provider/register/views/provider_info_form.dart';
import 'package:harry_service_app/app/modules/provider/restaurant/views/add_restaurant_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/bindings/change_pass_binding.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/change_password_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/messaging_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/provider_account_information_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/provider_booking_request_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/provider_nav_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/provider_settings_screen.dart';
import 'package:harry_service_app/app/modules/provider/transport/views/add_transport_service.dart';
import 'package:harry_service_app/app/modules/role/views/role_selection_screen.dart';
import 'package:harry_service_app/app/modules/splash/splash_screen.dart';


import 'package:harry_service_app/app/modules/user/hire/views/hire_details_screen.dart';
import 'package:harry_service_app/app/modules/user/massage/views/booking_request.dart';
import 'package:harry_service_app/app/modules/user/massage/views/massage_details_screen.dart';

import 'package:harry_service_app/app/modules/user/pass/views/pass_details_screen.dart';
import 'package:harry_service_app/app/modules/user/restaurant/views/restaurantDetails.dart';

import 'package:harry_service_app/app/modules/user/shared/bindings/get_profile_binding.dart';
import 'package:harry_service_app/app/modules/user/shared/views/booking_screen.dart';
import 'package:harry_service_app/app/modules/user/trasnport/views/transport_details_screen.dart';

import '../core/bindings/app_bindings.dart';
import '../modules/all_service/views/AllServiceScreen.dart';
import '../modules/auth/views/login_screen.dart';
import '../modules/auth/views/otp_verification_screen.dart';
import '../modules/auth/views/signup_screen.dart';
import '../modules/onboard/views/on_boarding_screen.dart';



import '../modules/user/hire/bindings/hire_details_bindings.dart';
import '../modules/user/pass/bindings/booking_details_binding.dart';
import '../modules/user/pass/bindings/pass_details_bindings.dart';
import '../modules/user/shared/bindings/bottom_bindings.dart';
import '../modules/user/shared/views/bottom_nav_screen.dart';

import '../modules/user/pass/views/set_information.dart';
import 'app_routes.dart';

abstract class AppPages {

  /// for initial screen
  static const initialRoutes = Routes.splash;

  /// all the screen as list
  static final routes = [


    ///====================== auth=================================================
    GetPage(
        name: Routes.login,
        page: () => LoginScreen(),
      binding: LoginBindings()
    ),

    /// user signup
    GetPage(
        name: Routes.signup,
        page: () => SignupScreen(),
        binding:signupBindings()

    ),


    /// provider signup
    GetPage(
        name: Routes.providerSignUp,
        page: ()=>ProviderSignUp()
    ),

    /// email Verify
    GetPage(
        name: Routes.emailVerify,
        page: ()=>EmailVerifyScreen(),
      binding: EmailVerifyBindings()
    ),



    /// otp Verify
    GetPage(
        name: Routes.otpVerify,
        page: ()=>OtpVerification(),
      binding: OtpBindings()
    ),


   /// Reset Screen
    GetPage(
        name: Routes.passReset,
        page: ()=>PassResetScreen(),
      binding: PassResetBindings()
    ),







    ///======================== user section==================================================
    GetPage(
      /// all service
      name: Routes.service,
      page: () => AllServiceScreen(),
    ),

    /// pass
    GetPage(
        name: Routes.passCardDetails,
        page: () => PassDetailsScreen(),

    binding: SinglePassDetailsBindings()
    ),

    GetPage(
      /// pass booking details
      name: Routes.passInformation,
      page: () => SetInformation(),
      binding: BookingDetailsBindings()
    ),

    ///bottom nav
    GetPage(name: Routes.bottomNav,
        page: () => BottomNavScreen(),
      binding: BottomNavBinding(),
    ),


    /// transport
    GetPage(
      name: Routes.transportDetails,
      page: () => TransportDetailsScreen(),
    ),

    /// message
    GetPage(name: Routes.massageDetails, page: () => MassageDetailsScreen()),

    GetPage(name: Routes.bookingRequest, page: () => BookingRequest()),

    /// hire
    GetPage(name: Routes.hireDetails, page: () => HireDetailsScreen(),
    binding: HireDetailsBinding()),

    /// restaurant
    GetPage(name: Routes.restaurantDetails, page: () => RestaurantDetails()),


    /// onboarding screen

    GetPage(name: Routes.onBoarding, page: () => OnBoardingScreen()),


    /// splash screen
    GetPage(name: Routes.splash, page: ()=>SplashScreen()),






    /// provider section ========================================


  /// shared provided
    GetPage(name: Routes.providerNavScreen,
        page: ()=>ProviderNavScreen()
    ),


    GetPage(name: Routes.messagingScreen,
        page: ()=>MessagingScreen()
     ),



    ///provider profile
    GetPage(name: Routes.providerInfoScreen,
        page: ()=>ProviderAccountInformationScreen(),
      binding: GetProfileBinding()

     ),

  GetPage(name: Routes.providerSettingsScreen,
        page: ()=>ProviderSettingsScreen()
     ),

 GetPage(name: Routes.providerPassScreen,
        page: ()=>ProviderPassScreen(),
        binding: ChangePassBinding()
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
