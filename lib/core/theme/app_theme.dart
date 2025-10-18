import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';

class AppTheme {
  // Light Theme
  static ThemeData lightTheme({String themeName = 'ocean'}) {
    final primaryColor = AppColors.getPrimaryColor(themeName);
    final secondaryColor = AppColors.getSecondaryColor(themeName);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: AppColors.lightSurface,
        background: AppColors.lightBackground,
        error: AppColors.error,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.lightBackground,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: AppSpacing.appBarElevation,
        centerTitle: true,
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTextStyles.h5.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.lightTextPrimary,
        ),
      ),

      // Text Theme
      textTheme: AppTextStyles.lightTextTheme,

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.lightTextPrimary,
        size: AppSpacing.iconMd,
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: AppSpacing.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        ),
        color: AppColors.lightSurface,
        margin: const EdgeInsets.all(AppSpacing.sm),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.inputPaddingHorizontal,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(
            color: primaryColor,
            width: AppSpacing.focusedBorderWidth,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppSpacing.defaultBorderWidth,
          ),
        ),
        labelStyle: AppTextStyles.bodyMedium,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.grey500,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: primaryColor,
        unselectedItemColor: AppColors.grey500,
        type: BottomNavigationBarType.fixed,
        elevation: AppSpacing.bottomNavElevation,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
      ),

      // Navigation Bar Theme (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: primaryColor.withOpacity(0.1),
        labelTextStyle: WidgetStateProperty.all(AppTextStyles.labelSmall),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primaryColor);
          }
          return const IconThemeData(color: AppColors.grey500);
        }),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.grey100,
        deleteIconColor: AppColors.grey600,
        labelStyle: AppTextStyles.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.lightSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.dialogBorderRadius),
        ),
        titleTextStyle: AppTextStyles.h5.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.lightTextSecondary,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.bottomSheetBorderRadius),
          ),
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.grey800,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.snackbarBorderRadius),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: AppSpacing.dividerThickness,
        space: AppSpacing.md,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        circularTrackColor: AppColors.grey200,
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: AppColors.grey300,
        thumbColor: primaryColor,
        overlayColor: primaryColor.withOpacity(0.1),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return AppColors.grey400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return AppColors.grey300;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return AppColors.grey400;
        }),
      ),
    );
  }

  // Dark Theme
  static ThemeData darkTheme({String themeName = 'ocean'}) {
    final primaryColor = AppColors.getPrimaryColor(themeName);
    final secondaryColor = AppColors.getSecondaryColor(themeName);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: AppColors.darkSurface,
        background: AppColors.darkBackground,
        error: AppColors.error,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.darkBackground,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: AppSpacing.appBarElevation,
        centerTitle: true,
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTextStyles.h5.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.darkTextPrimary,
        ),
      ),

      // Text Theme
      textTheme: AppTextStyles.darkTextTheme,

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.darkTextPrimary,
        size: AppSpacing.iconMd,
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: AppSpacing.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        ),
        color: AppColors.darkSurface,
        margin: const EdgeInsets.all(AppSpacing.sm),
      ),

      // Similar configuration as light theme but with dark colors...
      // (Abbreviated for brevity - same structure as light theme)

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey800,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.inputPaddingHorizontal,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(
            color: primaryColor,
            width: AppSpacing.focusedBorderWidth,
          ),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.grey500,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: primaryColor,
        unselectedItemColor: AppColors.grey500,
        type: BottomNavigationBarType.fixed,
        elevation: AppSpacing.bottomNavElevation,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
      ),

      dialogTheme: DialogTheme(
        backgroundColor: AppColors.darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.dialogBorderRadius),
        ),
        titleTextStyle: AppTextStyles.h5.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextSecondary,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.grey200,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.grey900,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.snackbarBorderRadius),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: AppSpacing.dividerThickness,
        space: AppSpacing.md,
      ),
    );
  }

  // Helper method to get theme by name
  static ThemeData getThemeByName(String themeName, bool isDark) {
    return isDark ? darkTheme(themeName: themeName) : lightTheme(themeName: themeName);
  }
}
