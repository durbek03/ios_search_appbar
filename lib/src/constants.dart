import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension Constants on BuildContext {
  Color kDefaultAppBarColor() {
    return CupertinoTheme.of(this).barBackgroundColor.withAlpha(0xFF);
  }
}

Border invisibleBorder = const Border(
  bottom: BorderSide(
    color: Colors.transparent,
    width: 0,
  ),
);

const Duration kAppBarCollapseDuration = Duration(milliseconds: 200);
const double kSearchHeight = 36.0;