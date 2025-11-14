abstract class Routes {
  // ===========================================================================
  // 🧍 USER SECTION
  // ===========================================================================


  /// SkiPass
  static const service = "/service";

  /// Bottom Navigation
  static const bottomNav = "/transportNav";

  /// Pass
  static const passInformation = "/passInfo";
  static const passCardDetails = "/passDetails";

  /// Transport
  static const transportDetails = "/transportDetails";

  /// Message
  static const massageDetails = "/massageDetails";
  static const bookingRequest = "/bookingRequest";

  /// Hire
  static const hireDetails = "/hireDetails";

  /// Profile
  static const profile = "profile";

  /// Restaurant
  static const restaurantDetails = "/restaurantDetails";





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


///add services  part
///pass
  static const addPassService="/addPass";

  /// massage
static const addMessageService="/addMessageService";

/// transport
  static const addTransportService="/addTransportService";

  /// restaurant
  static const addRestaurantService="/addRestaurantService";




}
