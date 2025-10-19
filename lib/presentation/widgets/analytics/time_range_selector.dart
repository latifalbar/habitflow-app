import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/analytics_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../analytics/date_range_picker_button.dart';
import '../../providers/analytics_provider.dart';

class TimeRangeSelector extends ConsumerWidget {
  const TimeRangeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);
    final analyticsNotifier = ref.watch(analyticsProvider.notifier);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          // Time range tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildTab(
                  context,
                  '7D',
                  AnalyticsTimeRange.last7Days,
                  analytics.timeRange,
                  () => analyticsNotifier.setTimeRange(AnalyticsTimeRange.last7Days),
                ),
                _buildTab(
                  context,
                  '30D',
                  AnalyticsTimeRange.last30Days,
                  analytics.timeRange,
                  () => analyticsNotifier.setTimeRange(AnalyticsTimeRange.last30Days),
                ),
                _buildTab(
                  context,
                  '90D',
                  AnalyticsTimeRange.last90Days,
                  analytics.timeRange,
                  () => analyticsNotifier.setTimeRange(AnalyticsTimeRange.last90Days),
                ),
                _buildTab(
                  context,
                  '1Y',
                  AnalyticsTimeRange.lastYear,
                  analytics.timeRange,
                  () => analyticsNotifier.setTimeRange(AnalyticsTimeRange.lastYear),
                ),
                _buildTab(
                  context,
                  'All',
                  AnalyticsTimeRange.allTime,
                  analytics.timeRange,
                  () => analyticsNotifier.setTimeRange(AnalyticsTimeRange.allTime),
                ),
                _buildTab(
                  context,
                  'Custom',
                  AnalyticsTimeRange.custom,
                  analytics.timeRange,
                  () => _showCustomDateRangeDialog(context, analyticsNotifier, ref),
                ),
              ],
            ),
          ),
          
          // Custom date range display
          if (analytics.timeRange == AnalyticsTimeRange.custom) ...[
            const SizedBox(height: AppSpacing.sm),
            DateRangePickerButton(
              startDate: analytics.customStartDate,
              endDate: analytics.customEndDate,
              onTap: () => _showCustomDateRangeDialog(context, analyticsNotifier, ref),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    String label,
    AnalyticsTimeRange range,
    AnalyticsTimeRange selectedRange,
    VoidCallback onTap,
  ) {
    final isSelected = range == selectedRange;
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.oceanPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected ? [
              BoxShadow(
                color: AppColors.oceanPrimary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isSelected ? Colors.white : AppColors.grey600,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  void _showCustomDateRangeDialog(BuildContext context, AnalyticsNotifier notifier, WidgetRef ref) {
    final analytics = ref.read(analyticsProvider);
    showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: analytics.customStartDate ?? DateTime.now().subtract(const Duration(days: 29)),
        end: analytics.customEndDate ?? DateTime.now(),
      ),
    ).then((dateRange) {
      if (dateRange != null) {
        notifier.setTimeRange(
          AnalyticsTimeRange.custom,
          customStart: dateRange.start,
          customEnd: dateRange.end,
        );
      }
    });
  }
}
