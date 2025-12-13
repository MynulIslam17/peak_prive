import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../../core/constants/text-style.dart';

class TransportBookingDetails extends StatefulWidget {
  const TransportBookingDetails({super.key});

  @override
  State<TransportBookingDetails> createState() =>
      _TransportBookingDetailsState();
}

class _TransportBookingDetailsState extends State<TransportBookingDetails> {
  final PanelController _panelController = PanelController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SlidingUpPanel(
        controller: _panelController,
        maxHeight: size.height * 0.75,
        minHeight: size.height * 0.55,
        parallaxEnabled: true,
        parallaxOffset: 0.2,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        panelBuilder: (ScrollController sc) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ListView(
              controller: sc,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Booking Information",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const ListTile(
                  leading: Icon(Icons.restaurant),
                  title: Text("Restaurant Name"),
                  subtitle: Text("Address goes here"),
                ),
                const ListTile(
                  leading: Icon(Icons.people),
                  title: Text("Number of Guests"),
                  subtitle: Text("4 Guests"),
                ),
                const ListTile(
                  leading: Icon(Icons.schedule),
                  title: Text("Booking Time"),
                  subtitle: Text("12:00 PM - 2:00 PM"),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Confirm Booking"),
                ),
              ],
            ),
          );
        },
        body: Stack(
          children: [

            Container( /// header image
              height: size.height * 0.5,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1a1a2e).withOpacity(0.7),
                    const Color(0xFF16213e).withOpacity(0.7),
                  ],
                ),
              ),
              child: Image.asset("assets/images/restu1.jpg", fit: BoxFit.cover),
            ),
            ///  Title
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Request Details",
                  style: AppTextStyle.h2_semibold_22(color: Colors.white),
                ),
              ),
            ),
            ///  Back button
            Positioned(
              top: 50,
              left: 16,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }













}
