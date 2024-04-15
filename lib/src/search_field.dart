import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_search_appbar/src/constants.dart';
import 'package:ios_search_appbar/src/properties/search_field_props.dart';
import 'package:ios_search_appbar/src/view_model.dart';

final _cancelButtonKey = GlobalKey();

class SearchField extends StatefulWidget {
  SearchField(
      {Key? key,
      required this.appBarCollapsed,
      required this.viewModel,
      required this.properties,
      required this.searchCancelOpen,
      required this.backgroundColor,
      required this.scrollController,
      required this.borderColor})
      : super(key: key);

  final ViewModel viewModel;
  final SearchFieldProperties properties;
  final bool searchCancelOpen;
  final bool appBarCollapsed;
  final Color backgroundColor;
  final Color borderColor;
  final ScrollController scrollController;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  double? cancelButtonWidth = null;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_cancelButtonKey.currentContext != null) {
        cancelButtonWidth = _cancelButtonKey.currentContext?.findRenderObject()?.paintBounds.size.width;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ValueListenableBuilder(
          valueListenable: widget.viewModel.searchHeight,
          builder: (BuildContext context, double value, Widget? child) {
            return TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: value),
              duration: Duration(milliseconds: widget.viewModel.shouldAnimateSmoothly ? 200 : 10),
              builder: (context, double tweenValue, child) {
                late double opacity;
                const threshold = kSearchHeight * 0.8;
                const oneStepValue = (10 / (kSearchHeight - threshold));
                opacity = (tweenValue.ceil() - threshold.ceil()) * oneStepValue / 10;
                if (opacity > 1) {
                  opacity = 1;
                }
                if (opacity < 0) {
                  opacity = 0;
                }
                return AnimatedContainer(
                  decoration: BoxDecoration(
                      color: widget.appBarCollapsed ? widget.backgroundColor : Scaffold.of(context).widget.backgroundColor,
                      border: widget.appBarCollapsed
                          ? Border(
                              bottom: BorderSide(
                                color: widget.borderColor,
                                width: 0.33,
                              ),
                            )
                          : invisibleBorder),
                  padding: EdgeInsets.only(
                      bottom: 10,
                      left: widget.properties.paddingLeft,
                      top: widget.appBarCollapsed ? (MediaQuery.of(context).padding.top + 12) : 8,
                      right: widget.properties.paddingRight),
                  duration: kAppBarCollapseDuration,
                  child: SizedBox(
                    height: tweenValue,
                    child: Stack(
                      alignment: AlignmentDirectional.centerStart,
                      children: [
                        AnimatedContainer(
                          duration: kAppBarCollapseDuration,
                          /// MediaQuery.of(context).size.width * 0.725 is approximate width of searchField if the word of "Cancel" button is Cancel;
                          /// if for some reason cancelButtonWidth is not calculated correctly I will use MediaQuery.of(context).size.width * 0.725 as default width
                          width: widget.searchCancelOpen ? (cancelButtonWidth == null ? (constraints.maxWidth) * 0.725 : constraints.maxWidth - (cancelButtonWidth! + widget.properties.paddingLeft + 2 * widget.properties.paddingRight)) : MediaQuery.of(context).size.width,
                          child: Focus(
                            onFocusChange: (value) {
                              widget.viewModel.onFocusChange(value, widget.properties.getController().text);
                              widget.viewModel.onSearchFocusChange(value, widget.properties.getController().text);
                            },
                            child: CupertinoSearchTextField(
                              onSuffixTap: () {
                                widget.properties.getController().text = "";
                                widget.properties.getFocusNode().requestFocus();
                                widget.properties.onSuffixTap?.call();
                              },
                              suffixIcon: widget.properties.suffixIcon,
                              focusNode: widget.properties.getFocusNode(),
                              style: widget.properties.style,
                              controller: widget.properties.getController(),
                              onChanged: widget.properties.onChanged,
                              backgroundColor: widget.properties.backgroundColor,
                              onSubmitted: widget.properties.onSubmitted,
                              placeholder: widget.properties.placeholder,
                              placeholderStyle: (widget.properties.placeholderStyle ??
                                  const TextStyle(color: CupertinoColors.systemGrey).copyWith(
                                      color: (widget.properties.placeholderStyle?.color ?? CupertinoColors.systemGrey)
                                          .withOpacity(opacity))),
                              decoration: widget.properties.decoration,
                              borderRadius: widget.properties.borderRadius,
                              keyboardType: widget.properties.keyboardType,
                              padding: widget.properties.padding,
                              itemSize: widget.properties.itemSize,
                              itemColor: widget.properties.itemColor,
                              prefixIcon: Builder(builder: (context) {
                                return Opacity(
                                  opacity: opacity,
                                  child: widget.properties.prefixIcon,
                                );
                              }),
                              prefixInsets: widget.properties.prefixInsets,
                              suffixInsets: widget.properties.suffixInsets,
                              autofocus: widget.properties.autofocus,
                              autocorrect: widget.properties.autocorrect,
                              enabled: widget.properties.enabled,
                              onTap: widget.properties.onTap,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: AnimatedOpacity(
                            curve: Curves.easeIn,
                            duration: kAppBarCollapseDuration,
                            opacity: widget.searchCancelOpen ? 1 : 0,
                            child: AnimatedSlide(
                              offset: Offset(widget.searchCancelOpen ? 0 : 2, 0),
                              duration: kAppBarCollapseDuration,
                              child: GestureDetector(
                                onTap: () async {
                                  widget.properties.onCancelTap?.call();
                                  await widget.viewModel.cancelSearch(
                                      widget.properties.getController(), widget.scrollController, widget.properties.getFocusNode());
                                  widget.viewModel.changeAppBarCollapseState(false, widget.properties.getController().text);
                                  widget.viewModel.changeCancelSearch(false);
                                },
                                child: Text(
                                  key: _cancelButtonKey,
                                  widget.properties.cancelButtonName,
                                  style: widget.properties.cancelButtonStyle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      }
    );
  }
}
