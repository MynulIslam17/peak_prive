

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import '../../../booking/controllers/my_bookings_controller.dart';


import '../../../../data/api/peak_api.dart';
import '../../../chats/controllers/chat_list_controller.dart';
import '../controllers/listing_browse_controller.dart';

class BottomNavBinding extends Bindings {
  @override
  void dependencies() {


    // Home browse, one controller per service (tag = ServiceKind.name).
    for (final kind in ServiceKind.values) {
      ListingBrowseController.register(kind);
    }

    // My bookings tab.
    Get.put(MyBookingsController());




  }
}
