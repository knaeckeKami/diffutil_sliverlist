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


## How to use

### Don't mutate the list passed into DiffUtilSliverList yourself

The widget works by comparing the old list with the new list.

If you have a `List<int> list = [1,2,3]`, pass this to

`DiffUtilSliverList<int>(items: list, ...)`, 

and then use something like


```dart
setState(() {
  list.add(4);
});
```

this is not going to work, since you mutated the list and now DiffUtil can't compare the two state of the lists any more.

either copy the list before mutation:

```dart
setState(() {
  list = List.from(list); // copy the old list
  list.add(4);
});
```

Or just copy the list before passing it to DiffUtilSliverList:

`DiffUtilSliverList<int>(items: List.from(list), ...)`,

### Mutability

DiffUtilSliverList operates as if it owns the passed list and mutates the old list
 it during calculating which items to animate. 
 
This means that the list passed into DiffUtilSliverList needs to be mutable and growable.
 
So if you first use it with the list `[1,2,3]`, and then with the list `[1,2,3,4]`, 
it will mutate the fist list with to contents `[1,2,3]`. 
Normally, this should not be a problem, as the list is outdated anyway, but if this is a problem in your use case,
copy the list before passing it to DiffUtilSliverList.
 
