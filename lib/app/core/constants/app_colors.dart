
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class AppColors {


 static const Color primary_1 =Color(0xffD4AF38);
 static const Color primary_3 =Color(0xffE2C97A);
 static const Color black_1 =Color(0xff0F0E0E);
 static const Color black_2=Color(0xff3F3E3E);
 static const Color black_3 =Color(0xff5E5E5E);

 /// green
 static const Color green300 =Color(0xFF548A65);
 static const Color secendary =Color(0xff5186B1);




 /// appbar background

 static LinearGradient appBarBackground = LinearGradient(
  colors: [
   Colors.brown.withOpacity(0.1), // Brown at the top
   Color(0xff5186B1).withOpacity(0.1), // Blue color blending with brown
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomLeft,
  stops: [0.0, 1.0],  // Brown to blue blend from top to bottom
 );
 
 
 /// gradient for splash

 static const LinearGradient splashGradient = LinearGradient(
   begin: Alignment.topLeft,
   end: Alignment.bottomRight,
   colors: [
     Color(0xFF093825), // Darkest
     Color(0xFF093F29),
     Color(0xFF08523C), // Lighter highlight
     Color(0xFF024E35), // Deep base
   ],
   stops: [0.0, 0.3, 0.7, 1.0],
 );

 /// card background
 static LinearGradient cardBackground = LinearGradient(
  colors: [
   Colors.brown.shade200, // Brown at the top
   Colors.white// Blue color blending with brown
  ],
  begin: Alignment.topRight,
  end: Alignment.center,
  stops: [0.0, 1.0],  // Brown to blue blend from top to bottom
 );


}