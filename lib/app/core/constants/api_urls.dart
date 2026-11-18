
class AppUrls{
  //https://api.peakprivee.com/api/v1
  //https://wn85j8p6-5000.asse.devtunnels.ms/api/v1

/// base url
  static const baseUrl="https://sushil5000.ssh.bd/api/v1";

  /// Socket.IO server: the same host as the API. (api.peakprivee.com still
  /// runs the previous backend, which never sends `booking:updated` or
  /// `notification:new` for bookings made on this API.)
  static final socketBaseUrl = Uri.parse(baseUrl).origin;

  /// loginUrl
  static const loginUrl="$baseUrl/auth/login";

  /// New access token from a stored refresh token.
  static const refreshTokenUrl = "$baseUrl/auth/refresh-token";

  /// Ends the session on the server.
  static const logoutUrl = "$baseUrl/auth/logout";


  ///user signup url5
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
static String bookingReviewUrl({required String productId,required String serviceType})=>"$baseUrl/$serviceType/review/${productId}";


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

  static String myItineraryUrl="$baseUrl/booking/itinerary";


/// ===================provider===========================

/// ======================= home ==================================


   static String providerHome="$baseUrl/dashboard/meta/provider"; /// home
   static String providerBookingUrl="$baseUrl/booking/all";


  /// booking single

  static String bookingSingleItem(String id)=>"$baseUrl/booking/$id";

  /// change booking status  /booking/update-status

  static String changeBookingStatus(String id)=>"$baseUrl/booking/update-status/$id";

  /// Provider declines a booking: full refund, stock returned, guest notified.
  static String rejectBooking(String id) => "$baseUrl/booking/reject/$id";

  /// Hire / transport: equipment or vehicle given to the guest.
  static String handOverBooking(String id) => "$baseUrl/booking/hand-over/$id";

  /// Hire / transport: returned. The server works out the late fee.
  static String completeBooking(String id) => "$baseUrl/booking/complete/$id";


  // Wallet, withdrawals and notifications: see PeakApi (lib/app/data/api).


/// chats

  static String allChatList = '$baseUrl/chat/chat-users';
  static String messageHistory(String otherUserId) =>'$baseUrl/chat/user-messages/${otherUserId}';


}