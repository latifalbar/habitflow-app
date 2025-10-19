import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import 'package:intl/intl.dart';

class DateRangePickerButton extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onTap;

  const DateRangePickerButton({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.oceanPrimary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: AppColors.oceanPrimary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: AppColors.oceanPrimary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              _formatDateRange(),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.oceanPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: AppColors.oceanPrimary,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateRange() {
    if (startDate == null || endDate == null) {
      return 'Select date range';
    }
    
    final dateFormat = DateFormat('MMM d');
    final start = dateFormat.format(startDate!);
    final end = dateFormat.format(endDate!);
    
    return '$start - $end';
  }
}
