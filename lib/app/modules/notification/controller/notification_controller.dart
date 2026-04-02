import 'package:get/get.dart';
import 'package:harry_service_app/app/data/services/network/network_caller.dart';
import '../../../core/constants/api_urls.dart';
import '../model/notification_model.dart';

class NotificationController extends GetxController {
  /// Notification list
  List<NotificationItem> notificationList = [];

  /// Loading & error
  bool _isLoading = false;
  String? _errorMessage;

  /// Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch notifications from backend
  Future<bool> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    update();

    bool success = false;

    try {
      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrls.notificationUrl,
      );

      if (response.isSuccess && response.body != null) {
        final model = NotificationResponse.fromJson(response.body!);
        notificationList = model.data;
        success = true;
      } else {
        _errorMessage = 'Failed to fetch notifications';
        success = false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      success = false;
    } finally {
      _isLoading = false;
      update();
    }

    return success;
  }

  /// Clear notifications
  void clearData() {
    notificationList.clear();
    _errorMessage = null;
    _isLoading = false;
    update();
  }
}