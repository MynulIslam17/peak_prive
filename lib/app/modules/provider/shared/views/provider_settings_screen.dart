import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/custom_appbar.dart';
import '../../../../routes/app_routes.dart';

class ProviderSettingsScreen extends StatefulWidget {
  const ProviderSettingsScreen({super.key});

  @override
  State<ProviderSettingsScreen> createState() => _ProviderSettingsScreenState();
}

class _ProviderSettingsScreenState extends State<ProviderSettingsScreen> {
  final icons = Assets.icons;
  final images = Assets.images;
  Widget _tile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: enabled ? const Color(0xFFFBF3DC) : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 19,
                  color: enabled
                      ? const Color(0xFF9A7A12)
                      : AppColors.textDisabled),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyle.sub_h3_medium_14(
                  color: enabled ? AppColors.textPrimary : AppColors.textTertiary,
                ),
              ),
            ),
            if (enabled)
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textTertiary)
            else
              Text('Coming soon',
                  style: AppTextStyle.p_regular_12(
                      color: AppColors.textDisabled)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const divider = Divider(height: 1, indent: 60, color: AppColors.border);
    BoxDecoration card() => BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        );

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: const CustomAppBar(title: "Settings"),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Text('Security',
                style: AppTextStyle.p_medium_12(color: AppColors.textTertiary)),
          ),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: card(),
            child: _tile(
              icon: Icons.lock_outline_rounded,
              title: 'Change password',
              onTap: () => Get.toNamed(Routes.providerPassScreen),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
            child: Text('About',
                style: AppTextStyle.p_medium_12(color: AppColors.textTertiary)),
          ),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: card(),
            child: Column(
              children: [
                _tile(icon: Icons.shield_outlined, title: 'Privacy policy'),
                divider,
                _tile(
                    icon: Icons.description_outlined,
                    title: 'Terms & conditions'),
                divider,
                _tile(icon: Icons.info_outline_rounded, title: 'About us'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
