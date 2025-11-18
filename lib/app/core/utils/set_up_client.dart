
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';

import '../../data/services/network_caller.dart';
import '../../routes/app_routes.dart';

NetworkCaller setUpNetworkClient() {
 return NetworkCaller(onUnAuthorize: _onUnAuthorize, accessToken:(){
  return  Get.find<AuthController>().accessToken ?? "";
 });
}

Future<void> _onUnAuthorize() async {

/// land to login page if unauthorized

 Get.offAllNamed(Routes.login);






}