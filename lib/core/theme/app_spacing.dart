class AppSpacing {
  // Base spacing unit (8px)
  static const double base = 8.0;

  // Standard spacing values
  static const double xs = 4.0; // 0.5x
  static const double sm = 8.0; // 1x
  static const double md = 16.0; // 2x
  static const double lg = 24.0; // 3x
  static const double xl = 32.0; // 4x
  static const double xxl = 48.0; // 6x
  static const double xxxl = 64.0; // 8x

  // Named spacing for specific uses
  static const double screenPadding = md;
  static const double cardPadding = md;
  static const double listItemPadding = md;
  static const double sectionSpacing = lg;
  static const double componentSpacing = sm;

  // Icon sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  static const double iconXxl = 64.0;

  // Button sizes
  static const double buttonHeightSm = 32.0;
  static const double buttonHeightMd = 44.0;
  static const double buttonHeightLg = 56.0;
  static const double buttonPaddingHorizontal = md;
  static const double buttonIconSpacing = sm;

  // Input field sizes
  static const double inputHeightSm = 36.0;
  static const double inputHeightMd = 48.0;
  static const double inputHeightLg = 56.0;
  static const double inputPaddingHorizontal = md;

  // Border radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusRound = 999.0;

  // Card sizes
  static const double cardElevation = 2.0;
  static const double cardBorderRadius = radiusMd;
  static const double cardPaddingVertical = md;
  static const double cardPaddingHorizontal = md;

  // App bar
  static const double appBarHeight = 56.0;
  static const double appBarElevation = 0.0;
  static const double appBarPadding = md;

  // Bottom navigation
  static const double bottomNavHeight = 72.0;
  static const double bottomNavIconSize = iconMd;
  static const double bottomNavElevation = 8.0;

  // List items
  static const double listTileHeight = 72.0;
  static const double listTileIconSize = iconMd;
  static const double listTileSpacing = sm;

  // Avatar sizes
  static const double avatarXs = 24.0;
  static const double avatarSm = 32.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 64.0;
  static const double avatarXl = 96.0;

  // Badge sizes
  static const double badgeSize = 20.0;
  static const double badgePadding = 4.0;

  // Divider
  static const double dividerThickness = 1.0;
  static const double dividerIndent = md;

  // Shadow/Elevation
  static const double shadowBlur = 8.0;
  static const double shadowOffset = 2.0;
  static const double shadowOpacity = 0.1;

  // Animation values
  static const double defaultBorderWidth = 1.0;
  static const double focusedBorderWidth = 2.0;

  // Grid spacing
  static const double gridSpacing = md;
  static const int gridCrossAxisCount = 2;

  // Modal/Dialog
  static const double dialogPadding = lg;
  static const double dialogBorderRadius = radiusLg;
  static const double dialogMaxWidth = 400.0;

  // Bottom sheet
  static const double bottomSheetBorderRadius = radiusLg;
  static const double bottomSheetPadding = lg;
  static const double bottomSheetHandleWidth = 40.0;
  static const double bottomSheetHandleHeight = 4.0;

  // Snackbar
  static const double snackbarBorderRadius = radiusSm;
  static const double snackbarPadding = md;
  static const double snackbarMargin = md;

  // Habit card specific
  static const double habitCardHeight = 80.0;
  static const double habitIconSize = iconLg;
  static const double habitStreakIconSize = iconSm;

  // Stats card
  static const double statsCardHeight = 120.0;
  static const double statsNumberSize = 48.0;

  // Achievement card
  static const double achievementCardSize = 100.0;
  static const double achievementIconSize = iconXl;

  // Garden plant
  static const double plantSize = 80.0;
  static const double plantSpacing = md;

  // Chart dimensions
  static const double chartHeight = 200.0;
  static const double chartPadding = md;
  static const double chartLegendSpacing = sm;

  // Loading indicator
  static const double loadingIndicatorSize = iconLg;
  static const double loadingIndicatorStrokeWidth = 3.0;

  // Image sizes
  static const double imageIconSize = 100.0;
  static const double imageThumbnailSize = 64.0;
  static const double imagePreviewSize = 200.0;

  // Helper methods
  static double spacing(double multiplier) => base * multiplier;

  static double responsiveSpacing(double screenWidth) {
    if (screenWidth < 360) {
      return sm;
    } else if (screenWidth < 600) {
      return md;
    } else {
      return lg;
    }
  }
}
