import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ItineraryDetails extends StatefulWidget {
  const ItineraryDetails({super.key});

  @override
  State<ItineraryDetails> createState() => _ItineraryDetailsState();
}

class _ItineraryDetailsState extends State<ItineraryDetails> {
  final PanelController panelController = PanelController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Placeholder data, replace with your actual model
    final String thumbnail =
        'https://iter-bene.s3.eu-north-1.amazonaws.com/uploads/ski-pass/49113051-d009-411b-8b8e-34493b474baf.webp';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SlidingUpPanel(
        controller: panelController,
        maxHeight: size.height * 0.75,
        minHeight: size.height * 0.55,
        parallaxEnabled: true,
        parallaxOffset: 0.2,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        panelBuilder: (scrollController) => _SlidingContent(scrollController),
        body: SafeArea(
          child: Stack(
            children: [
              // Background Image
              SizedBox(
                height: size.height * 0.6,
                width: double.infinity,
                child: Image.network(
                  thumbnail,
                  fit: BoxFit.cover,
                ),
              ),

              // Back Button
              Positioned(
                top: 16,
                left: 16,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder sliding panel content
class _SlidingContent extends StatelessWidget {
  final ScrollController scrollController;
  const _SlidingContent(this.scrollController, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          width: 40,
          height: 5,
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Itinerary Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        // Add your itinerary details here
        const Text(
          'Here you can put description, services, schedules, etc.',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}