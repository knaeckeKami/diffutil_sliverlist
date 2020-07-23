import 'package:diffutil_dart/diffutil.dart';

void main() {
  final result = calculateListDiff([1, 2, 3], [3, 1, 0, 5]);

  result.dispatchUpdatesTo(MyConsumer());
}

class MyConsumer implements ListUpdateCallback {
  @override
  void onChanged(int position, int count, Object payload) {
    print("$position changed $count times: $payload");
  }

  @override
  void onInserted(int position, int count) {
    print("on position $position inserted $count times");
  }

  @override
  void onMoved(int fromPosition, int toPosition) {
    print("item moved from $fromPosition to $toPosition");
  }

  @override
  void onRemoved(int position, int count) {
    print("$count items removed at $position");
  }
}
