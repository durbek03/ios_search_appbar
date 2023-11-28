import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:ios_search_appbar/src/constants.dart';

class ViewModel {
  /// Threshold where large title should disappear
  final double largeTitleThreshold = kMinInteractiveDimensionCupertino + kSearchHeight;

  ///if large title of appBar is beyond [largeTitleThreshold] then it is false else true
  final ValueNotifier<bool> largeTitleVisible = ValueNotifier(true);

  final ValueNotifier<bool> largeTitleIsHalfVisible = ValueNotifier(false);

  ///height of searchBar
  final ValueNotifier<double> searchHeight = ValueNotifier(0);

  ///Value of this field is [true] if scrolling is stopped when searchBars
  ///height is not fully animated (of height between 0 and 36) and else false
  bool shouldAnimateSmoothly = false;

  ///true if appBar is collapsed else false
  final ValueNotifier<bool> appBarCollapsed = ValueNotifier(false);

  ///true if cancel button on searchBar is open else false
  final ValueNotifier<bool> searchCancelOpen = ValueNotifier(false);

  ///true if CustomScrollView is being scrolled else false
  final ValueNotifier<bool> isScrolling = ValueNotifier(false);

  ///true if scroll offset is negative else false
  final ValueNotifier<bool> offsetIsNegativeOrZero = ValueNotifier(false);

  ///Calculation of searchBars animation
  calculateSearch(double offset, ScrollDirection direction) {
    if (appBarCollapsed.value) return;
    if (isScrolling.value) {
      if ((direction.name == ScrollDirection.reverse.name && direction.name == ScrollDirection.idle.name) &&
          searchHeight.value == 0) {
        return;
      }
      if ((direction.name == ScrollDirection.forward.name && direction.name == ScrollDirection.idle.name) &&
          searchHeight.value == kSearchHeight) {
        return;
      }

      shouldAnimateSmoothly = false;
      if (offset <= kSearchHeight && offset >= 0) {
        searchHeight.value = kSearchHeight - offset;
        if (searchHeight.value == kSearchHeight) {
        } else if (searchHeight.value == 0) {
        }
        return;
      }
      if (offset > kSearchHeight && searchHeight.value != 0) {
        searchHeight.value = 0;
        return;
      }
      if (offset < 0 && searchHeight.value != kSearchHeight) {
        searchHeight.value = kSearchHeight;
        return;
      }
    } else {
      if (offset > kSearchHeight / 3 && offset <= kSearchHeight) {
        shouldAnimateSmoothly = true;
        searchHeight.value = 0;
        return;
      }
      if (offset <= kSearchHeight / 3 && offset >= 0) {
        shouldAnimateSmoothly = true;
        searchHeight.value = kSearchHeight;
        return;
      }
    }
  }

  void offsetChange(double offset) {
    changeOffsetIsNegativeOrZero(offset);
    _changeLargeTitle(offset);
  }

  void _changeLargeTitle(double offset) {
    if (offset > largeTitleThreshold) {
      largeTitleVisible.value = false;
      largeTitleIsHalfVisible.value = false;
    } else if (offset  <= largeTitleThreshold) {
      largeTitleVisible.value = true;
      largeTitleIsHalfVisible.value = false;
    } else {
      largeTitleIsHalfVisible.value = true;
    }
  }

  void changeOffsetIsNegativeOrZero(double offset) {
    if (offset <= 0 && !offsetIsNegativeOrZero.value) {
      offsetIsNegativeOrZero.value = true;
      return;
    }
    if (offsetIsNegativeOrZero.value) {
      if (offset > 0) {
        offsetIsNegativeOrZero.value = false;
        return;
      }
    }
  }

  changeAppBarCollapseState(bool isCollapsed, String text) async {
    if (!isCollapsed) {
      if (text.trim().isNotEmpty) return;
      appBarCollapsed.value = false;
    } else {
      appBarCollapsed.value = true;
    }
  }

  Future onSearchFocusChange(bool isFocused, String text) async {
    if (isFocused) {
      changeCancelSearch(true);
      return;
    }
    if (!isFocused && text.isEmpty) {
      changeCancelSearch(false);
      return;
    }
  }

  Future cancelSearch(TextEditingController textController, ScrollController scrollController, FocusNode searchFocus) async {
    scrollController.jumpTo(0.0);
    textController.text = "";
    if (searchFocus.hasFocus) {
      searchFocus.unfocus();
    }
  }

  changeCancelSearch(bool cancelOpen) {
    searchCancelOpen.value = cancelOpen;
  }

  onFocusChange(bool value, String text) {
    if (value) {
      changeAppBarCollapseState(value, text);
    } else {
      if (text.isNotEmpty) {
        return;
      } else {
        changeAppBarCollapseState(value, text);
      }
    }
  }
}