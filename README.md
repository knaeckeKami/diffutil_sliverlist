# diffutil_sliverlist

A SliverList that implicitly animates changes.



```dart

Widget build(BuildContext context) {
    return CustomScrollView(
                 slivers: [
                   DiffUtilSliverList.fromList<int>(
                     list,
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
                     removeAnimationDuration: const Duration(milliseconds: 300),
                     insertAnimationDuration: const Duration(milliseconds: 120),
                   ),
                 ],
               );
}

```

If `list` changes, the list will automatically animate new/removed items:

![](https://media.giphy.com/media/LRgWnoPvRPW5WEeJYq/giphy.gif)