import 'package:get/get.dart';

extension ResponsiveSize on num {
  /// Scales size relative to standard mobile width baseline of 375 points.
  double get w => (this / 375.0) * Get.width;

  /// Scales size relative to standard mobile height baseline of 812 points.
  double get h => (this / 812.0) * Get.height;

  /// Scales text font size relative to screen width for readable scales across devices.
  double get sp => (this / 375.0) * Get.width;
}
