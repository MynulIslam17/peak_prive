
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

  /// show category wise data if category missing then show all data(also work for home url)
static String hireAllServiceUrl([String ? category]){

  if(category!=null && category.isNotEmpty){
    return "$baseUrl/ski-hire/all?category=$category";
  }

  return"$baseUrl/ski-hire/all";

}

/// get hire category

static String hireCategory="$baseUrl/common/category/ski-hire";


/// hire details show

static String hireDetailsUrl(String id)=>"$baseUrl/ski-hire/${id}";


/// give rating and review
static String hireBookingReviewUrl(String productId)=>"$baseUrl/ski-hire/review/${productId}";




///===============================transport======================================

  /// show category wise data if category missing then show all data(also work for home url)
 static   String   transportServiceUrl([String ? category]){
   if(category!=null && category.isNotEmpty){
     return "$baseUrl/transport/all?category=$category";
   }
   return "$baseUrl/transport/all";
 }


 /// category list

static String transportCategoryUrl="$baseUrl/common/category/transport";






















}