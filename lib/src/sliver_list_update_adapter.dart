import 'package:diffutil_dart/diffutil.dart' as diffutil;
import 'package:flutter/widgets.dart';

class ListUpdateCallBackToSliverAnimatedListKeyAdapter<T, L>
    implements diffutil.ListUpdateCallback {
  final GlobalKey<SliverAnimatedListState> stateKey;
  final Widget Function(BuildContext, Animation<double>, Widget)
      removeAnimationBuilder;
  final Widget Function(BuildContext, T) builder;
  final L oldList;
  final T Function(L, int) getValueByIndex;
  final Duration insertDuration;
  final Duration removeDuration;

  ListUpdateCallBackToSliverAnimatedListKeyAdapter(
      this.stateKey,
      this.builder,
      this.oldList,
      this.removeAnimationBuilder,
      this.insertDuration,
      this.getValueByIndex,
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
  void onInserted(int position, int count) {
    while (count > 0) {
      stateKey.currentState.insertItem(position, duration: insertDuration);
      count--;
      position++;
    }
  }

  @override
  void onMoved(int fromPosition, int toPosition) {
    /// [SliverAnimatedList] does not support moves
    throw UnimplementedError();
  }

  @override
  void onRemoved(int position, int count) {
    while (count > 0) {
      stateKey.currentState.removeItem(
          position,
          (context, animation) => removeAnimationBuilder(context, animation,
              builder(context, getValueByIndex(oldList, position))),
          duration: removeDuration);
      count--;
    }
  }
}
