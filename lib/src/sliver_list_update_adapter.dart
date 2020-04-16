import 'package:diffutil_dart/diffutil.dart' as diffutil;
import 'package:diffutil_sliverlist/src/diffutil_sliverlist_widget.dart';
import 'package:flutter/widgets.dart';

class ListUpdateCallBackToSliverAnimatedListKeyAdapter<T>
    implements diffutil.ListUpdateCallback {
  final GlobalKey<SliverAnimatedListState> stateKey;
  final AnimatedDiffUtilWidgetBuilder removeAnimationBuilder;
  final DiffUtilWidgetBuilder<T> builder;
  final List<T> oldList;
  final Duration insertDuration;
  final Duration removeDuration;

  ListUpdateCallBackToSliverAnimatedListKeyAdapter(
      this.stateKey,
      this.builder,
      this.oldList,
      this.removeAnimationBuilder,
      this.insertDuration,
      this.removeDuration);

  @override
  void onChanged(int position, int count, Object payload) {
    while (count > 0) {
      stateKey.currentState.removeItem(
          position, (context, animation) => const SizedBox.shrink(),
          duration: const Duration());
      onInserted(position, 1);
      count--;
      position++;
    }
  }

  @override
  void onInserted(final int position, final int count) {
    for (var loopCount = 0; loopCount < count; loopCount++) {
      stateKey.currentState
          .insertItem(position + loopCount, duration: insertDuration);
    }
    oldList.insertAll(position, List<T>.filled(count, null));
  }

  @override
  void onMoved(int fromPosition, int toPosition) {
    /// [SliverAnimatedList] does not support moves
    throw UnimplementedError();
  }

  @override
  void onRemoved(final int position, final int count) {
    for (var loopCount = 0; loopCount < count; loopCount++) {
      final oldItem = oldList[position + loopCount];
      // i purposfully remove the item at the same position on each
      // turn. the internal state is updated, so it removes the right item
      // actually. i only need to calculate the positon of oldLost
      // which might get ot of sync if count > 1.
      // the oldList is only updated at the end of the method for better performance
      stateKey.currentState.removeItem(
          position,
          (context, animation) => removeAnimationBuilder(
              context, animation, builder(context, oldItem)),
          duration: removeDuration);
    }
    oldList.removeRange(position, position + count);
  }
}
