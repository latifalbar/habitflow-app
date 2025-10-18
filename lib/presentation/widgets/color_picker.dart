import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class ColorPickerWidget extends StatefulWidget {
  final Color? selectedColor;
  final Function(Color) onColorSelected;

  const ColorPickerWidget({
    super.key,
    this.selectedColor,
    required this.onColorSelected,
  });

  @override
  State<ColorPickerWidget> createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  Color? _selectedColor;

  // Beautiful preset colors for habits
  static const List<Color> _presetColors = [
    AppColors.oceanPrimary,
    AppColors.sunsetPrimary,
    AppColors.forestPrimary,
    AppColors.lavenderPrimary,
    AppColors.coralPrimary,
    AppColors.mintPrimary,
    AppColors.rosePrimary,
    AppColors.skyPrimary,
    AppColors.goldPrimary,
    AppColors.plumPrimary,
    AppColors.tealPrimary,
    AppColors.amberPrimary,
    AppColors.indigoPrimary,
    AppColors.emeraldPrimary,
    AppColors.pinkPrimary,
    AppColors.cyanPrimary,
    AppColors.orangePrimary,
    AppColors.purplePrimary,
    AppColors.limePrimary,
    AppColors.redPrimary,
    AppColors.bluePrimary,
    AppColors.greenPrimary,
    AppColors.yellowPrimary,
    AppColors.brownPrimary,
    AppColors.greyPrimary,
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.selectedColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        
        // Color grid
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _presetColors.map((color) {
            final isSelected = _selectedColor == color;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
                widget.onColorSelected(color);
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected 
                        ? Colors.white
                        : AppColors.grey300,
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                  ],
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
        
        if (_selectedColor != null) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: _selectedColor!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(
                color: _selectedColor!.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Selected: ${_getColorName(_selectedColor!)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _selectedColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _getColorName(Color color) {
    if (color == AppColors.oceanPrimary) return 'Ocean';
    if (color == AppColors.sunsetPrimary) return 'Sunset';
    if (color == AppColors.forestPrimary) return 'Forest';
    if (color == AppColors.lavenderPrimary) return 'Lavender';
    if (color == AppColors.coralPrimary) return 'Coral';
    if (color == AppColors.mintPrimary) return 'Mint';
    if (color == AppColors.rosePrimary) return 'Rose';
    if (color == AppColors.skyPrimary) return 'Sky';
    if (color == AppColors.goldPrimary) return 'Gold';
    if (color == AppColors.plumPrimary) return 'Plum';
    if (color == AppColors.tealPrimary) return 'Teal';
    if (color == AppColors.amberPrimary) return 'Amber';
    if (color == AppColors.indigoPrimary) return 'Indigo';
    if (color == AppColors.emeraldPrimary) return 'Emerald';
    if (color == AppColors.pinkPrimary) return 'Pink';
    if (color == AppColors.cyanPrimary) return 'Cyan';
    if (color == AppColors.orangePrimary) return 'Orange';
    if (color == AppColors.purplePrimary) return 'Purple';
    if (color == AppColors.limePrimary) return 'Lime';
    if (color == AppColors.redPrimary) return 'Red';
    if (color == AppColors.bluePrimary) return 'Blue';
    if (color == AppColors.greenPrimary) return 'Green';
    if (color == AppColors.yellowPrimary) return 'Yellow';
    if (color == AppColors.brownPrimary) return 'Brown';
    if (color == AppColors.greyPrimary) return 'Grey';
    return 'Custom';
  }
}
