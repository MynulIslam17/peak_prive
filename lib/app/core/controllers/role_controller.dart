
import 'package:get/get.dart';

class  RoleController extends GetxController{

  String _role="";
  String get getRole=>_role;


  void changeRole(String role){

    _role=role;

    update();


  }


}