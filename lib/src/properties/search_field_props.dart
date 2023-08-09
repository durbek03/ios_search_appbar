import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchFieldProperties {
  SearchFieldProperties(
      {this.controller,
      this.onChanged,
      this.onSubmitted,
      this.style,
      this.placeholder,
      this.placeholderStyle,
      this.decoration,
      this.backgroundColor,
      this.borderRadius,
      this.keyboardType = TextInputType.text,
      this.padding = const EdgeInsetsDirectional.fromSTEB(5.5, 8, 5.5, 8),
      this.itemColor = CupertinoColors.secondaryLabel,
      this.itemSize = 20.0,
      this.prefixInsets = const EdgeInsetsDirectional.fromSTEB(6, 0, 0, 3),
      this.prefixIcon = const Icon(CupertinoIcons.search),
      this.suffixInsets = const EdgeInsetsDirectional.fromSTEB(0, 0, 5, 2),
      this.suffixIcon = const Icon(CupertinoIcons.xmark_circle_fill),
      this.onSuffixTap,
      this.focusNode,
      this.autofocus = false,
      this.onTap,
      this.autocorrect = true,
      this.enabled = true,
      this.onCancelTap,
      this.paddingLeft = 16,
      this.paddingRight = 16,
      this.cancelButtonName = "Cancel",
      this.cancelButtonStyle = const TextStyle(
          color: Colors.blue, fontWeight: FontWeight.w400, fontSize: 17)}) {}

  final TextEditingController? controller;
  final TextEditingController _localController = TextEditingController();
  final FocusNode? focusNode;
  final FocusNode _localFocusNode = FocusNode();

  TextEditingController getController() {
    return controller ?? _localController;
  }

  FocusNode getFocusNode() {
    return focusNode ?? _localFocusNode;
  }

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onCancelTap;
  final TextStyle? style;
  final String? placeholder;
  final TextStyle? placeholderStyle;
  final BoxDecoration? decoration;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final TextInputType? keyboardType;
  final EdgeInsetsGeometry padding;
  final Color itemColor;
  final double itemSize;
  final EdgeInsetsGeometry prefixInsets;
  final Widget prefixIcon;
  final EdgeInsetsGeometry suffixInsets;
  final Icon suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool autofocus;
  final VoidCallback? onTap;
  final bool autocorrect;
  final double paddingLeft;
  final double paddingRight;
  final String cancelButtonName;
  final TextStyle cancelButtonStyle;
  final bool? enabled;

  ///do not call this method. this should be called only from within the package
  dispose() {
    _localFocusNode.dispose();
    _localController.dispose();
  }
}
