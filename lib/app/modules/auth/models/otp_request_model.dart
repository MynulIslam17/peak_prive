class OtpRequestModel{

  final String email;
  final String otp;


  OtpRequestModel({required this.otp,required this.email});


  Map<String,dynamic> toJson(){
    return {
      "email":email,
      "otp": otp
    };


  }





}