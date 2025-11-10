import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../gen/assets.gen.dart';
import '../constants/text-style.dart';

class ProfileFieldBox extends StatelessWidget {
  const ProfileFieldBox({
    super.key,
    required this.leadingIcon,
    this.actionIcons,
    required this.onTap,
    required this.title,
    this.borderColor,
    this.isLogout = false,
  });

  final SvgGenImage leadingIcon;
  final SvgGenImage? actionIcons;
  final VoidCallback onTap;
  final String title;
  final Color? borderColor;
  final bool isLogout;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: borderColor ?? Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment:
            isLogout ? MainAxisAlignment.center : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              leadingIcon.svg(width: 17, height: 17),
              SizedBox(width: isLogout ? 10 : 8),

              // Expanded title
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyle.sub_h3_regular_14().copyWith(
                    color: isLogout ? Colors.red : Colors.black,
                    fontWeight: isLogout ? FontWeight.w600 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),

              // Only show action icon for normal items
              if (!isLogout && actionIcons != null)
                InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: actionIcons!.svg(),
                  ),
                ),
            ],
          ),

        ),
      ),
    );
  }
}
