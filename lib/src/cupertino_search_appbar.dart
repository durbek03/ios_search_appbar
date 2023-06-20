import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:navigation_search_bar/src/constants.dart';
import 'package:navigation_search_bar/src/cupertino_appbar.dart';
import 'package:navigation_search_bar/src/properties/app_bar_props.dart';
import 'package:navigation_search_bar/src/properties/search_field_props.dart';
import 'package:navigation_search_bar/src/search_field.dart';
import 'package:navigation_search_bar/src/view_model.dart';
import 'package:navigation_search_bar/src/widgets/extra_scroll_sliver.dart';
import 'package:navigation_search_bar/src/widgets/sliver_pinned_header.dart';
import 'package:navigation_search_bar/src/widgets/status_bar.dart';

class CupertinoSearchAppBar extends StatefulWidget {
  CupertinoSearchAppBar({
    Key? key,
    required this.slivers,
    this.title = "",

    /// set initial offset to 36.0 if you want to define scrollController
    this.scrollController,
    SearchFieldProperties? searchFieldProperties,
    AppBarProperties? appBarProperties,
  }) : super(key: key) {
    this.searchFieldProperties = searchFieldProperties ?? SearchFieldProperties();
    this.appBarProperties = appBarProperties ?? AppBarProperties();
  }

  /// Title of [NavigationAppBar]
  final String title;

  /// Pass widgets as slivers
  final List<Widget> slivers;

  /// Scroll controller of [CustomScrollView]
  late final ScrollController? scrollController;

  /// With this field, [CupertinoTextField] which is responsible for search can be customized
  late final SearchFieldProperties searchFieldProperties;

  /// With this field, [NavigationAppBar] can be customized
  late final AppBarProperties appBarProperties;

  @override
  State<CupertinoSearchAppBar> createState() => _CupertinoSearchAppBarState(scrollController: scrollController);
}

class _CupertinoSearchAppBarState extends State<CupertinoSearchAppBar> {
  /// [ViewModel] holds all necessary fields for driving core functionalities of this package (appBarCollapse, searchTextField animation...)
  late final ViewModel _viewModel = ViewModel();
  String? listHashCodeBefore;
  late final ScrollController scrollController;
  double remainingScreenHeight = 0;

  _CupertinoSearchAppBarState({ScrollController? scrollController}) {
    this.scrollController = scrollController ?? ScrollController(initialScrollOffset: kSearchHeight);
  }

  @override
  void dispose() {
    scrollController.dispose();
    SearchFieldProperties.focusNode.dispose();
    SearchFieldProperties.controller.dispose();
    super.dispose();
  }


  @override
  void didUpdateWidget(CupertinoSearchAppBar oldWidget) {
    _viewModel.offsetChange(scrollController.offset);
    return super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (SearchFieldProperties.focusNode.hasFocus) {
          SearchFieldProperties.focusNode.unfocus();
        }
      },
      child: NotificationListener(
        onNotification: (notification) {
          if (notification is ScrollNotification) {
            _viewModel.offsetChange(scrollController.offset);
            if (notification is ScrollStartNotification) {
              _viewModel.isScrolling.value = true;
            }
            if (notification is ScrollEndNotification) {
              _viewModel.isScrolling.value = false;
            }
            _viewModel.calculateSearch(scrollController.offset, scrollController.position.userScrollDirection);
          }
          return false;
        },
        child: Stack(
          children: [
            CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              controller: scrollController,
              slivers: [
                ValueListenableBuilder(
                    valueListenable: _viewModel.isScrolling,
                    builder: (BuildContext context, bool isScrolling, Widget? child) {
                      /// This sliver has height of 0 but scrollExtent of the same height as [CupertinoSearchTextField]
                      /// The purpose of this sliver is maintaining position of slivers
                      /// inside [CustomScrollView] while [CupertinoSearchTextField] animates it's height

                      ExtraScrollRenderSliver.shouldUpdate = isScrolling == false;
                      return ExtraScrollSliver(
                        key: Key("extraScrollKey${DateTime.now().millisecondsSinceEpoch}"),
                        extraScroll: kSearchHeight,
                        isScrolling: isScrolling,
                        child: const SizedBox(),
                      );
                    }),
                SliverToBoxAdapter(
                  child: ValueListenableBuilder(
                    builder: (context, largeTitleVisible, child) {
                      return ValueListenableBuilder(
                        valueListenable: _viewModel.appBarCollapsed,
                        builder: (context, appBarCollapsed, child) {
                          return _buildTitle(context, isVisible: largeTitleVisible, appBarCollapsed: appBarCollapsed);
                        },
                      );
                    },
                    valueListenable: _viewModel.largeTitleVisible,
                  ),
                ),
                SliverPinnedHeader(
                    child: ValueListenableBuilder(
                        valueListenable: _viewModel.searchCancelOpen,
                        builder: (context, cancelOpen, child) {
                          return ValueListenableBuilder(
                            valueListenable: _viewModel.appBarCollapsed,
                            builder: (context, isCollapsed, child) {
                              return SearchField(
                                scrollController: scrollController,
                                appBarCollapsed: isCollapsed,
                                viewModel: _viewModel,
                                properties: widget.searchFieldProperties,
                                searchCancelOpen: cancelOpen,
                                backgroundColor:
                                    widget.appBarProperties.backgroundColor ?? context.kDefaultAppBarColor(),
                                borderColor:
                                    widget.appBarProperties.borderColor ?? const Color.fromRGBO(60, 60, 67, 0.29),
                              );
                            },
                          );
                        })),
                ...widget.slivers,
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: kSearchHeight,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              child: ValueListenableBuilder(
                  valueListenable: _viewModel.largeTitleVisible,
                  builder: (context, largeTitleVisible, child) {
                    return ValueListenableBuilder(
                      valueListenable: _viewModel.appBarCollapsed,
                      builder: (context, isCollapsed, child) {
                        return NavigationAppBar(
                          borderColor: widget.appBarProperties.borderColor,
                          backgroundColor: widget.appBarProperties.backgroundColor,
                          blurred: !widget.appBarProperties.blurredBackground ? false : !largeTitleVisible,
                          largeTitleVisible: largeTitleVisible,
                          title: widget.title,
                          titleStyle: widget.appBarProperties.titleStyle,
                          isCollapsed: isCollapsed,
                        );
                      },
                    );
                  }),
            ),

            /// making SystemStatusBar transparent
            const SystemStatusBar()
          ],
        ),
      ),
    );
  }

  /// Large title of app bar
  Widget _buildTitle(BuildContext context, {bool isVisible = true, required bool appBarCollapsed}) {
    return AnimatedContainer(
      color: appBarCollapsed ? widget.appBarProperties.backgroundColor : Scaffold.of(context).widget.backgroundColor,
      padding: const EdgeInsets.only(
        left: 15,
      ),
      height: appBarCollapsed ? 0 : MediaQuery.of(context).padding.top + 44 + 44,
      duration: kAppBarCollapseDuration,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: DefaultTextStyle(
          style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          child: AnimatedOpacity(
            opacity: appBarCollapsed ? 0 : 1,
            duration: const Duration(milliseconds: 100),
            child: Text(isVisible ? widget.title : "", style: widget.appBarProperties.titleStyle),
          ),
        ),
      ),
    );
  }
}
