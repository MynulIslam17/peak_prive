import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/user/pass/models/booking_success_model.dart';
import '../../../../core/constants/api_urls.dart';
import '../../../../data/services/network_caller.dart';

class CreateBookingController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  TicketModel? _successResponse;

  // getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  TicketModel? get successResponse => _successResponse;

  /// Booking method
  Future<bool> proceedBooking(Map<String, dynamic> body) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    update(); // UI update

    try {
      // 1️⃣ Call API
      final response = await Get.find<NetworkCaller>().postRequest(
        url: AppUrls.userBookingUrl,
        body: body,
      );

      // 2️⃣ Success Case
      if (response.isSuccess && response.body != null) {
        // JsonHelper inside TicketModel handles nulls & type safety
        _successResponse = TicketModel.fromJson(response.body!);
        _successMessage = response.body!['message'] ?? "Booking successful";
        return true;
      }

      // 3️⃣ API returned failure
      _errorMessage = response.errorMessage ?? "Booking failed";
      return false;

    } catch (e) {
      // 4️⃣ Exception Case
      _errorMessage = e.toString();
      return false;

    } finally {
      _isLoading = false;
      update(); // final UI update
    }
  }
}