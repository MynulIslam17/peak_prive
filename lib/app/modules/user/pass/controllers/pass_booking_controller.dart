import 'package:get/get.dart';
import '../../../../core/constants/api_urls.dart';
import '../../../../data/services/network_caller.dart';

class CreateBookingController extends GetxController {
  bool _bookingProgress = false;
  String? _errorMessage;
  String? _sessionUrl;
  String? _sessionId;

  bool get bookingProgress => _bookingProgress;
  String? get errorMessage => _errorMessage;
  String? get sessionUrl => _sessionUrl;
  String? get sessionId => _sessionId;

  /// Now accepting a `Map<String, dynamic>` directly
  Future<bool> proceedBooking(Map<String, dynamic> body) async {
    _bookingProgress = true;
    update();

    try {
      /// Send the booking request data as a POST request
      final response = await Get.find<NetworkCaller>().postRequest(
        url: AppUrls.userBookingUrl,
        body: body,
      );

      if (response.isSuccess && response.body != null) {
        final data = response.body!['data'];


        _errorMessage = null;
        update();
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Booking failed.";
        update();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      update();
      return false;
    } finally {
      _bookingProgress = false;
      update();
    }
  }
}
