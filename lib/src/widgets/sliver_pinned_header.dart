import 'package:flutter/widgets.dart';
import 'package:navigation_search_bar/src/widgets/render_sliver_pinned_header.dart';

class SliverPinnedHeader extends SingleChildRenderObjectWidget {
  const SliverPinnedHeader({
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderSliverPinnedHeader createRenderObject(BuildContext context) {
    return RenderSliverPinnedHeader();
  }
}
