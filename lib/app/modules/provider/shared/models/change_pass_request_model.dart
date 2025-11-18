
import 'package:flutter/foundation.dart';

class ChangePassRequestModel{

  final String  currentPassword;
  final String  newPassword;

  ChangePassRequestModel({
    required this.newPassword,
    required this.currentPassword}
      );



   Map<String,dynamic> toJson(){


     return {
       "currentPassword":currentPassword,
       "newPassword": newPassword
     };
   }







}