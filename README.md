# diffutil_sliverlist

[![Pub Package](https://img.shields.io/pub/v/diffutil_sliverlist.svg)](https://pub.dartlang.org/packages/diffutil_sliverlist)
[![Build Status](https://github.com/knaeckeKami/diffutil_sliverlist/workflows/Build/badge.svg)](https://github.com/knaeckeKami/diffutil_sliverlist/actions)
[![codecov](https://codecov.io/gh/knaeckeKami/diffutil_sliverlist/branch/master/graph/badge.svg)](https://codecov.io/gh/knaeckeKami/diffutil_sliverlist)


A SliverList that implicitly animates changes.

It supports two use cases:


## Animating changes from a list of widgets with unique keys

When you have a list of Widgets and can give each Widget a unique key, you can use `DiffUtilSliverList.fromKeyedWidgetList`.

See the example code:

```dart
class _ExpandableListsState extends State<ExpandableLists> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return DiffUtilSliverList.fromKeyedWidgetList(
      children: [
        ListTile(
          key: Key("1"),
          title: Text("first"),
          trailing: Icon(Icons.chevron_right),
        ),
        ListTile(
          key: Key("2"),
          title: Text("second"),
          trailing: Icon(Icons.chevron_right),
        ),
        if (this.expanded)
          for (int i = 3; i < 6; i++)
            ListTile(
              key: Key(i.toString()),
              title: Text("index: $i"),
              trailing: Icon(Icons.chevron_right),
            ),
        ListTile(
          key: Key("expand_collapse"),
          onTap: () => setState(() {
            expaned = !expaned;
          }),
          title: Text(expanded ? "collapse" : "expand", style: TextStyle(fontWeight: FontWeight.bold),),
          trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more),
        )
      ],
      insertAnimationBuilder: (context, animation, child) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      removeAnimationBuilder: (context, animation, child) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          axisAlignment: 0,
          child: child,
        ),
      ),
    );
  }
}
```

And the result:

![](https://media.giphy.com/media/UrKN0Se7CCBwTBP01V/giphy.gif)


## Building Widgets from a list of data objects that implement ==

Example:

```dart

Widget build(BuildContext context) {
    return CustomScrollView(
             slivers: [
               DiffUtilSliverList<int>(
                 items: list,
                 builder: (context, item) => 
                   Container(
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

If the items don't implement `==` correctly, you can pass your own `equalityChecker`.

