import 'package:get/get.dart';

import '../controllers/itinerary_controller.dart';

class ItineraryBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(ItineraryController());
  }
}
