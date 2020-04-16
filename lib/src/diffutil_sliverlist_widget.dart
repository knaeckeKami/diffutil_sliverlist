import 'package:diffutil_dart/diffutil.dart' as diffutil;
import 'package:diffutil_sliverlist/src/sliver_list_update_adapter.dart';
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
              'This duplicate key was ${child.key} in widget  ${child}. '
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
