import 'package:diffutil_dart/diffutil.dart' as diffutil;
import 'package:diffutil_sliverlist/src/sliver_list_update_adapter.dart';
import 'package:flutter/widgets.dart';

typedef EqualityChecker<T> = bool Function(T, T);
typedef DiffUtilWidgetBuilder<T> = Widget Function(BuildContext, T);
typedef AnimatedDiffUtilWidgetBuilder = Widget Function(
    BuildContext, Animation<double>, Widget);

class DiffUtilSliverList<T> extends StatefulWidget {
  /// the (immutable) list of items
  final List<T> items;

  /// builder that renders a single item (without animation)
  final Widget Function(BuildContext, T) builder;

  /// builder that renders the insertion animation
  final AnimatedDiffUtilWidgetBuilder insertAnimationBuilder;

  /// that renders the removal animation
  final AnimatedDiffUtilWidgetBuilder removeAnimationBuilder;
  final Duration insertAnimationDuration;
  final Duration removeAnimationDuration;

  final EqualityChecker<T> equalityChecker;

  const DiffUtilSliverList({
    Key key,
    @required this.items,
    @required this.builder,
    @required this.insertAnimationBuilder,
    @required this.removeAnimationBuilder,
    this.insertAnimationDuration = const Duration(milliseconds: 300),
    this.removeAnimationDuration = const Duration(milliseconds: 300),
    this.equalityChecker,
  }) : super(key: key);

  @override
  _DiffUtilSliverListState<T> createState() => _DiffUtilSliverListState<T>();
}

class _DiffUtilSliverListState<T> extends State<DiffUtilSliverList<T>> {
  GlobalKey<SliverAnimatedListState> listKey;

  @override
  void initState() {
    super.initState();
    listKey = GlobalKey<SliverAnimatedListState>();
  }

  @override
  void didUpdateWidget(DiffUtilSliverList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldList = oldWidget.items;
    final newList = widget.items;

    final diff = diffutil.calculateListDiff<T>(oldList, newList,
        detectMoves: false, equalityChecker: widget.equalityChecker);
    final diffHandler = ListUpdateCallBackToSliverAnimatedListKeyAdapter<T>(
        listKey,
        oldWidget.builder,
        oldList,
        oldWidget.removeAnimationBuilder,
        widget.insertAnimationDuration,
        widget.removeAnimationDuration);
    diff.dispatchUpdatesTo(diffHandler);
  }

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedList(
      key: listKey,
      initialItemCount: widget.items.length,
      itemBuilder: (context, index, animation) => widget.insertAnimationBuilder(
        context,
        animation,
        widget.builder(context, widget.items[index]),
      ),
    );
  }
}
