import 'package:flutter/material.dart';

class DeleteDialogService {
  static void show({
    required BuildContext context,
    String title = "Delete",
    String message = "Are you sure you want to delete this item?",
    String deleteLabel = "Delete",
    String cancelLabel = "Cancel",
    Color themeColor = const Color(0xFFD4AF38),
    required Future<bool> Function() onDelete, // delete callback from outside
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.delete_outline_rounded, color: themeColor, size: 32),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    // Message
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 28),

                    // Buttons
                    Row(
                      children: [
                        // Cancel
                        Expanded(
                          child: TextButton(
                            onPressed: isLoading ? null : () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Text(cancelLabel, style: TextStyle(color: Colors.grey[700])),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Delete
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                              setState(() => isLoading = true);

                              // Call the delete function from outside
                              bool success = await onDelete();

                              if (success) {
                                Navigator.pop(context); // close dialog
                              } else {
                                setState(() => isLoading = false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : Text(deleteLabel, style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
