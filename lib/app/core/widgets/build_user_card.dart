import 'package:flutter/material.dart';

class ModernUserCard extends StatelessWidget {
  final String? fullName;
  final String? profileUrl;
  final String? serviceArea;
  final VoidCallback? onMessageTap;
  final VoidCallback? onCallTap;

  const ModernUserCard({
    Key? key,
    this.fullName,
    this.profileUrl,
    this.serviceArea,
    this.onMessageTap,
    this.onCallTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.1),
            const Color(0xFF8B5CF6).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 14),
          Expanded(child: _buildUserInfo()),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final hasImage = (profileUrl ?? '').isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 12,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 32,
        backgroundColor: Colors.grey.shade300,
        backgroundImage: hasImage ? NetworkImage(profileUrl!) : null,
        child: !hasImage
            ? const Icon(Icons.person, size: 32, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fullName ?? 'N/A',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 14,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                serviceArea ?? 'N/A',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionIconButton(Icons.message_outlined, onMessageTap),
        const SizedBox(width: 8),
        _buildActionIconButton(Icons.call_outlined, onCallTap),
      ],
    );
  }

  Widget _buildActionIconButton(IconData icon, VoidCallback? onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF6366F1)),
      ),
    );
  }
}
