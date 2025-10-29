

  import 'package:get/get.dart';

class NavController extends GetxController{

   int _currentIndex=0;

   String _serviceType="";

   String get getServiceType=>_serviceType;


  int get getIndex=>_currentIndex;


  void changeIndex(int index){


  _currentIndex=index;

    update();

  }

  void  addType(String serviceType){


    _serviceType=serviceType;
    update();

  }



   void resetIndex() {
     _currentIndex = 0;
     update();
   }





}