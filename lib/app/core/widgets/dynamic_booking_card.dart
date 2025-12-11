import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ServiceInfoCard extends StatelessWidget {
  final String imageUrl;

  final String title1, value1, icon1Path;
  final String title2, value2, icon2Path;
  final String title3, value3, icon3Path;
  final String title4, value4, icon4Path;
    final VoidCallback ? onTap;

  final bool value1IsIcon;
  final bool value3IsIcon;

  const ServiceInfoCard({
    super.key,
    required this.imageUrl,
    required this.title1,
    required this.value1,
    required this.icon1Path,
    required this.title2,
    required this.value2,
    required this.icon2Path,
    required this.title3,
    required this.value3,
    required this.icon3Path,
    required this.title4,
    required this.value4,
    required this.icon4Path,
    this.value1IsIcon = false,
    this.value3IsIcon = false,
     this.onTap,
  });

  // Safe SVG loader
  Widget _svg(String path) {
    return SvgPicture.asset(
      path,
      width: 12,
      height: 12,
      colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
      placeholderBuilder: (_) => const SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(strokeWidth: 1),
      ),
    );
  }

  // Displays text or special icon
  Widget _valueWidget(String text, bool isIcon) {
    if (!isIcon) {
      return Flexible(
        child: Text(
          text,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,color: Colors.blueGrey),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    switch (text.toUpperCase()) {
      case "VIP":
        return const Icon(Icons.verified_user_outlined, size: 20, color: Colors.blue);
      case "LUNCH":
        return const Icon(Icons.restaurant_menu, size: 20);
      default:
        return Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        );
    }
  }

  Widget _infoTile(String title, String value, String icon, {bool isIcon = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _svg(icon),
            const SizedBox(width: 6),
            _valueWidget(value, isIcon),
          ],
        ),
      ],
    );
  }

  Widget _infoRow({
    required String t1,
    required String v1,
    required String i1,
    required bool isIcon1,
    required String t2,
    required String v2,
    required String i2,
    bool isIcon2 = false,
  }) {
    return Row(
      children: [
        Expanded(child: _infoTile(t1, v1, i1, isIcon: isIcon1)),
        const SizedBox(width: 12),
        Expanded(child: _infoTile(t2, v2, i2, isIcon: isIcon2)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:onTap ,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 75,
                  height: 95,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 75,
                    height: 95,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Right info section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(
                      t1: title1,
                      v1: value1,
                      i1: icon1Path,
                      isIcon1: value1IsIcon,
                      t2: title2,
                      v2: value2,
                      i2: icon2Path,
                    ),
                    const SizedBox(height: 16),
                    _infoRow(
                      t1: title3,
                      v1: value3,
                      i1: icon3Path,
                      isIcon1: value3IsIcon,
                      t2: title4,
                      v2: value4,
                      i2: icon4Path,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
