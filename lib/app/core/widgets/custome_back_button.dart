import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../gen/assets.gen.dart';

class CustomBackButton extends StatelessWidget {

  final VoidCallback onTap;


  final icon=Assets.icons;
  const CustomBackButton({
    super.key,
    required this.onTap,

  });



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.5),
          child:IconButton(onPressed:onTap , icon: icon.caretLeft.svg()),
        ),
      ),
    );
  }
}