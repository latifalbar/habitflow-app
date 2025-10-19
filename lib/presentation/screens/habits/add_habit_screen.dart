import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/habit.dart';
import '../../providers/habits_provider.dart';
import '../../providers/garden_provider.dart';
import '../../widgets/icon_picker.dart';
import '../../widgets/color_picker.dart';
import '../../widgets/frequency_selector.dart';
import '../../widgets/goal_type_selector.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  final Habit? habit; // For edit mode

  const AddHabitScreen({super.key, this.habit});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  // Form state
  String? _selectedIcon;
  Color _selectedColor = AppColors.oceanPrimary;
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  HabitGoalType _selectedGoalType = HabitGoalType.simple;
  List<int> _customDays = [];
  int _timesPerWeek = 3;
  int _everyXDays = 2;
  double _goalValue = 1.0;
  String _goalUnit = 'times';

  bool _isLoading = false;

  final List<String> _categories = [
    'Health & Fitness',
    'Learning & Education',
    'Work & Productivity',
    'Personal Care',
    'Social & Relationships',
    'Hobbies & Interests',
    'Spiritual & Mindfulness',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      // Load existing habit data for edit mode
      _nameController.text = widget.habit!.name;
      _descriptionController.text = widget.habit!.description;
      _categoryController.text = widget.habit!.category;
      _selectedIcon = widget.habit!.icon;
      _selectedColor = widget.habit!.color;
      _selectedFrequency = widget.habit!.frequency;
      _selectedGoalType = widget.habit!.goalType;
      _customDays = List.from(widget.habit!.customDays);
      _timesPerWeek = widget.habit!.timesPerWeek;
      _everyXDays = widget.habit!.everyXDays;
      _goalValue = widget.habit!.goalValue ?? 1.0;
      _goalUnit = widget.habit!.goalUnit ?? 'times';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.habit != null ? 'Edit Habit' : 'Add New Habit',
          style: AppTextStyles.h5,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveHabit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          widget.habit != null ? 'Update' : 'Save',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.oceanPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: AppSpacing.md),
              
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Habit Name *',
                  hintText: 'e.g., Drink Water, Read Books',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a habit name';
                  }
                  if (value.trim().length < 2) {
                    return 'Habit name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Description field
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Describe your habit...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Category field
              DropdownButtonFormField<String>(
                value: _categoryController.text.isNotEmpty 
                    ? _categoryController.text 
                    : _categories.first,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _categoryController.text = value;
                  }
                },
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Visual Section
              _buildSectionHeader('Visual'),
              const SizedBox(height: AppSpacing.md),
              
              // Icon picker
              _buildIconSelector(),
              
              const SizedBox(height: AppSpacing.md),
              
              // Color picker
              ColorPickerWidget(
                selectedColor: _selectedColor,
                onColorSelected: (color) {
                  setState(() {
                    _selectedColor = color;
                  });
                },
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Frequency Section
              _buildSectionHeader('Frequency'),
              const SizedBox(height: AppSpacing.md),
              
              FrequencySelector(
                selectedFrequency: _selectedFrequency,
                customDays: _customDays,
                timesPerWeek: _timesPerWeek,
                everyXDays: _everyXDays,
                onFrequencyChanged: (frequency) {
                  setState(() {
                    _selectedFrequency = frequency;
                  });
                },
                onCustomDaysChanged: (days) {
                  setState(() {
                    _customDays = days;
                  });
                },
                onTimesPerWeekChanged: (times) {
                  setState(() {
                    _timesPerWeek = times;
                  });
                },
                onEveryXDaysChanged: (days) {
                  setState(() {
                    _everyXDays = days;
                  });
                },
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Goal Section
              _buildSectionHeader('Goal'),
              const SizedBox(height: AppSpacing.md),
              
              GoalTypeSelector(
                selectedGoalType: _selectedGoalType,
                goalValue: _goalValue,
                goalUnit: _goalUnit,
                onGoalTypeChanged: (goalType) {
                  setState(() {
                    _selectedGoalType = goalType;
                  });
                },
                onGoalValueChanged: (value) {
                  setState(() {
                    _goalValue = value;
                  });
                },
                onGoalUnitChanged: (unit) {
                  setState(() {
                    _goalUnit = unit;
                  });
                },
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.oceanPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          widget.habit != null ? 'Update Habit' : 'Create Habit',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.h6.copyWith(
        color: AppColors.grey700,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Icon',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        
        GestureDetector(
          onTap: _selectIcon,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey300),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _selectedColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    _selectedIcon != null 
                        ? _getIconData(_selectedIcon!)
                        : Icons.add,
                    color: _selectedColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    _selectedIcon != null 
                        ? 'Icon selected'
                        : 'Tap to select icon',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _selectedIcon != null 
                          ? AppColors.grey800
                          : AppColors.grey500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.grey400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectIcon() async {
    final selectedIcon = await showIconPicker(
      context,
      selectedIcon: _selectedIcon,
    );
    
    if (selectedIcon != null) {
      setState(() {
        _selectedIcon = selectedIcon;
      });
    }
  }

  IconData _getIconData(String iconString) {
    // This should match the icon mapping in HabitCard
    switch (iconString.toLowerCase()) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'water_drop':
        return Icons.water_drop;
      case 'book':
        return Icons.book;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'bedtime':
        return Icons.bedtime;
      case 'wake':
        return Icons.wb_sunny;
      case 'restaurant':
        return Icons.restaurant;
      case 'coffee':
        return Icons.coffee;
      case 'work':
        return Icons.work;
      case 'school':
        return Icons.school;
      case 'home':
        return Icons.home;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'directions_run':
        return Icons.directions_run;
      case 'pool':
        return Icons.pool;
      case 'bike_scooter':
        return Icons.bike_scooter;
      case 'psychology':
        return Icons.psychology;
      case 'volunteer_activism':
        return Icons.volunteer_activism;
      case 'music_note':
        return Icons.music_note;
      case 'palette':
        return Icons.palette;
      case 'camera_alt':
        return Icons.camera_alt;
      case 'games':
        return Icons.games;
      case 'movie':
        return Icons.movie;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'pets':
        return Icons.pets;
      case 'family_restroom':
        return Icons.family_restroom;
      case 'favorite':
        return Icons.favorite;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'eco':
        return Icons.eco;
      case 'star':
        return Icons.star;
      case 'celebration':
        return Icons.celebration;
      case 'travel_explore':
        return Icons.travel_explore;
      case 'language':
        return Icons.language;
      case 'code':
        return Icons.code;
      case 'brush':
        return Icons.brush;
      default:
        return Icons.check_circle_outline;
    }
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedIcon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an icon for your habit'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(habitRepositoryProvider);
      
      final habit = Habit(
        id: widget.habit?.id ?? repository.generateId(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        icon: _selectedIcon!,
        color: _selectedColor,
        frequency: _selectedFrequency,
        goalType: _selectedGoalType,
        goalValue: _selectedGoalType != HabitGoalType.simple ? _goalValue : null,
        goalUnit: _selectedGoalType == HabitGoalType.quantifiable ? _goalUnit : null,
        customDays: _customDays,
        timesPerWeek: _timesPerWeek,
        everyXDays: _everyXDays,
        createdAt: widget.habit?.createdAt ?? DateTime.now(),
        category: _categoryController.text.isNotEmpty 
            ? _categoryController.text 
            : _categories.first,
        isArchived: widget.habit?.isArchived ?? false,
        sortOrder: widget.habit?.sortOrder ?? 0,
        metadata: widget.habit?.metadata ?? {},
      );

      if (widget.habit != null) {
        await ref.read(habitsProvider.notifier).updateHabit(habit);
      } else {
        await ref.read(habitsProvider.notifier).addHabit(habit);
        
        // Auto-plant seed in garden for new habits
        try {
          final garden = ref.read(gardenProvider).value;
          if (garden != null) {
            final emptyPosition = garden.getFirstEmptyPosition();
            if (emptyPosition != null) {
              await ref.read(gardenProvider.notifier).plantSeed(habit, emptyPosition);
            }
          }
        } catch (e) {
          // Garden planting failed, but don't block habit creation
          print('Failed to plant seed in garden: $e');
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.habit != null 
                  ? 'Habit "${habit.name}" updated successfully!'
                  : 'Habit "${habit.name}" created successfully! 🌱'
            ),
            backgroundColor: AppColors.greenPrimary,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating habit: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
