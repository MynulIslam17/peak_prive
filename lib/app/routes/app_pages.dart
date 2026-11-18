import 'dart:developer';

import 'package:get/get_navigation/get_navigation.dart';
import 'package:harry_service_app/app/modules/auth/bindings/email_verify_bindings.dart';
import 'package:harry_service_app/app/modules/auth/bindings/login_bindings.dart';
import 'package:harry_service_app/app/modules/auth/bindings/otp_bindings.dart';
import 'package:harry_service_app/app/modules/auth/bindings/pass_reset_bindings.dart';
import 'package:harry_service_app/app/modules/auth/bindings/signup_bindings.dart';
import 'package:harry_service_app/app/modules/auth/views/email_verify_screen.dart';

import 'package:harry_service_app/app/modules/auth/views/pass_reset_screen.dart';
import 'package:harry_service_app/app/modules/chats/bingings/chat_binding.dart';
import 'package:harry_service_app/app/modules/notification/bindings/notification_bindings.dart';
import 'package:harry_service_app/app/modules/notification/views/notification_screen.dart';
import 'package:harry_service_app/app/modules/provider/massage/views/add_massage_screen.dart';
import 'package:harry_service_app/app/modules/provider/pass/views/add_pass_screen.dart';
import 'package:harry_service_app/app/modules/provider/register/views/provider_info_form.dart';
import 'package:harry_service_app/app/modules/provider/restaurant/views/add_restaurant_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/bindings/change_pass_binding.dart';
import 'package:harry_service_app/app/modules/provider/shared/bindings/provider_nav_bindings.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/change_password_screen.dart';

import 'package:harry_service_app/app/modules/provider/shared/views/provider_account_information_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/provider_booking_request_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/provider_nav_screen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/provider_profile_secreen.dart';
import 'package:harry_service_app/app/modules/provider/shared/views/provider_settings_screen.dart';
import 'package:harry_service_app/app/modules/provider/ski_hire/views/add_hire_screen.dart';
import 'package:harry_service_app/app/modules/provider/transport/views/add_transport_service.dart';
import 'package:harry_service_app/app/modules/splash/splash_screen.dart';

import 'package:harry_service_app/app/modules/user/hire/views/hire_details_screen.dart';
import 'package:harry_service_app/app/modules/user/hire/views/hire_checkout_screen.dart';
import 'package:harry_service_app/app/modules/user/itinerary/views/itinerary_screen.dart';
import 'package:harry_service_app/app/modules/user/massage/bindings/message_details_binding.dart';
import 'package:harry_service_app/app/modules/user/massage/views/booking_request.dart';
import 'package:harry_service_app/app/modules/user/massage/views/massage_details_screen.dart';

import 'package:harry_service_app/app/modules/user/pass/views/pass_details_screen.dart';
import 'package:harry_service_app/app/modules/user/pass/views/ticket_screen.dart';
import 'package:harry_service_app/app/modules/user/restaurant/bindings/restaurant_details_bindings.dart';
import 'package:harry_service_app/app/modules/user/restaurant/views/restaurantDetails.dart';

import 'package:harry_service_app/app/modules/user/shared/bindings/get_profile_binding.dart';
import 'package:harry_service_app/app/modules/user/shared/bindings/wallet_binder.dart';
import 'package:harry_service_app/app/modules/user/shared/views/all_transaction.dart';
import 'package:harry_service_app/app/modules/user/shared/views/booking_screen.dart';
import 'package:harry_service_app/app/modules/user/shared/views/user_wallet.dart';
import 'package:harry_service_app/app/modules/user/trasnport/bindings/trasnport_details_bindings.dart';
import 'package:harry_service_app/app/modules/user/trasnport/views/transport_details_screen.dart';
import 'package:harry_service_app/app/modules/user/trasnport/views/transport_checkout_screen.dart';
import 'package:harry_service_app/app/modules/user/restaurant/views/restaurant_checkout_screen.dart';

