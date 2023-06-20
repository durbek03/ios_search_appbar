import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:navigation_search_bar/src/constants.dart';
import 'package:navigation_search_bar/src/properties/search_field_props.dart';
import 'package:navigation_search_bar/src/view_model.dart';

class SearchField extends StatelessWidget {
  const SearchField(
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
  Widget build(BuildContext context) {
    final focusedSearchWidth = MediaQuery.of(context).size.width * 0.7525;
    return ValueListenableBuilder(
      valueListenable: viewModel.searchHeight,
      builder: (BuildContext context, double value, Widget? child) {
        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: value),
          duration: Duration(milliseconds: viewModel.shouldAnimateSmoothly ? 200 : 10),
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
                  color: appBarCollapsed ? backgroundColor : Scaffold.of(context).widget.backgroundColor,
                  border: appBarCollapsed
                      ? Border(
                          bottom: BorderSide(
                            color: borderColor,
                            width: 0.33,
                          ),
                        )
                      : invisibleBorder),
              padding: EdgeInsets.only(
                  bottom: 10,
                  left: 15.0,
                  top: appBarCollapsed ? (MediaQuery.of(context).padding.top + 12) : 8,
                  right: 15),
              duration: kAppBarCollapseDuration,
              child: SizedBox(
                height: tweenValue,
                child: Stack(
                  alignment: AlignmentDirectional.centerStart,
                  children: [
                    AnimatedContainer(
                      duration: kAppBarCollapseDuration,
                      width: searchCancelOpen ? focusedSearchWidth : MediaQuery.of(context).size.width,
                      child: Focus(
                        onFocusChange: (value) {
                          viewModel.onFocusChange(value, SearchFieldProperties.controller.text);
                          viewModel.onSearchFocusChange(value, SearchFieldProperties.controller.text);
                        },
                        child: CupertinoSearchTextField(
                          onSuffixTap: () {
                            SearchFieldProperties.controller.text = "";
                            SearchFieldProperties.focusNode.requestFocus();
                            properties.onSuffixTap?.call();
                          },
                          suffixIcon: properties.suffixIcon,
                          focusNode: SearchFieldProperties.focusNode,
                          style: properties.style,
                          controller: SearchFieldProperties.controller,
                          onChanged: properties.onChanged,
                          backgroundColor: properties.backgroundColor,
                          onSubmitted: properties.onSubmitted,
                          placeholder: properties.placeholder,
                          placeholderStyle: (properties.placeholderStyle ?? const TextStyle(color: CupertinoColors.systemGrey).copyWith(color: (properties.placeholderStyle?.color ?? CupertinoColors.systemGrey).withOpacity(opacity))),
                          decoration: properties.decoration,
                          borderRadius: properties.borderRadius,
                          keyboardType: properties.keyboardType,
                          padding: properties.padding,
                          itemSize: properties.itemSize,
                          itemColor: properties.itemColor,
                          prefixIcon: Builder(builder: (context) {

                            return Opacity(
                              opacity: opacity,
                              child: properties.prefixIcon,
                            );
                          }),
                          prefixInsets: properties.prefixInsets,
                          suffixInsets: properties.suffixInsets,
                          autofocus: properties.autofocus,
                          autocorrect: properties.autocorrect,
                          enabled: properties.enabled,
                          onTap: properties.onTap,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: AnimatedOpacity(
                        curve: Curves.easeIn,
                        duration: kAppBarCollapseDuration,
                        opacity: searchCancelOpen ? 1 : 0,
                        child: AnimatedSlide(
                          offset: Offset(searchCancelOpen ? 0 : 2, 0),
                          duration: kAppBarCollapseDuration,
                          child: GestureDetector(
                            onTap: () async {
                              properties.onCancelTap?.call();
                              await viewModel.cancelSearch(
                                  SearchFieldProperties.controller, scrollController, SearchFieldProperties.focusNode);
                              viewModel.changeAppBarCollapseState(false, SearchFieldProperties.controller.text);
                              viewModel.changeCancelSearch(false);
                            },
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w400, fontSize: 17),
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
}
