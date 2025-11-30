//
// import 'package:get/get.dart';
// import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
//
// import '../../data/services/network_caller.dart';
// import '../../routes/app_routes.dart';
//
// NetworkCaller setUpNetworkClient() {
//  return NetworkCaller(onUnAuthorize: _onUnAuthorize, accessToken:(){
//   return  Get.find<AuthController>().accessToken ?? "";
//  });
// }
//
// Future<void> _onUnAuthorize() async {
//
// /// land to login page if unauthorized
//
//  Get.offAllNamed(Routes.login);
//
//
//
//
//
//
// }


import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../data/services/network_caller.dart';
import '../../routes/app_routes.dart';
import '../controllers/auth_controller.dart';

NetworkCaller setUpNetworkClient() {
 return NetworkCaller(
  onUnAuthorize: _onUnAuthorize,
  accessToken: () => Get.find<AuthController>().accessToken ?? "",
 );
}

Future<void> _onUnAuthorize() async {
 Get.offAllNamed(Routes.login); // Go to login if token invalid
}
