// ============================================
// IMAGE PICKER DIALOG SERVICE
// ============================================
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerDialogService {
  static Future<void> show({
    required BuildContext context,
    required Function(ImageSource) onImageSourceSelected,
    String title = "Select Image",
    String subtitle = "Choose from gallery or take a photo",
    String galleryLabel = "Gallery",
    String gallerySubtitle = "Choose from your photos",
    String cameraLabel = "Camera",
    String cameraSubtitle = "Take a new photo",
    String cancelLabel = "Cancel",
    Color primaryColor = const Color(0xFF2196F3),
    Color galleryIconColor = Colors.blue,
    Color cameraIconColor = Colors.orange,
  }) {
    FocusManager.instance.primaryFocus?.unfocus();
    return showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.grey.shade50],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.image_search,
                        color: primaryColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildImagePickerOption(
                      icon: Icons.photo_library_rounded,
                      title: galleryLabel,
                      subtitle: gallerySubtitle,
                      onTap: () {
                        Navigator.pop(context);
                        onImageSourceSelected(ImageSource.gallery);
                      },
                      color: galleryIconColor,
                    ),
                    const SizedBox(height: 12),
                    _buildImagePickerOption(
                      icon: Icons.camera_alt_rounded,
                      title: cameraLabel,
                      subtitle: cameraSubtitle,
                      onTap: () {
                        Navigator.pop(context);
                        onImageSourceSelected(ImageSource.camera);
                      },
                      color: cameraIconColor,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          cancelLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildImagePickerOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}