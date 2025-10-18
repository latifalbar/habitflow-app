import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/habit.dart';

class GoalTypeSelector extends StatefulWidget {
  final HabitGoalType? selectedGoalType;
  final double? goalValue;
  final String? goalUnit;
  final Function(HabitGoalType) onGoalTypeChanged;
  final Function(double)? onGoalValueChanged;
  final Function(String)? onGoalUnitChanged;

  const GoalTypeSelector({
    super.key,
    this.selectedGoalType,
    this.goalValue,
    this.goalUnit,
    required this.onGoalTypeChanged,
    this.onGoalValueChanged,
    this.onGoalUnitChanged,
  });

  @override
  State<GoalTypeSelector> createState() => _GoalTypeSelectorState();
}

class _GoalTypeSelectorState extends State<GoalTypeSelector> {
  HabitGoalType? _selectedGoalType;
  double _goalValue = 1.0;
  String _goalUnit = 'times';
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  final List<String> _commonUnits = [
    'times', 'minutes', 'hours', 'pages', 'glasses', 'steps', 'calories', 'km', 'miles'
  ];

  @override
  void initState() {
    super.initState();
    _selectedGoalType = widget.selectedGoalType;
    _goalValue = widget.goalValue ?? 1.0;
    _goalUnit = widget.goalUnit ?? 'times';
    _valueController.text = _goalValue.toString();
    _unitController.text = _goalUnit;
  }

  @override
  void dispose() {
    _valueController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goal Type',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        
        // Goal type options
        ...HabitGoalType.values.map((goalType) {
          return _buildGoalTypeOption(goalType);
        }).toList(),
        
        const SizedBox(height: AppSpacing.md),
        
        // Conditional inputs based on selected goal type
        if (_selectedGoalType == HabitGoalType.quantifiable) ...[
          _buildQuantifiableInputs(),
        ] else if (_selectedGoalType == HabitGoalType.timeBased) ...[
          _buildTimeBasedInputs(),
        ],
      ],
    );
  }

  Widget _buildGoalTypeOption(HabitGoalType goalType) {
    final isSelected = _selectedGoalType == goalType;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGoalType = goalType;
        });
        widget.onGoalTypeChanged(goalType);
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
                    _getGoalTypeTitle(goalType),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.oceanPrimary : AppColors.grey800,
                    ),
                  ),
                  Text(
                    _getGoalTypeDescription(goalType),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _getGoalTypeIcon(goalType),
              color: isSelected ? AppColors.oceanPrimary : AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantifiableInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goal Details',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Value',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
                onChanged: (value) {
                  final parsedValue = double.tryParse(value);
                  if (parsedValue != null && parsedValue > 0) {
                    _goalValue = parsedValue;
                    widget.onGoalValueChanged?.call(_goalValue);
                  }
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                value: _goalUnit,
                decoration: InputDecoration(
                  labelText: 'Unit',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
                items: _commonUnits.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _goalUnit = value;
                    });
                    widget.onGoalUnitChanged?.call(_goalUnit);
                  }
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // Custom unit input
        TextField(
          controller: _unitController,
          decoration: InputDecoration(
            labelText: 'Custom Unit (optional)',
            hintText: 'e.g., pages, glasses, steps',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              setState(() {
                _goalUnit = value;
              });
              widget.onGoalUnitChanged?.call(_goalUnit);
            }
          },
        ),
      ],
    );
  }

  Widget _buildTimeBasedInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time Goal',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Minutes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
                onChanged: (value) {
                  final parsedValue = double.tryParse(value);
                  if (parsedValue != null && parsedValue > 0) {
                    _goalValue = parsedValue;
                    widget.onGoalValueChanged?.call(_goalValue);
                  }
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                'minutes',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // Time preview
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.oceanPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Text(
            _getTimePreview(_goalValue),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.oceanPrimary,
            ),
          ),
        ),
      ],
    );
  }

  String _getGoalTypeTitle(HabitGoalType goalType) {
    switch (goalType) {
      case HabitGoalType.simple:
        return 'Simple';
      case HabitGoalType.quantifiable:
        return 'Quantifiable';
      case HabitGoalType.timeBased:
        return 'Time-based';
    }
  }

  String _getGoalTypeDescription(HabitGoalType goalType) {
    switch (goalType) {
      case HabitGoalType.simple:
        return 'Just complete the habit';
      case HabitGoalType.quantifiable:
        return 'Set a specific amount';
      case HabitGoalType.timeBased:
        return 'Spend a certain amount of time';
    }
  }

  IconData _getGoalTypeIcon(HabitGoalType goalType) {
    switch (goalType) {
      case HabitGoalType.simple:
        return Icons.check_circle_outline;
      case HabitGoalType.quantifiable:
        return Icons.straighten;
      case HabitGoalType.timeBased:
        return Icons.timer;
    }
  }

  String _getTimePreview(double minutes) {
    final hours = (minutes / 60).floor();
    final remainingMinutes = (minutes % 60).round();
    
    if (hours > 0) {
      return remainingMinutes > 0 
          ? 'Goal: ${hours}h ${remainingMinutes}m'
          : 'Goal: ${hours}h';
    }
    return 'Goal: ${minutes.round()}m';
  }
}
