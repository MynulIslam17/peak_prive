import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/chats/controllers/chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies

    Get.lazyPut<ChatController>(()=>ChatController());
  }
}
