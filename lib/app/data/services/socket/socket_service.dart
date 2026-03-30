// lib/service/socket_service.dart
import 'package:get/get.dart';
import 'socket_helper.dart';

class SocketService extends GetxService {
  late SocketHelper _helper;

  Future<SocketService> init({
    required String userId,
    required String token,
    required String baseUrl,
  }) async {
    _helper = SocketHelper(
      userId: userId,
      authToken: token,
      baseUrl: baseUrl,
    );
    _helper.connect();
    return this;
  }

  SocketHelper get helper => _helper;

  @override
  void onClose() {
    _helper.dispose();
    super.onClose();
  }
}