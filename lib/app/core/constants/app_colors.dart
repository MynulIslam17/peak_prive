
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

 /// ===================================================================
 /// Neutral + semantic tokens.
 ///
 /// These were missing, which is why screens reached for `Colors.white`,
 /// `Colors.grey.shade300` and `Colors.red` directly — there was nowhere
 /// else to get them from. Everything below is additive; existing tokens
 /// keep their values.
 /// ===================================================================

 /// Surfaces
 static const Color white = Color(0xFFFFFFFF);

 /// The one page background for every screen: white. Cards on it keep their
 /// border; inputs and chips use [surfaceAlt].
 static const Color scaffold = Color(0xFFFFFFFF);

 /// Picker accents (selected hour, AM/PM, today's date ring).
 static const Color goldTint = Color(0xFFFBF3DC);
 static const Color goldDeep = Color(0xFF9A7A12);
 static const Color surface = Color(0xFFFFFFFF);
 static const Color surfaceAlt = Color(0xFFFDFAF6);

 /// Lines + dividers
 static const Color border = Color(0xFFEEEEEE);
 static const Color divider = Color(0xFFE6E6E6);

 /// Text
 static const Color textPrimary = black_1;
 static const Color textSecondary = black_2;
 static const Color textTertiary = black_3;
 static const Color textOnPrimary = Color(0xFF1A1500);
 static const Color textDisabled = Color(0xFF9E9E9E);

 /// States
 static const Color disabled = Color(0xFFE0E0E0);
 static const Color error = Color(0xFFD14343);
 static const Color success = Color(0xFF2E7D4F);
 static const Color warning = Color(0xFFE8A33D);
 static const Color info = secendary;

 /// Shimmer. Previously every skeleton picked its own pair, and
 /// home_shimmer used the same colour for base and highlight, which
 /// rendered a static grey block with no animation at all.
 static const Color shimmerBase = Color(0xFFE4E4E4);
 static const Color shimmerHighlight = Color(0xFFF5F5F5);




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