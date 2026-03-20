import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  static double getWidth(BuildContext context) => MediaQuery.of(context).size.width;

  static double getHeight(BuildContext context) => MediaQuery.of(context).size.height;
  
  static T responsiveValue<T>(BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = getWidth(context);
    if (width >= 1200 && desktop != null) return desktop;
    if (width >= 600 && tablet != null) return tablet;
    return mobile;
  }
}
