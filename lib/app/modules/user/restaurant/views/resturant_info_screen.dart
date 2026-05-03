import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/widgets/appbar_with_title.dart';
import 'package:harry_service_app/app/core/widgets/custome_back_button.dart';
import 'package:harry_service_app/app/modules/user/pass/controllers/pass_booking_controller.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../routes/app_routes.dart';

class RestaurantInfoScreen extends StatefulWidget {
  const RestaurantInfoScreen({super.key});

  @override
  State<RestaurantInfoScreen> createState() => _RestaurantInfoScreenState();
}

class _RestaurantInfoScreenState extends State<RestaurantInfoScreen> {

  late Map<String, dynamic> productInfo;



  @override
  void initState() {
    super.initState();
    productInfo = Get.arguments as Map<String, dynamic>;
  }

  final icons = Assets.icons;
  final images = Assets.images;

  Widget _buildDetailRow(String label, String value, {Color valueColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String price, Color goldColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontFamily: 'Roboto', color: Colors.black),
              children: [
                TextSpan(
                  text: '€$price',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: goldColor),
                ),
                const TextSpan(
                  text: '/per seat',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color goldColor = Color(0xFFD4AF37);
    const Color availableColor = Colors.red;

    return Scaffold(

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          productInfo["thumbnail"] ?? "",
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                          ),
                        ),
                      ),

                      // Properly positioned custom back button
                      Positioned(
                        top: 16,
                        left: 16,
                        child: CustomBackButton(
                          onTap: () => Get.back(),
                        ),
                      ),
                    ],
                  ),


                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        "${productInfo["seatType"]}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: goldColor),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        _buildDetailRow("Total seat", productInfo["totalSeat"].toString()),
                        const Divider(height: 1),
                        _buildDetailRow("Available seat", productInfo["availableSeat"].toString(), valueColor: availableColor),
                        const Divider(height: 1),
                        _buildPriceRow("Price", productInfo["price"].toString(), goldColor),
                        const Divider(height: 1),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                   Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(
                          "${productInfo["description"]}",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Get.toNamed(Routes.restaurantBookingInfo,

                arguments: productInfo
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
