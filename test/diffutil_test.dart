import 'package:diffutil_sliverlist/diffutil_sliverlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("does not allow non-unique keys when using fromKeyedWidgetList",
      (tester) async {
    await tester.pumpWidget(
      Builder(
        builder: (context) => DiffUtilSliverList.fromKeyedWidgetList(
          children: [
            Container(
              key: const Key('a'),
            ),
            Container(
              key: const Key('a'),
            ),
          ],
          insertAnimationBuilder: (context, animation, widget) => widget,
          removeAnimationBuilder: (context, animation, widget) => widget,
        ),
      ),
    );

    final dynamic error = tester.takeException();

    expect(error, isAssertionError);
  });

  testWidgets("does not throw error when keys are unique", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomScrollView(
          slivers: [
            DiffUtilSliverList.fromKeyedWidgetList(
              children: [
                Container(
                  key: const Key('a'),
                ),
                Container(
                  key: const Key('b'),
                ),
              ],
              insertAnimationBuilder: (context, animation, widget) => widget,
              removeAnimationBuilder: (context, animation, widget) => widget,
            ),
          ],
        ),
      ),
    );

    final dynamic error = tester.takeException();

    expect(error, isNull);
  });

  testWidgets("insert builder called", (tester) async {
    var insertCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: CustomScrollView(
          slivers: [
            DiffUtilSliverList.fromKeyedWidgetList(
              children: [
                Container(
                  key: const Key('a'),
                ),
              ],
              insertAnimationBuilder: (context, animation, widget) => widget,
              removeAnimationBuilder: (context, animation, widget) => widget,
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CustomScrollView(
          slivers: [
            DiffUtilSliverList.fromKeyedWidgetList(
              children: [
                Container(
                  key: const Key('a'),
                ),
                Container(
                  key: const Key('b'),
                ),
              ],
              insertAnimationBuilder: (context, animation, widget) {
                if (animation.isCompleted) {
                  expect(widget.key, const Key('a'));
                } else {
                  expect(widget.key, const Key('b'));
                }
                insertCount++;
                return widget;
              },
              removeAnimationBuilder: (context, animation, widget) {
                fail("removeAnimationBuilder should not be called");
              },
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(insertCount, 2);
  });

  testWidgets("remove builder called", (tester) async {
    var removeCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: CustomScrollView(
          slivers: [
            DiffUtilSliverList.fromKeyedWidgetList(
              children: [
                Container(
                  key: const Key('a'),
                ),
                Container(
                  key: const Key('b'),
                ),
              ],
              insertAnimationBuilder: (context, animation, widget) => widget,
              removeAnimationBuilder: (context, animation, widget) => widget,
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CustomScrollView(
          slivers: [
            DiffUtilSliverList.fromKeyedWidgetList(
              children: [
                Container(
                  key: const Key('b'),
                ),
              ],
              insertAnimationBuilder: (context, animation, widget) {
                expect(animation.isCompleted, isTrue);
                return widget;
              },
              removeAnimationBuilder: (context, animation, widget) {
                expect(widget.key, const Key('a'));
                expect(animation.isCompleted, isFalse);
                removeCount++;
                return widget;
              },
            ),
          ],
        ),
      ),
    );

    expect(removeCount, 1);
  });
}
