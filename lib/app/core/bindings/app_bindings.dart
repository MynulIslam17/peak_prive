

 import 'package:get/get.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/core/utils/set_up_client.dart';


import '../../data/api/peak_api.dart';
import '../../data/services/network/connectivity_controller.dart';
import '../constants/api_urls.dart';
import '../../modules/chats/controllers/chat_list_controller.dart';
import '../controllers/nav_controller.dart';

class AppBindings extends Bindings{
  @override
  void dependencies() {


    /// nav controllers
    Get.put<NavController>(NavController());

    final http = Get.put(setUpNetworkClient());
    // Typed API for listings, bookings, notifications, wallet, dashboard.
    Get.put(PeakApi(http, baseUrl: AppUrls.baseUrl), permanent: true);
    Get.put(AuthController());


    Get.put(ChatListController());
    Get.put(ConnectivityController(), permanent: true);


    
  }




}