import '../core/bindings/app_bindings.dart';
import '../modules/all_service/views/AllServiceScreen.dart';
import '../modules/auth/views/login_screen.dart';
import '../modules/auth/views/otp_verification_screen.dart';
import '../modules/auth/views/signup_screen.dart';
import '../modules/chats/messaging_screen.dart';
import '../modules/onboard/views/on_boarding_screen.dart';

import '../modules/user/hire/bindings/hire_details_bindings.dart';
import '../modules/user/itinerary/bindings/itinerary_bindings.dart';
import '../modules/user/pass/bindings/pass_details_bindings.dart';
import '../modules/user/shared/bindings/bottom_nav_bindings.dart';
import '../modules/user/shared/views/bottom_nav_screen.dart';

import '../modules/user/pass/views/set_information.dart';
import '../modules/user/shared/views/withdraw_screen.dart';
import '../modules/booking/views/booking_details_screen.dart';
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
      binding: LoginBindings(),
    ),

    /// user signup
    GetPage(
      name: Routes.signup,
      page: () => SignupScreen(),
      binding: signupBindings(),
    ),

    /// provider signup
    GetPage(
      name: Routes.providerSignUp,
      page: () => ProviderSignUp(),
      binding: signupBindings(),
    ),

    /// email Verify
    GetPage(
      name: Routes.emailVerify,
      page: () => EmailVerifyScreen(),
      binding: EmailVerifyBindings(),
    ),

    /// otp Verify
    GetPage(
      name: Routes.otpVerify,
      page: () => OtpVerification(),
      binding: OtpBindings(),
    ),

    /// Reset Screen
    GetPage(
      name: Routes.passReset,
      page: () => PassResetScreen(),
      binding: PassResetBindings(),
    ),

    ///======================== user section==================================================
    GetPage(
      /// all service
      name: Routes.service,
      page: () => AllServiceScreen(),
      // Cross-fade from the splash/login: no dark frame between them.
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 350),
    ),

    /// pass
    GetPage(
      name: Routes.passCardDetails,
      page: () => PassDetailsScreen(),

      binding: SinglePassDetailsBindings(),
    ),

    GetPage(
      /// show booking details to user
      name: Routes.userPassBookingDetails,
      page: () => const BookingDetailsScreen(),
    ),

    GetPage(
      /// pass booking details
      name: Routes.passInformation,
      page: () => const SetInformation(),
    ),

    GetPage(
      /// pass booking details
      name: Routes.ticket,
      page: () => const TicketScreen(),

    ),

    ///bottom nav
    GetPage(
      name: Routes.bottomNav,
      page: () => BottomNavScreen(),
      binding: BottomNavBinding(),
    ),

    ///boooking extra payment
    GetPage(
      // Late fees are paid from the booking screen now.
      name: Routes.bookingExtraPayment,
      page: () => const BookingDetailsScreen(),
    ),

    /// transport==============
    GetPage(
      name: Routes.transportDetails,
      page: () => TransportDetailsScreen(),
      binding: TransportDetailsBindings(),
    ),

    GetPage(
      /// trip checkout (args: {'id', 'listing': TransportDetail?})
      name: Routes.transportCheckout,
      page: () => const TransportCheckoutScreen(),
    ),

    GetPage(
      /// show booking details to user
      name: Routes.userTransportBookingDetails,
      page: () => const BookingDetailsScreen(),
    ),

    /// message
    GetPage(
      name: Routes.massageDetails,
      page: () => MassageDetailsScreen(),
      binding: MessageDetailsBindings(),
    ),

    GetPage(
      name: Routes.bookingRequest,
      page: () => const MassageCheckoutScreen(),
    ),

    GetPage(
      /// show booking details to user
      name: Routes.userMassageBookingDetails,
      page: () => const BookingDetailsScreen(),
    ),

    /// hire
    GetPage(
      name: Routes.hireDetails,
      page: () => HireDetailsScreen(),
      binding: HireDetailsBinding(),
    ),

    GetPage(
      /// equipment checkout (args: {'id', 'listing': SkiHireDetail?, 'quantities'?})
      name: Routes.hireCheckout,
      page: () => const HireCheckoutScreen(),
    ),

    GetPage(
      name: Routes.userHireBookingDetails,

      /// show booking details to user
      page: () => const BookingDetailsScreen(),
    ),

    /// restaurant
    GetPage(
      name: Routes.restaurantDetails,
      page: () => RestaurantDetails(),
      binding: RestaurantDetailsBindings(),
    ),

    GetPage(
      /// table checkout (args: {'id', 'listing': RestaurantDetail?, 'seats'?})
      name: Routes.restaurantCheckout,
      page: () => const RestaurantCheckoutScreen(),
    ),

    GetPage(
      /// show booking details to user
      name: Routes.userRestaurantBookingDetails,
      page: () => const BookingDetailsScreen(),
    ),

    /// onboarding screen
    GetPage(name: Routes.onBoarding, page: () => OnBoardingScreen()),

    /// splash screen
    GetPage(name: Routes.splash, page: () => SplashScreen()),

    /// user wallet
    GetPage(
      name: Routes.userWallet,
      page: () => UserWallet(),
      binding: WalletBinder(),
    ),
    GetPage(
      name: Routes.userTransaction,
      page: () => AllTransaction(),
      binding: WalletBinder(),
    ),
    GetPage(
      name: Routes.withdraw,
      page: () => WithdrawScreen(),
      binding: WalletBinder(),
    ),

    /// provider section ========================================

    /// shared provided
    GetPage(
      name: Routes.providerNavScreen,
      page: () => ProviderNavScreen(),
      binding: ProviderNavBindings(),
    ),

    GetPage(name: Routes.messagingScreen, page: () => MessagingScreen(),binding: ChatBinding()),

    /// provider profile
    GetPage(
      name: Routes.providerProfileScreen,
      page: () => ProviderProfileScreen(),
      binding: GetProfileBinding(),
    ),

    ///provider account information
    GetPage(
      name: Routes.providerInfoScreen,
      page: () => ProviderAccountInformationScreen(),
      binding: GetProfileBinding(),
    ),

    GetPage(
      name: Routes.providerSettingsScreen,
      page: () => ProviderSettingsScreen(),
    ),

    GetPage(
      name: Routes.providerPassScreen,
      page: () => ProviderPassScreen(),
      binding: ChangePassBinding(),
    ),

    GetPage(
      name: Routes.providerBookingDetails,
      page: () => const BookingDetailsScreen(),
    ),

    /// add pass service
    GetPage(name: Routes.addPassService, page: () => AddPassScreen()),

    GetPage(name: Routes.passDetailsService, page: () => const BookingDetailsScreen()),

    /// add message service
    GetPage(name: Routes.addMessageService, page: () => AddMassageScreen()),
    GetPage(
      name: Routes.massageDetailsService,
      page: () => const BookingDetailsScreen(),
    ),

    /// add transport service
    GetPage(name: Routes.addTransportService, page: () => AddTransportScreen()),

    GetPage(
      name: Routes.transportDetailsService,
      page: () => const BookingDetailsScreen(),
    ),

    /// add  restaurant service
    GetPage(
      name: Routes.addRestaurantService,
      page: () => AddRestaurantScreen(),
    ),

    GetPage(
      name: Routes.restaurantDetailsService,

      /// show booking user data to provider
      page: () => const BookingDetailsScreen(),
    ),

    /// add  hire service
    GetPage(name: Routes.addHireService, page: () => AddHireScreen()),

    /// add  hire service
    GetPage(
      name: Routes.hireDetailsService,

      /// show booking user data to provider
      page: () => const BookingDetailsScreen(),
    ),

    GetPage(
      name: Routes.itinerary,
      page: () => ItineraryScreen(),
      binding: ItineraryBindings(),
    ),

    GetPage(name: Routes.itineraryDetails, page: () => const BookingDetailsScreen()),

    /// One booking screen for every service and both roles.
    GetPage(name: Routes.bookingDetails, page: () => const BookingDetailsScreen()),

    GetPage(
      name: Routes.notification,
      page: () => NotificationScreen(),
      binding: NotificationBindings(),
    ),







  ];
}
