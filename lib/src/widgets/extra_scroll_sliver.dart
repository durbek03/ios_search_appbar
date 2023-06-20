import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ExtraScrollSliver extends SingleChildRenderObjectWidget {
  const ExtraScrollSliver({required this.extraScroll, Widget? child, required this.isScrolling, Key? key})
      : super(child: child, key: key);
  final double extraScroll;
  final bool isScrolling;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return ExtraScrollRenderSliver(extraScroll, isScrolling);
  }
}

class ExtraScrollRenderSliver extends RenderSliverSingleBoxAdapter {
  ExtraScrollRenderSliver(this.extraScroll, this.isScrolling);

  static bool shouldUpdate = false;
  final double extraScroll;
  final bool isScrolling;
  ScrollDirection lastScrollDirection = ScrollDirection.idle;

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    final SliverConstraints constraints = this.constraints;
    if (constraints.userScrollDirection.name != ScrollDirection.idle.name) {
      lastScrollDirection = constraints.userScrollDirection;
    }
    ;
    child!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    final double childExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child!.size.width;
        break;
      case Axis.vertical:
        childExtent = child!.size.height;
        break;
    }
    final double paintedChildSize = calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    final double cacheExtent = calculateCacheOffset(constraints, from: 0.0, to: childExtent);

    final offset = constraints.scrollOffset;
    if (ExtraScrollRenderSliver.shouldUpdate) {
      ExtraScrollRenderSliver.shouldUpdate = false;
      if (offset > 0 && offset <= extraScroll / 3) {
        geometry = SliverGeometry(scrollOffsetCorrection: -offset);
        return;
      }
      if (offset > extraScroll / 3 && offset < extraScroll) {
        geometry = SliverGeometry(scrollOffsetCorrection: extraScroll - offset);
        return;
      }
    }

    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);
    geometry = SliverGeometry(
      scrollExtent: childExtent + extraScroll,
      paintExtent: paintedChildSize,
      cacheExtent: cacheExtent,
      maxPaintExtent: childExtent,
      hitTestExtent: paintedChildSize,
      hasVisualOverflow: childExtent > constraints.remainingPaintExtent || constraints.scrollOffset > 0.0,
    );
    setChildParentData(child!, constraints, geometry!);
  }
}
