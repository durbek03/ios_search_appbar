# iOS Search AppBar

The **iOS Search AppBar** package is a Flutter library that provides a collapsible app bar and a beautiful search bar animation, giving your Flutter app an iOS-style look and feel. It is fully customizable and compatible with both iOS and Android platforms.

![demo_gif](https://github.com/durbek03/ios_search_appbar/assets/76834170/1f671641-2e63-4297-b1f2-a1a8aa32abe6)

## Usage
Add the `ios_search_appbar` package to your `pubspec.yaml` file:

```yaml
dependencies:
  ios_search_appbar: ^1.0.7

```
Import the package in your Dart code:
```dart
import 'package:ios_search_appbar/cupertino_search_appbar.dart';
```
Use `CupertinoSearchAppBar` by passing your content to the `slivers` parameter:
```dart
CupertinoSearchAppBar(
  slivers: [
    // Your slivers go here
  ],
)
```
Example:
```dart
class Example extends StatelessWidget {
  const Example({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoSearchAppBar(
      //to customize search bar, use:
      searchFieldProperties: SearchFieldProperties(),
      //to customize app bar, use:
      appBarProperties: AppBarProperties(),
      slivers: [
        //under the hood this package places other necessary sliver before yours' to correctly animate searchBar
        //but for such cases as CupertinoSliverRefreshControl, it is safe to insert them at the beginning and to do that
        //wrap your sliver with Prior widget
        Prior(
          child: CupertinoSliverRefreshControl()
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return CupertinoListTile(title: Text("Title with index of $index"));
            },
            childCount: 15,
          ),
        ),
      ],
    );
  }
}
