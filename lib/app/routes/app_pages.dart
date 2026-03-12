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
import 'package:harry_service_app/app/modules/provider/massage/views/massage_booking_details.dart';
import 'package:harry_service_app/app/modules/provider/pass/views/add_pass_screen.dart';
import 'package:harry_service_app/app/modules/provider/pass/views/pass_booking_details.dart';
import 'package:harry_service_app/app/modules/provider/pass/views/provider_booking_details.dart';
import 'package:harry_service_app/app/modules/provider/register/views/provider_info_form.dart';
import 'package:harry_service_app/app/modules/provider/restaurant/views/add_restaurant_screen.dart';
import 'package:harry_service_app/app/modules/provider/restaurant/views/restaurant_booking_details.dart';
import 'package:harry_service_app/app/modules/provider/shared/bindings/change_pass_binding.dart';
import 'package:harry_service_app/app/modules/provider/shared/bindings/provider_nav_bindings.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/change_password_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/messaging_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/provider_account_information_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/provider_booking_request_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/provider_nav_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/provider_profile_secreen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/provider_settings_screen.dart';
import 'package:harry_service_app/app/modules/provider/ski_hire/views/add_hire_screen.dart';
import 'package:harry_service_app/app/modules/provider/ski_hire/views/hire_booking_details.dart';
import 'package:harry_service_app/app/modules/provider/transport/views/add_transport_service.dart';
import 'package:harry_service_app/app/modules/provider/transport/views/trasnsport_booking_details.dart';
import 'package:harry_service_app/app/modules/role/views/role_selection_screen.dart';
import 'package:harry_service_app/app/modules/splash/splash_screen.dart';


import 'package:harry_service_app/app/modules/user/hire/views/hire_details_screen.dart';
import 'package:harry_service_app/app/modules/user/hire/views/user_hire_booking_info.dart';
import 'package:harry_service_app/app/modules/user/itinerary/itinerary_screen.dart';
import 'package:harry_service_app/app/modules/user/massage/bindings/message_details_binding.dart';
import 'package:harry_service_app/app/modules/user/massage/views/booking_request.dart';
import 'package:harry_service_app/app/modules/user/massage/views/massage_details_screen.dart';
import 'package:harry_service_app/app/modules/user/massage/views/user_massage_booking_info.dart';

import 'package:harry_service_app/app/modules/user/pass/views/pass_details_screen.dart';
import 'package:harry_service_app/app/modules/user/pass/views/user_pass_booking_info.dart';
import 'package:harry_service_app/app/modules/user/restaurant/bindings/restaurant_details_bindings.dart';
import 'package:harry_service_app/app/modules/user/restaurant/views/restaurantDetails.dart';
import 'package:harry_service_app/app/modules/user/restaurant/views/restaurant_booking_info.dart';
import 'package:harry_service_app/app/modules/user/restaurant/views/resturant_info_screen.dart';
import 'package:harry_service_app/app/modules/user/restaurant/views/user_restaurant_booking_info.dart';

