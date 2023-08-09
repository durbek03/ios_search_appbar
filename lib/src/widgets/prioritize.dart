import 'package:flutter/material.dart';

/// wrap your sliver with this widget if you want to [prioritize] it
/// [Prior] widgets will be inserted from the 0 index in [slivers] paramether of [CustomScrollView]
class Prior extends StatelessWidget {
  const Prior ({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
