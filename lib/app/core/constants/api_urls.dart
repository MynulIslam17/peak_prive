
class AppUrls{
  //https://qwkbmjl3-5000.inc1.devtunnels.ms/api/v1

/// base url
  static const baseUrl="https://qwkbmjl3-5000.inc1.devtunnels.ms/api/v1";

  /// loginUrl
  static const loginUrl="$baseUrl/auth/login";


  ///user signup url
 static const userSignUp="$baseUrl/auth/register";

 /// verify email
  static const verifyEmail="$baseUrl/auth/forgot-password";

 ///user verify otp url
 static const verifyOtp="$baseUrl/auth/verify-otp";

 /// resend otp url
 static const resendOtp="$baseUrl/auth/resend-otp";

 /// password reset  url
 static const passResetUrl="$baseUrl/auth/reset-password";

 /// ski pass all service
static const passAllServiceUrl="$baseUrl/ski-pass/all";

/// single pass details method
static String singlePassDetails(String id)=>"$baseUrl/ski-pass/$id";

///  create booking booking
static String passBookingUrl="${baseUrl}/booking/create";


///get my booking
static String myBookingUrl(String category)=>"${baseUrl}/booking/my-booking?category=${category}";

/// get my profile

static String getMyProfileUrl="$baseUrl/users/profile/me";

  /// update profile url
static String updateProfileUrl="$baseUrl/users/update-profile";


  /// update profile url
static String changePasswordUrl="$baseUrl/auth/change-password";



  /// ==========================hire=======================
static String hireAllServiceUrl="$baseUrl/ski-hire/all";

static String hireDetailsUrl(String id)=>"$baseUrl/ski-hire/${id}";




















}