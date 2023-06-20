import 'package:flutter/material.dart';

class AppBarProperties {
  AppBarProperties({
    TextStyle? titleStyle,
    this.backgroundColor,
    this.blurredBackground = true,
    this.borderColor,
  }) {
    this.titleStyle = titleStyle ?? const TextStyle();
  }

  late final TextStyle titleStyle;
  final Color? backgroundColor;
  late final Color? borderColor;
  final bool blurredBackground;
}
