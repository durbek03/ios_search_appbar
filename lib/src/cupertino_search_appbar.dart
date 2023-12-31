import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_search_appbar/src/constants.dart';
import 'package:ios_search_appbar/src/cupertino_appbar.dart';
import 'package:ios_search_appbar/src/properties/app_bar_props.dart';
import 'package:ios_search_appbar/src/properties/search_field_props.dart';
import 'package:ios_search_appbar/src/search_field.dart';
import 'package:ios_search_appbar/src/view_model.dart';
import 'package:ios_search_appbar/src/widgets/extra_scroll_sliver.dart';
import 'package:ios_search_appbar/src/widgets/sliver_pinned_header.dart';

class CupertinoSearchAppBar extends StatefulWidget {
  CupertinoSearchAppBar({
    Key? key,
    required this.slivers,
    this.refreshSliver,
    this.title = "",

    /// set initial offset to 36.0 if you want to define scrollController
    this.scrollController,
    SearchFieldProperties? searchFieldProperties,
    AppBarProperties? appBarProperties,
  }) : super(key: key) {

    /// if you are passing ScrollController you must set initialScrollOffset to 36.0
    assert(scrollController?.initialScrollOffset == 36.0 || scrollController?.initialScrollOffset == null);

    this.searchFieldProperties = searchFieldProperties ?? SearchFieldProperties();
    this.appBarProperties = appBarProperties ?? AppBarProperties();
  }

  /// Title of [NavigationAppBar]
  final String title;

  /// Pass widgets as slivers
  final List<Widget> slivers;

  /// Scroll controller of [CustomScrollView]
  final ScrollController? scrollController;

  final ScrollController _localScrollController = ScrollController(initialScrollOffset: 36);

  /// With this field, [CupertinoTextField] which is responsible for search can be customized
  late final SearchFieldProperties searchFieldProperties;

  /// With this field, [NavigationAppBar] can be customized
  late final AppBarProperties appBarProperties;

  final Widget? refreshSliver;

  ScrollController getScrollController() {
    return scrollController ?? _localScrollController;
  }

  @override
  State<CupertinoSearchAppBar> createState() => _CupertinoSearchAppBarState();
}

class _CupertinoSearchAppBarState extends State<CupertinoSearchAppBar> {
  /// [ViewModel] holds all necessary fields for driving core functionalities of this package (appBarCollapse, searchTextField animation...)
  late final ViewModel _viewModel = ViewModel();
  String? listHashCodeBefore;
  double remainingScreenHeight = 0;

  /// prioritized slivers will be inserted from the first index of the list
  /// you will not see any difference "UI"wise but the order of slivers will be changed in widget tree
  /// this package needs to insert [ExtraScrollSliver] before other scrollable slivers to correctly animate searchBar
  /// however sometimes you have to insert you own sliver from the 0 index of sliverList. For example [CupertinoSliverRefreshControl] which adds refresher when list is pulled down
  /// inserting your sliver for such use cases does not break the animation of searchBar

  @override
  void dispose() {
    widget._localScrollController.dispose();
    widget.searchFieldProperties.dispose();
    widget.getScrollController().dispose();
    super.dispose();
  }


  @override
  void didUpdateWidget(CupertinoSearchAppBar oldWidget) {
    if (widget.getScrollController().hasClients) {
    _viewModel.offsetChange(widget.getScrollController().offset);
    }
    return super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.searchFieldProperties.getFocusNode().hasFocus) {
          widget.searchFieldProperties.getFocusNode().unfocus();
        }
      },
      child: NotificationListener(
        onNotification: (notification) {
          if (notification is ScrollNotification) {
            _viewModel.offsetChange(widget.getScrollController().offset);
            if (notification is ScrollStartNotification) {
              _viewModel.isScrolling.value = true;
            }
            if (notification is ScrollEndNotification) {
              _viewModel.isScrolling.value = false;
            }
            _viewModel.calculateSearch(widget.getScrollController().offset, widget.getScrollController().position.userScrollDirection);
          }
          return false;
        },
        child: Stack(
          children: [
            CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              controller: widget.getScrollController(),
              slivers: [
                if (widget.refreshSliver != null) widget.refreshSliver!,
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
                                scrollController: widget.getScrollController(),
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
            ValueListenableBuilder(
                valueListenable: _viewModel.offsetIsNegativeOrZero,
                builder: (context, offsetIsNegativeOrZero, child) {
                 return ValueListenableBuilder(
                    valueListenable: _viewModel.largeTitleVisible,
                    builder: (context, largeTitleVisible, child) {
                      return ValueListenableBuilder(
                        valueListenable: _viewModel.appBarCollapsed,
                        builder: (context, isCollapsed, child) {
                          return ValueListenableBuilder(
                              valueListenable: _viewModel.largeTitleIsHalfVisible,
                              builder: (context, largeTitleHalfVisible, child) {
                              return NavigationAppBar(
                                leading: widget.appBarProperties.leading,
                                trailing: widget.appBarProperties.trailing,
                                borderColor: widget.appBarProperties.borderColor,
                                backgroundColor: widget.appBarProperties.backgroundColor,
                                blurred: !widget.appBarProperties.blurredBackground ? false : !largeTitleVisible,
                                largeTitleVisible: largeTitleVisible,
                                title: widget.title,
                                titleStyle: widget.appBarProperties.titleStyle,
                                isCollapsed: isCollapsed, offsetIsNegativeOrZero: offsetIsNegativeOrZero, largeTitleHalfVisible: largeTitleHalfVisible,
                              );
                            }
                          );
                        },
                      );
                    });
              }
            ),

            /// making SystemStatusBar transparent
            // const SystemStatusBar()
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