import 'package:harry_service_app/app/modules/user/shared/bindings/get_profile_binding.dart';
import 'package:harry_service_app/app/modules/user/shared/views/all_transaction.dart';
import 'package:harry_service_app/app/modules/user/shared/views/booking_screen.dart';
import 'package:harry_service_app/app/modules/user/shared/views/extra_booking_screen.dart';
import 'package:harry_service_app/app/modules/user/shared/views/user_wallet.dart';
import 'package:harry_service_app/app/modules/user/trasnport/bindings/trasnport_details_bindings.dart';
import 'package:harry_service_app/app/modules/user/trasnport/views/transport_details_screen.dart';
import 'package:harry_service_app/app/modules/user/trasnport/views/user_transport_booking_info.dart';

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
        page: ()=>ProviderSignUp(),
        binding: signupBindings()

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

        GetPage( /// show booking details to user
        name: Routes.userPassBookingDetails,
        page: () => UsePassBookingInfo(),

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


      ///boooking extra payment
    GetPage(name: Routes.bookingExtraPayment,
        page: () => ExtraBookingScreen(),
      binding: BottomNavBinding(),
    ),





    /// transport==============
    GetPage(
      name: Routes.transportDetails,
      page: () => TransportDetailsScreen(),
      binding: TransportDetailsBindings()
    ),

        GetPage( /// show booking details to user
      name: Routes.userTransportBookingDetails,
      page: () => UserTransportBookingInfo(),

    ),





    /// message
    GetPage(
        name: Routes.massageDetails,
        page: () => MassageDetailsScreen(),
      binding: MessageDetailsBindings()),

    GetPage(name: Routes.bookingRequest,
        page: () => BookingRequest(),
    binding: BookingDetailsBindings()
    ),

    GetPage( /// show booking details to user
        name: Routes.userMassageBookingDetails,
        page: () => UserMassageBookingInfo(),

    ),



    /// hire
    GetPage(name: Routes.hireDetails,
        page: () => HireDetailsScreen(),
    binding: HireDetailsBinding()),

    GetPage(
        name: Routes.userHireBookingDetails,/// show booking details to user
        page: () => UserHireBookingInfo(),

    ),

    /// restaurant
    GetPage(
        name: Routes.restaurantDetails,
        page: () => RestaurantDetails(),
    binding: RestaurantDetailsBindings()
    ),

    GetPage(/// show booking details to user
        name: Routes.userRestaurantBookingDetails,
        page: () => UserRestaurantBookingInfo(),

    ),

    GetPage(name: Routes.restaurantInfo, page: () => RestaurantInfoScreen(),
    binding: RestaurantDetailsBindings()),

    GetPage(name: Routes.restaurantBookingInfo, page: () => RestaurantBookingInfo(),
    binding: RestaurantDetailsBindings()),


    /// onboarding screen

    GetPage(name: Routes.onBoarding, page: () => OnBoardingScreen()),


    /// splash screen
    GetPage(name: Routes.splash, page: ()=>SplashScreen()),




    /// user wallet

    GetPage(name: Routes.userWallet, page: ()=>UserWallet()),
    GetPage(name: Routes.userTransaction, page: ()=>AllTransaction()),



    /// provider section ========================================


  /// shared provided
    GetPage(name: Routes.providerNavScreen,
        page: ()=>ProviderNavScreen(),
      binding: ProviderNavBindings()
    ),


    GetPage(name: Routes.messagingScreen,
        page: ()=>MessagingScreen()
     ),

   /// provider profile
    GetPage(name: Routes.providerProfileScreen,
        page: ()=>ProviderProfileScreen(),
        binding: GetProfileBinding()

    ),




    ///provider account information
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

    GetPage(name: Routes.passDetailsService,
        page: ()=>PassBookingDetails()
     ),

/// add message service
    GetPage(name: Routes.addMessageService,
        page: ()=>AddMassageScreen()
     ),
  GetPage(name: Routes.massageDetailsService,
        page: ()=>MassageBookingDetails()
     ),

/// add transport service
    GetPage(name: Routes.addTransportService,
        page: ()=>AddTransportScreen()
     ),

    GetPage(name: Routes.transportDetailsService,
        page: ()=>TransportBookingDetails()
     ),



/// add  restaurant service
    GetPage(name: Routes.addRestaurantService,
        page: ()=>AddRestaurantScreen()
     ),

   GetPage(name: Routes.restaurantDetailsService,/// show booking user data to provider
        page: ()=>RestaurantBookingDetails()
     ),

/// add  hire service
    GetPage(name: Routes.addHireService,
        page: ()=>AddHireScreen()
     ),

    /// add  hire service
    GetPage(name: Routes.hireDetailsService, /// show booking user data to provider
        page: ()=>HireBookingDetails()
     ),


    GetPage(name: Routes.itinerary,
        page: ()=>ItineraryScreen()
     ),





















  ];
}
