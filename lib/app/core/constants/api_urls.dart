
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

  /// show single transport details
static String transportDetailsUrl(String id)=>"$baseUrl/transport/$id";



///================================Message  ============================================
  ///
  /// show category wise data if category missing then show all data(also work for home url)
  static   String   massageServiceUrl([String ? category]){
    if(category!=null && category.isNotEmpty){
      return "$baseUrl/massage/all?category=$category";
    }
    return "$baseUrl/massage/all";
  }

  /// massage category list
  static String massageCategoryUrl="$baseUrl/common/category/massage";

  /// show single massage  details
  static String massageDetailsUrl(String id)=>"$baseUrl/massage/$id";




  /// ===================restaurant =========================================


  /// show category wise data if category missing then show all data(also work for home url)
  static   String   restaurantServiceUrl([String ? category]){
    if(category!=null && category.isNotEmpty){
      return "$baseUrl/restaurant/all?category=$category";
    }
    return "$baseUrl/restaurant/all";
  }


  /// show single restaurant  details
  static String restaurantDetailsUrl(String id)=>"$baseUrl/restaurant/$id";


  /// restaurant category list
  static String restaurantCategoryUrl="$baseUrl/common/category/restaurant";








/// ===================provider===========================

/// ======================= home ==================================


   static String providerHome="$baseUrl/dashboard/meta/provider"; /// home
   static String providerServiceUrl="$baseUrl/ski-pass/my-all";
   static String providerBookingUrl="$baseUrl/booking/all";

///    =======         ski all service url======
  static String providerPassService="$baseUrl/ski-pass/my-all";
  /// ski service update url
  static String  providerPassServiceUpdate(String id)=>"$baseUrl/ski-pass/update/$id";
  /// ski service delete url
  static String  providerPassServiceDelete(String id)=>"$baseUrl/ski-pass/delete/$id";

/// ==============pass create url=================
  static String providerPassCreateUrl="$baseUrl/ski-pass/create";



  ///=============restaurant provider=======================

  ///      create restaurant
  static String providerRestaurantService="$baseUrl/restaurant/my-all";
  static String createRestaurantUrl="$baseUrl/restaurant/create";
  ///      update restaurant
  static String updateRestaurantUrl(String id)=>"$baseUrl/restaurant/update/${id}";
  ///      delete restaurant
  static String deleteRestaurantUrl(String id)=>"$baseUrl/restaurant/delete/${id}";


  ///================== massage provider========================

  static String providerMassageService="$baseUrl/massage/my-all";
  static String  deleteMassageServiceUrl(String id)=>"$baseUrl/massage/delete/$id";
  static String  createMassageServiceUrl="$baseUrl/massage/create";





















}