import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/habit.dart';

class FrequencySelector extends StatefulWidget {
  final HabitFrequency? selectedFrequency;
  final List<int>? customDays;
  final int? timesPerWeek;
  final int? everyXDays;
  final Function(HabitFrequency) onFrequencyChanged;
  final Function(List<int>)? onCustomDaysChanged;
  final Function(int)? onTimesPerWeekChanged;
  final Function(int)? onEveryXDaysChanged;

  const FrequencySelector({
    super.key,
    this.selectedFrequency,
    this.customDays,
    this.timesPerWeek,
    this.everyXDays,
    required this.onFrequencyChanged,
    this.onCustomDaysChanged,
    this.onTimesPerWeekChanged,
    this.onEveryXDaysChanged,
  });

  @override
  State<FrequencySelector> createState() => _FrequencySelectorState();
}

class _FrequencySelectorState extends State<FrequencySelector> {
  HabitFrequency? _selectedFrequency;
  List<int> _customDays = [];
  int _timesPerWeek = 3;
  int _everyXDays = 2;

  final List<String> _dayNames = [
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
  ];

  @override
  void initState() {
    super.initState();
    _selectedFrequency = widget.selectedFrequency;
    _customDays = widget.customDays ?? [];
    _timesPerWeek = widget.timesPerWeek ?? 3;
    _everyXDays = widget.everyXDays ?? 2;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequency',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        
        // Frequency options
        ...HabitFrequency.values.map((frequency) {
          return _buildFrequencyOption(frequency);
        }).toList(),
        
        const SizedBox(height: AppSpacing.md),
        
        // Conditional inputs based on selected frequency
        if (_selectedFrequency == HabitFrequency.customDays) ...[
          _buildCustomDaysSelector(),
        ] else if (_selectedFrequency == HabitFrequency.timesPerWeek) ...[
          _buildTimesPerWeekSelector(),
        ] else if (_selectedFrequency == HabitFrequency.everyXDays) ...[
          _buildEveryXDaysSelector(),
        ],
      ],
    );
  }

  Widget _buildFrequencyOption(HabitFrequency frequency) {
    final isSelected = _selectedFrequency == frequency;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFrequency = frequency;
        });
        widget.onFrequencyChanged(frequency);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.oceanPrimary.withOpacity(0.1)
              : AppColors.grey50,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected 
                ? AppColors.oceanPrimary
                : AppColors.grey200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.oceanPrimary : AppColors.grey400,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getFrequencyTitle(frequency),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.oceanPrimary : AppColors.grey800,
                    ),
                  ),
                  Text(
                    _getFrequencyDescription(frequency),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDaysSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Days',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: List.generate(7, (index) {
            final isSelected = _customDays.contains(index);
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _customDays.remove(index);
                  } else {
                    _customDays.add(index);
                  }
                });
                widget.onCustomDaysChanged?.call(_customDays);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.oceanPrimary
                      : AppColors.grey100,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: isSelected 
                        ? AppColors.oceanPrimary
                        : AppColors.grey300,
                  ),
                ),
                child: Center(
                  child: Text(
                    _dayNames[index],
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected ? Colors.white : AppColors.grey600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTimesPerWeekSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Times per Week',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            IconButton(
              onPressed: _timesPerWeek > 1 ? () {
                setState(() {
                  _timesPerWeek--;
                });
                widget.onTimesPerWeekChanged?.call(_timesPerWeek);
              } : null,
              icon: const Icon(Icons.remove),
            ),
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey300),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                '$_timesPerWeek',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              onPressed: _timesPerWeek < 7 ? () {
                setState(() {
                  _timesPerWeek++;
                });
                widget.onTimesPerWeekChanged?.call(_timesPerWeek);
              } : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEveryXDaysSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Every X Days',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            IconButton(
              onPressed: _everyXDays > 1 ? () {
                setState(() {
                  _everyXDays--;
                });
                widget.onEveryXDaysChanged?.call(_everyXDays);
              } : null,
              icon: const Icon(Icons.remove),
            ),
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey300),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                '$_everyXDays',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              onPressed: _everyXDays < 30 ? () {
                setState(() {
                  _everyXDays++;
                });
                widget.onEveryXDaysChanged?.call(_everyXDays);
              } : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  String _getFrequencyTitle(HabitFrequency frequency) {
    switch (frequency) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.customDays:
        return 'Custom Days';
      case HabitFrequency.timesPerWeek:
        return 'Times per Week';
      case HabitFrequency.everyXDays:
        return 'Every X Days';
    }
  }

  String _getFrequencyDescription(HabitFrequency frequency) {
    switch (frequency) {
      case HabitFrequency.daily:
        return 'Every day';
      case HabitFrequency.customDays:
        return 'Select specific days';
      case HabitFrequency.timesPerWeek:
        return 'Flexible weekly schedule';
      case HabitFrequency.everyXDays:
        return 'Regular intervals';
    }
  }
}
