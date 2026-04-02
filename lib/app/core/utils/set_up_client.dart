


import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../data/services/network/network_caller.dart';
import '../../routes/app_routes.dart';
import '../controllers/auth_controller.dart';





NetworkCaller setUpNetworkClient() {
  return NetworkCaller(
      onUnAuthorize: _onUnAuthorize,
      accessToken: () => Get.find<AuthController>().accessToken ?? ""
  );
}

Future<void> _onUnAuthorize() async {
  Get.offAllNamed(Routes.login); // Go to login if token invalid
}
