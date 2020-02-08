# diffutil_sliverlist

[![Pub Package](https://img.shields.io/pub/v/diffutil_sliverlist.svg)](https://pub.dartlang.org/packages/diffutil_sliverlist)

A SliverList that implicitly animates changes.


```dart

Widget build(BuildContext context) {
    return CustomScrollView(
                     slivers: [
                       DiffUtilSliverList<int>(
                         items: list,
                         builder: (context, item) => Container(
                           color: colors[item % colors.length],
                           height: 48,
                           width: double.infinity,
                         ),
                         insertAnimationBuilder: (context, animation, child) =>
                             FadeTransition(
                           opacity: animation,
                           child: child,
                         ),
                         removeAnimationBuilder: (context, animation, child) =>
                             SizeTransition(
                           sizeFactor: animation,
                           child: child,
                         ),
                         removeAnimationDuration: const Duration(milliseconds: 3000),
                         insertAnimationDuration: const Duration(milliseconds: 1200),
                       ),
                     ],
                   );
}

```

If `list` changes, the list will automatically animate new/removed items:

![](https://media.giphy.com/media/LRgWnoPvRPW5WEeJYq/giphy.gif)