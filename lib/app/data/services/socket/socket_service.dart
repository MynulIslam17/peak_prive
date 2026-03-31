// lib/service/socket_service.dart

import 'package:get/get.dart';
import 'socket_helper.dart';

/// SocketService is a GetxService responsible for managing the
/// socket connection throughout the app.
///
/// It uses [SocketHelper] internally to connect, disconnect,
/// and handle socket events. This service can be reset or disposed
/// when necessary, e.g., on logout or user switch.
class SocketService extends GetxService {

  /// Internal SocketHelper instance
  late SocketHelper _helper;

  /// Initialize the SocketService with user credentials and base URL.
  ///
  /// This will create a new [SocketHelper] and establish a socket connection.
  /// Returns the instance of this service for chaining.
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

  /// Reset the socket connection by disposing the old one
  /// and creating a new [SocketHelper] with new credentials.
  ///
  /// This can be useful on logout/login or switching users.
  void reset({
    required String userId,
    required String token,
    required String baseUrl,
  }) {
    _helper.dispose();
    _helper = SocketHelper(
      userId: userId,
      authToken: token,
      baseUrl: baseUrl,
    );
    _helper.connect();
  }

  /// Expose the internal [SocketHelper] instance
  SocketHelper get helper => _helper;

  /// Dispose the socket connection when this service is closed.
  /// This is automatically called by GetX when removing the service
  /// if it is not marked permanent.
  @override
  void onClose() {
    _helper.dispose();
    super.onClose();
  }
}