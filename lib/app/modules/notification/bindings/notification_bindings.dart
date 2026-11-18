import 'package:get/get.dart';

import '../controller/notification_controller.dart';

class NotificationBindings extends Bindings {
  @override
  void dependencies() => NotificationController.ensure();
}
