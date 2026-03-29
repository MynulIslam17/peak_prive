abstract class Routes {
  // ===========================================================================
  // 🧍 USER SECTION
  // ===========================================================================


  /// SkiPass
  static const service = "/service";

  /// Bottom Navigation
  static const bottomNav = "/bottomNav";

  /// booking extra payment screen
  static const bookingExtraPayment = "/bookingExtraPayment";


  /// Pass
  static const passInformation = "/passInfo";
  static const passCardDetails = "/passDetails";
  static const userPassBookingDetails="/userPassBookingDetails";

  /// Transport
  static const transportDetails = "/transportDetails";
  static const userTransportBookingDetails = "/userTransportBookingDetails";

  /// Message
  static const massageDetails = "/massageDetails";
  static const bookingRequest = "/bookingRequest";
  static const userMassageBookingDetails="/userMassageBookingDetails";

  /// Hire
  static const hireDetails = "/hireDetails";
  static const userHireBookingDetails = "/userHireBookingDetails";



  /// Profile
  static const profile = "profile";

  /// Restaurant
  static const restaurantDetails = "/restaurantDetails";
  static const restaurantInfo = "/restaurantInfo";
  static const restaurantBookingInfo = "/restaurantBookingInfo";
  static const  userRestaurantBookingDetails = "/userRestaurantBookingDetails";



  /// user wallets

  static const userWallet="/userWallet";
  static const userTransaction="/userTransaction";
  static const withdraw="/withdraw";




  // ===========================================================================
  //  SHARED BY BOTH USER & PROVIDER
  // ===========================================================================

  /// Onboarding
  static const onBoarding = "/onboard";


  /// splash
  static const splash="/splash";

  /// role selection
  static const role = "/role";


  /// Authentication
  static const login = "/login";
  static const signup = "/signUp";
  static const providerSignUp = "/providerSignup"; /// Provider signup
  static const otpVerify="/otpVerify";
  static const emailVerify="/emailVerify";
  static const passReset="/passReset";






  // ===========================================================================
  //  PROVIDER SECTION
  // ===========================================================================





  static const providerNavScreen = "/pNavScreen";  /// Shared Provider Navigation


  static const messagingScreen = "/messagingScreen";  /// Messaging Screen

  static const providerBookingDetails="/providerBookingDetails";





  // ---------------------------------------------------------------------------
  //  Provider Profile / Settings
  // ---------------------------------------------------------------------------

  static const providerInfoScreen = "/providerAccountInfo";
  static const providerSettingsScreen = "/providerSettings";
  static const providerWallet = "/providerWallet";


  // ---------------------------------------------------------------------------
  //  Policy / About / Misc
  // ---------------------------------------------------------------------------

  static const privacyPolicy = "/privacyPolicy";
  static const termsConditions = "/termsConditions";
  static const providerAbout = "/providerAboutUs";
  static const providerPassScreen = "/providerPassScreen";
  static const  providerProfileScreen = "/providerProfileScreen";


///add services  part
///pass
  static const addPassService="/addPass";
  static const passDetailsService="/passDetailsService";/// show booking user data to provider

  /// massage
static const addMessageService="/addMessageService";
static const massageDetailsService="/massageDetailsService";/// show booking user data to provider

/// transport
  static const addTransportService="/addTransportService";
  static const transportDetailsService="/transportDetailsService";/// show booking user data to provider

  /// restaurant
  static const addRestaurantService="/addRestaurantService";
  static const restaurantDetailsService="/restaurantDetailsService"; /// show booking user data to provider
  /// hire
  static const addHireService="/addHireService";
  static const hireDetailsService="/hireDetailsService";/// show booking user data to provider


//itinerary
  static const itinerary="/itinerary";
  static const itineraryDetails="/itineraryDetails";

// notification

static const notification="/notification";












}
