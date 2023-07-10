import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'constants.dart';

class NavigationAppBar extends StatelessWidget {
  const NavigationAppBar(
      {Key? key,
      required this.blurred,
      required this.largeTitleVisible,
      required this.title,
      required this.titleStyle,
      this.backgroundColor,
      this.borderColor,
      required this.isCollapsed,
      this.trailing,
      this.leading})
      : super(key: key);

  final String title;
  final TextStyle titleStyle;
  final bool blurred;
  final bool largeTitleVisible;
  final Color? backgroundColor;
  final Color? borderColor;
  final Widget? trailing;
  final Widget? leading;
  final bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    return _wrapWithBlur(
      child: AnimatedContainer(
        duration: kAppBarCollapseDuration,
        width: MediaQuery.of(context).size.width,
        height: isCollapsed ? 0 : kMinInteractiveDimensionCupertino +
            MediaQuery.of(context).padding.top,
        decoration: BoxDecoration(
          border: largeTitleVisible ? invisibleBorder : Border(
            bottom: BorderSide(
              color: borderColor ?? const Color.fromRGBO(60, 60, 67, 0.29),
              width: 0.33,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              if (leading != null) ...[
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: leading!,
                  ),
                ),
              ],
              Expanded(
                child: Container(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 100),
                    child: !largeTitleVisible
                        ? Text(
                            title,
                            key: const Key("key_title_shown"),
                            style: titleStyle.copyWith(
                                fontSize: 17, fontWeight: FontWeight.w600),
                          )
                        : const Text(
                            "",
                            key: Key("key_title_hidden"),
                          ),
                  ),
                ),
              ),
              if (trailing != null)
                Expanded(
                    child: Align(
                  alignment: Alignment.centerRight,
                  child: trailing!,
                ))
            ],
          ),
        ),
      ),
      context: context,
    );
  }

  Widget _wrapWithBlur({required Widget child, required BuildContext context}) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: blurred ? 10 : 0, sigmaY: blurred ? 10 : 0),
        child: Container(
          color: Scaffold.of(context).widget.backgroundColor?.withOpacity(blurred ? (!largeTitleVisible ? 0 : 1) : 1),
          child: AnimatedContainer(
            duration: kAppBarCollapseDuration,
            color: isCollapsed ? backgroundColor : !largeTitleVisible ? (blurred
                ? (backgroundColor ?? context.kDefaultAppBarColor())
                    .withOpacity(0.8)
                : (backgroundColor ?? context.kDefaultAppBarColor())) : Scaffold.of(context).widget.backgroundColor,
            child: child,
          ),
        ),
      ),
    );
  }
}
