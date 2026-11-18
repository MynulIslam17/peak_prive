import 'package:get/get.dart';

import '../../data/services/network/network_caller.dart';
import '../../routes/app_routes.dart';
import '../controllers/auth_controller.dart';

NetworkCaller setUpNetworkClient() {
  return NetworkCaller(
    onUnAuthorize: _onUnAuthorize,
    accessToken: () =>
        Get.isRegistered<AuthController>()
            ? (Get.find<AuthController>().accessToken ?? "")
            : "",
  );
}

/// A single screen often fires several requests at once, so an expired token
/// produces a burst of 401s. Without this guard each one triggers its own
/// `offAllNamed`, which stacks navigations and can leave the router wedged.
bool _isHandlingUnauthorized = false;

Future<void> _onUnAuthorize() async {
  if (_isHandlingUnauthorized) return;
  _isHandlingUnauthorized = true;

  try {
    if (Get.isRegistered<AuthController>()) {
      // Clears the stale token and local profile as well as navigating; simply
      // routing to login used to leave the dead token in SharedPreferences, so
      // the next launch restored a session that the server already rejected.
      await Get.find<AuthController>().logout();
    } else {
      Get.offAllNamed(Routes.login);
    }
  } finally {
    _isHandlingUnauthorized = false;
  }
}
