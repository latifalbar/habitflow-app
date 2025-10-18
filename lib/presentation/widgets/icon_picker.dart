import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class IconPickerBottomSheet extends StatefulWidget {
  final String? selectedIcon;
  final Function(String) onIconSelected;

  const IconPickerBottomSheet({
    super.key,
    this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  State<IconPickerBottomSheet> createState() => _IconPickerBottomSheetState();
}

class _IconPickerBottomSheetState extends State<IconPickerBottomSheet> {
  String _searchQuery = '';
  String? _selectedIcon;

  // Curated list of icons for habits
  static const List<IconData> _habitIcons = [
    Icons.fitness_center,
    Icons.water_drop,
    Icons.book,
    Icons.self_improvement,
    Icons.bedtime,
    Icons.wb_sunny,
    Icons.restaurant,
    Icons.coffee,
    Icons.work,
    Icons.school,
    Icons.home,
    Icons.directions_walk,
    Icons.directions_run,
    Icons.pool,
    Icons.bike_scooter,
    Icons.psychology,
    Icons.volunteer_activism,
    Icons.music_note,
    Icons.palette,
    Icons.camera_alt,
    Icons.games,
    Icons.movie,
    Icons.shopping_cart,
    Icons.cleaning_services,
    Icons.pets,
    Icons.family_restroom,
    Icons.favorite,
    Icons.health_and_safety,
    Icons.eco,
    Icons.star,
    Icons.celebration,
    Icons.travel_explore,
    Icons.language,
    Icons.code,
    Icons.brush,
    Icons.sports_tennis,
    Icons.sports_basketball,
    Icons.sports_soccer,
    Icons.sports_volleyball,
    Icons.sports_esports,
    Icons.sports_golf,
    Icons.sports_motorsports,
    Icons.sports_handball,
    Icons.sports_kabaddi,
    Icons.sports_mma,
    Icons.sports_rugby,
    Icons.sports_cricket,
    Icons.sports_baseball,
    Icons.sports_hockey,
    Icons.sports_football,
    Icons.sports,
    Icons.sports_gymnastics,
  ];

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.selectedIcon;
  }

  List<IconData> get _filteredIcons {
    if (_searchQuery.isEmpty) return _habitIcons;
    
    // Simple search by icon name (you could enhance this with icon names mapping)
    return _habitIcons.where((icon) {
      final iconName = icon.toString().toLowerCase();
      return iconName.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Text(
                  'Choose Icon',
                  style: AppTextStyles.h5,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: _selectedIcon != null
                      ? () {
                          widget.onIconSelected(_selectedIcon!);
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search icons...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide(color: AppColors.grey300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide(color: AppColors.oceanPrimary),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Icons grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
              ),
              itemCount: _filteredIcons.length,
              itemBuilder: (context, index) {
                final icon = _filteredIcons[index];
                final isSelected = _selectedIcon == icon.toString();
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = icon.toString();
                    });
                  },
                  child: Container(
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
                    child: Icon(
                      icon,
                      color: isSelected 
                          ? AppColors.oceanPrimary
                          : AppColors.grey600,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to show icon picker
Future<String?> showIconPicker(
  BuildContext context, {
  String? selectedIcon,
}) async {
  String? result;
  
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => IconPickerBottomSheet(
      selectedIcon: selectedIcon,
      onIconSelected: (icon) {
        result = icon;
      },
    ),
  );
  
  return result;
}
