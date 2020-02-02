import 'package:diffutil_dart/diffutil.dart' as diffutil;
import 'package:diffutil_sliverlist/src/sliver_list_update_adapter.dart';
import 'package:flutter/widgets.dart';

class DiffUtilSliverList<T, L> extends StatefulWidget {
  /// the (immutable) list of items
  final L items;

  final T Function(L, int) getValueByIndex;

  final int Function(L) getCount;

  /// builder that renders a single item (without animation)
  final Widget Function(BuildContext, T) builder;

  /// builder that renders the insertion animation
  final Widget Function(BuildContext, Animation<double>, Widget)
      insertAnimationBuilder;

  /// that renders the removal animation
  final Widget Function(BuildContext, Animation<double>, Widget)
      removeAnimationBuilder;
  final Duration insertAnimationDuration;
  final Duration removeAnimationDuration;

  final bool Function(T, T) equalityChecker;

  const DiffUtilSliverList({
    Key key,
    @required this.items,
    @required this.getValueByIndex,
    @required this.getCount,
    @required this.builder,
    @required this.insertAnimationBuilder,
    @required this.removeAnimationBuilder,
    this.insertAnimationDuration = const Duration(milliseconds: 300),
    this.removeAnimationDuration = const Duration(milliseconds: 300),
    this.equalityChecker,
  }) : super(key: key);

  static DiffUtilSliverList<T, List<T>> fromList<T>(
    List<T> list, {
    Key key,
    Widget Function(BuildContext, T) builder,
    Widget Function(BuildContext, Animation<double>, Widget)
        removeAnimationBuilder,
    Widget Function(BuildContext, Animation<double>, Widget)
        insertAnimationBuilder,
    bool Function(T, T) equalityChecker,
    Duration insertAnimationDuration,
    Duration removeAnimationDuration,
  }) {
    return DiffUtilSliverList(
      getCount: (list) => list.length,
      getValueByIndex: (list, index) => list.elementAt(index),
      items: list,
      builder: builder,
      key: key,
      removeAnimationBuilder: removeAnimationBuilder,
      insertAnimationBuilder: insertAnimationBuilder,
      equalityChecker: equalityChecker,
      removeAnimationDuration:
          removeAnimationDuration ?? const Duration(milliseconds: 300),
      insertAnimationDuration:
          insertAnimationDuration ?? const Duration(milliseconds: 300),
    );
  }

  @override
  _DiffUtilSliverListState<T, L> createState() =>
      _DiffUtilSliverListState<T, L>();
}

class _DiffUtilSliverListState<T, L> extends State<DiffUtilSliverList<T, L>> {
  GlobalKey<SliverAnimatedListState> listKey;

  @override
  void initState() {
    super.initState();
    listKey = GlobalKey<SliverAnimatedListState>();
  }

  @override
  void didUpdateWidget(DiffUtilSliverList<T, L> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldList = oldWidget.items;
    final newList = widget.items;

    final diff = diffutil.calculateCustomListDiff<T, L>(oldList, newList,
        detectMoves: false,
        equalityChecker: widget.equalityChecker,
        getLength: widget.getCount,
        getByIndex: widget.getValueByIndex);
    final diffHandler = ListUpdateCallBackToSliverAnimatedListKeyAdapter<T, L>(
        listKey,
        oldWidget.builder,
        oldList,
        oldWidget.removeAnimationBuilder,
        widget.insertAnimationDuration,
        widget.getValueByIndex,
        widget.removeAnimationDuration);
    diff.dispatchUpdatesTo(diffHandler);
  }

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedList(
      key: listKey,
      initialItemCount: widget.getCount(widget.items),
      itemBuilder: (context, index, animation) => widget.insertAnimationBuilder(
        context,
        animation,
        widget.builder(context, widget.getValueByIndex(widget.items, index)),
      ),
    );
  }
}
