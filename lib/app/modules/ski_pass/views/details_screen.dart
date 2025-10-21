
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../gen/assets.gen.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final image=Assets.images;
  final icon=Assets.icons;
  @override
  Widget build(BuildContext context) {
    return Scaffold(

       body:Stack(
         children: [

           image.skiDetails.image(
             height: MediaQuery.sizeOf(context).height * 0.6,
             fit:BoxFit.cover
           ),



           Positioned(
             bottom: 0,
             child: Container(
               height: 300,
               decoration: BoxDecoration(
                 color: Colors.red
               ),
             ),
           )





         ],
       )


    );
  }
}
