

  import 'package:get/get.dart';

class NavController extends GetxController{

   int _currentIndex=0;
  int get getIndex=>_currentIndex;


  void changeIndex(int index){


    _currentIndex=index;

    update();

  }





}