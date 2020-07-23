import 'package:diffutil_dart/diffutil.dart' as diffutil;
import 'package:flutter/foundation.dart';
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

  /// @param items a list of items to construct widgets from. Must implement == correctly if no equalityChecker is set.
  /// @param builder builds a widget from a given item
  /// @param insertAnimationBuilder The animation builder for insert animations
  /// @param removeAnimationBuilder The animation builder for insert animations
  /// @param insertAnimationDuration The duration of the insert animation
  /// @param removeAnimationDuration The duration of the remove animation
  /// @param equalityChecker optional custom equality implementation, defaults to ==
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

  /// Construct a animated list from a list widgets with unique keys.
  ///
  /// @param children A List a Widgets with unique keys
  /// @param insertAnimationBuilder The animation builder for insert animations
  /// @param removeAnimationBuilder The animation builder for insert animations
  /// @param insertAnimationDuration The duration of the insert animation
  /// @param removeAnimationDuration The duration of the remove animation
  static DiffUtilSliverList<Widget> fromKeyedWidgetList({
    @required List<Widget> children,
    @required AnimatedDiffUtilWidgetBuilder insertAnimationBuilder,
    @required AnimatedDiffUtilWidgetBuilder removeAnimationBuilder,
    Duration insertAnimationDuration = const Duration(milliseconds: 300),
    Duration removeAnimationDuration = const Duration(milliseconds: 300),
  }) {
    //
    if (!kReleaseMode) {
      final Set<Key> keys = {};
      for (final Widget child in children) {
        if (!keys.add(child.key)) {
          throw FlutterError(
              'DiffUtilSliverList.fromKeyedWidgetList called with widgets that do not contain unique keys! '
              'This is an error as changed is this list cannot be animated reliably. Use unique keys or the default constructor. '
              'This duplicate key was ${child.key} in widget $child. '
              'Note: Hot reload is often broken when this happens, better use Hot Restart');
        }
      }
    }
    return DiffUtilSliverList<Widget>(
      items: children,
      builder: (context, widget) => widget,
      insertAnimationBuilder: insertAnimationBuilder,
      removeAnimationBuilder: removeAnimationBuilder,
      insertAnimationDuration: insertAnimationDuration,
      removeAnimationDuration: removeAnimationDuration,
      equalityChecker: (a, b) => a.key == b.key,
    );
  }

  @override
  _DiffUtilSliverListState<T> createState() => _DiffUtilSliverListState<T>();
}

class _DiffUtilSliverListState<T> extends State<DiffUtilSliverList<T>> {
  GlobalKey<SliverAnimatedListState> listKey;

  List<T> tempList;

  @override
  void initState() {
    super.initState();
    listKey = GlobalKey<SliverAnimatedListState>();
  }

  @override
  void didUpdateWidget(DiffUtilSliverList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final tempList = oldWidget.items;
    final newList = widget.items;

    final diff = diffutil
        .calculateListDiff<T>(tempList, newList,
            detectMoves: false, equalityChecker: widget.equalityChecker)
        .getUpdates(batch: true);

    this.tempList = tempList;
    diff.forEach(_onDiffUpdate);
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

  void _onChanged(int position, Object payload) {
    listKey.currentState.removeItem(
        position, (context, animation) => const SizedBox.shrink(),
        duration: const Duration());
    _onInserted(position, 1);
  }

  void _onInserted(final int position, final int count) {
    for (var loopCount = 0; loopCount < count; loopCount++) {
      listKey.currentState.insertItem(position + loopCount,
          duration: widget.insertAnimationDuration);
    }
    tempList.insertAll(position, List<T>.filled(count, null));
  }

  void _onRemoved(final int position, final int count) {
    for (var loopCount = 0; loopCount < count; loopCount++) {
      final oldItem = tempList[position + loopCount];
      // i purposefully remove the item at the same position on each
      // turn. the internal state is updated, so it removes the right item
      // actually. i only need to calculate the position of oldList
      // which might get ot of sync if count > 1.
      // the tempList is only updated at the end of the method for better performance
      listKey.currentState.removeItem(
          position,
          (context, animation) => widget.removeAnimationBuilder(
              context, animation, widget.builder(context, oldItem)),
          duration: widget.removeAnimationDuration);
    }
    tempList.removeRange(position, position + count);
  }

  void _onDiffUpdate(diffutil.DiffUpdate update) {
    update.when<void>(
        move: (_, __) =>
            throw UnimplementedError('moves are currently not supported'),
        insert: _onInserted,
        change: _onChanged,
        remove: _onRemoved);
  }
}
