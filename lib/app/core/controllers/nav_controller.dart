

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

  void  resetType(){


    _serviceType="";
    update();

  }



   void resetIndex() {
     _currentIndex = 0;
     update();
   }



   /// counter  controll

 int _count=0;

  int get getCount=>_count;


  void increaseCount(){
    _count++;
    update();
  }

  void decreaseCount(){
    _count--;
    update();
  }

  void resetCount(){
    _count=0;
    update();
  }








}