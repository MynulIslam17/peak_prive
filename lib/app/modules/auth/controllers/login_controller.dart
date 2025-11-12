
 import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import 'package:harry_service_app/app/modules/auth/models/login_request_model.dart';

class LoginController extends GetxController{

  bool _loginProgress=false;
  bool get loginProgress=>_loginProgress;

  String ?_errorMessage;

  String ?get errorMessage=>_errorMessage;

  String _role="";

  String get role=>_role;


  Future<bool> login(LoginRequestModel model) async{


    bool success=false;


    _loginProgress=true;
    update();

     NetworkResponse response=await Get.find<NetworkCaller>().postRequest(url: AppUrls.loginUrl,body:model.toJson() );

      _loginProgress=false;

      if(response.isSuccess){

         _role=response.body!["data"]["user"]["role"];

         success=true;
        _errorMessage=null;
      }else{
        _errorMessage=response.errorMessage;
      }

    update();

      return success;



  }








 }