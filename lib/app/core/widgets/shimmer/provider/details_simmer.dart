import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// --- Widget to create a modern ShimmerPlaceholder ---
class ShimmerPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// --- Modern Shimmer Screen ---
class DetailsShimmer extends StatelessWidget {
  const DetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // Modern gradient colors for shimmer effect
    const baseColor = Color(0xFFE8EEF5); // Soft blue-gray
    const highlightColor = Color(0xFFF5F8FD); // Almost white with blue tint

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC), // Modern light background
      body: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        enabled: true,
        period: const Duration(milliseconds: 1800),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Header/Owner Section ---
              _buildOwnerShimmer(),
              const SizedBox(height: 32),

              // --- 2. Items Section ---
              _buildSectionTitle('Items'),
              const SizedBox(height: 12),
              _buildItemShimmer(),
              const SizedBox(height: 28),

              // --- 3. Pricing Section ---
              _buildPricingShimmer(),
              const SizedBox(height: 28),

              // --- 4. Contact Details Section ---
              _buildSectionTitle('Contact Details'),
              const SizedBox(height: 12),
              _buildContactDetailShimmer(),
              const SizedBox(height: 12),
              _buildContactDetailShimmer(),
              const SizedBox(height: 28),

              // --- 5. Schedule Section ---
              _buildSectionTitle('Schedule'),
              const SizedBox(height: 12),
              _buildScheduleShimmer(),
              const SizedBox(height: 12),
              _buildScheduleShimmer(),
              const SizedBox(height: 40),

              // --- 6. Action Button ---
              _buildActionButtonShimmer(),
            ],
          ),
        ),
      ),
    );
  }

  // Section Title Widget
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2C3E50),
      ),
    );
  }

  // Modern Owner Info Widget
  Widget _buildOwnerShimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar with subtle shadow
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const ShimmerPlaceholder(width: 56, height: 56, borderRadius: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              const ShimmerPlaceholder(width: 120, height: 20),
              const SizedBox(height: 8),
              // Location
              Row(
                children: [
                  const ShimmerPlaceholder(width: 18, height: 18, borderRadius: 9),
                  const SizedBox(width: 6),
                  const ShimmerPlaceholder(width: 140, height: 16),
                ],
              ),
            ],
          ),
        ),
        // Action Buttons
        Column(
          children: [
            _buildIconButton(),
            const SizedBox(height: 8),
            _buildIconButton(),
          ],
        ),
      ],
    );
  }

  // Icon Button Widget
  Widget _buildIconButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const ShimmerPlaceholder(width: 44, height: 44, borderRadius: 22),
    );
  }

  // Modern Item Widget
  Widget _buildItemShimmer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Photo
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const ShimmerPlaceholder(width: double.infinity, height: 100),
          ),
          const SizedBox(height: 10),
          // Item Name
          const ShimmerPlaceholder(width: 100, height: 16),
        ],
      ),
    );
  }

  // Modern Pricing Card
  Widget _buildPricingShimmer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Extra Charge/Hour
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const ShimmerPlaceholder(width: 100, height: 14),
                const SizedBox(height: 10),
                const ShimmerPlaceholder(width: 60, height: 26),
              ],
            ),
          ),
          // Divider
          Container(
            width: 1,
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.grey[200],
          ),
          // Total Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const ShimmerPlaceholder(width: 80, height: 14),
                const SizedBox(height: 10),
                const ShimmerPlaceholder(width: 70, height: 26),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modern Contact Detail Widget
  Widget _buildContactDetailShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const ShimmerPlaceholder(width: 24, height: 24, borderRadius: 6),
          ),
          const SizedBox(width: 12),
          const ShimmerPlaceholder(width: 80, height: 16),
          const SizedBox(width: 12),
          const Expanded(
            child: ShimmerPlaceholder(width: 100, height: 16),
          ),
        ],
      ),
    );
  }

  // Modern Schedule Widget
  Widget _buildScheduleShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const ShimmerPlaceholder(width: 24, height: 24, borderRadius: 6),
          ),
          const SizedBox(width: 12),
          const ShimmerPlaceholder(width: 140, height: 16),
          const Spacer(),
          const ShimmerPlaceholder(width: 110, height: 16),
        ],
      ),
    );
  }

  // Modern Action Button
  Widget _buildActionButtonShimmer() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}