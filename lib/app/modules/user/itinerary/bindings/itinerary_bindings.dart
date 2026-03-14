import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/user/itinerary/controllers/get_all_itinerary_controller.dart';

class ItineraryBindings extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies

    Get.put(GetAllItineraryController());
  }


}