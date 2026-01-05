// lib/utils/responsive.dart

import 'package:flutter/material.dart';

/// RESPONSIVE UTILITY CLASS
///
/// UI Logic: Provides responsive sizing based on screen dimensions
///
/// Breakpoints:
/// - Mobile: < 600px (phones)
/// - Tablet: 600px - 900px (tablets, small laptops)
/// - Desktop: > 900px (desktops, large screens)
///
/// These breakpoints follow Material Design guidelines
/// and common industry standards
///
/// Usage:
/// - Check device type: Responsive.isMobile(context)
/// - Get adaptive padding: Responsive.getPagePadding(context)
/// - Get adaptive width: Responsive.getContentWidth(context)
/// - Get adaptive font sizes
class Responsive {
  /// Check if current device is mobile (< 600px)
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  /// Check if current device is tablet (600px - 900px)
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
          MediaQuery.of(context).size.width < 900;

  /// Check if current device is desktop (> 900px)
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  /// Get responsive page padding
  ///
  /// Returns:
  /// - Mobile: 16px padding
  /// - Tablet: 24px padding
  /// - Desktop: 32px padding
  ///
  /// Larger screens get more padding for better readability
  static EdgeInsets getPagePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  /// Get responsive content width
  ///
  /// Returns:
  /// - Mobile: Full screen width
  /// - Tablet: 80% of screen width
  /// - Desktop: Fixed 800px (for better readability)
  ///
  /// This prevents content from becoming too wide on large screens
  static double getContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (isMobile(context)) {
      return screenWidth;
    } else if (isTablet(context)) {
      return screenWidth * 0.8;
    } else {
      return 800; // Max width for desktop
    }
  }

  /// Get responsive title font size
  ///
  /// Returns:
  /// - Mobile: 20px
  /// - Tablet: 24px
  /// - Desktop: 28px
  static double getTitleFontSize(BuildContext context) {
    if (isMobile(context)) {
      return 20;
    } else if (isTablet(context)) {
      return 24;
    } else {
      return 28;
    }
  }

  /// Get responsive body font size
  ///
  /// Returns:
  /// - Mobile: 14px
  /// - Tablet/Desktop: 16px
  static double getBodyFontSize(BuildContext context) {
    if (isMobile(context)) {
      return 14;
    } else {
      return 16;
    }
  }

  /// Get responsive button padding
  ///
  /// Returns:
  /// - Mobile: Smaller padding for compact UI
  /// - Tablet/Desktop: Larger padding for easier clicking
  static EdgeInsets getButtonPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    }
  }

  /// Get responsive spacing
  ///
  /// Returns:
  /// - Mobile: 12px
  /// - Tablet: 16px
  /// - Desktop: 20px
  static double getSpacing(BuildContext context) {
    if (isMobile(context)) {
      return 12;
    } else if (isTablet(context)) {
      return 16;
    } else {
      return 20;
    }
  }
}