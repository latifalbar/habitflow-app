import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Social sign in button widget
class SocialSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String text;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  
  const SocialSignInButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.text,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.surface,
          foregroundColor: textColor ?? AppColors.textPrimary,
          side: BorderSide(
            color: AppColors.grey300,
            width: 1,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? AppColors.textPrimary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: iconColor ?? AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: textColor ?? AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
