
 import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/user/restaurant/controllers/restaurant_details_controller.dart';

class RestaurantDetailsBindings extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies

    Get.lazyPut<RestaurantDetailsController>(()=>RestaurantDetailsController());


  }

}