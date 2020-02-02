import 'dart:math';

import 'package:diffutil_sliverlist/src/implicit_animated_sliver_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(const DiffUtilSliverListDemo());

class DiffUtilSliverListDemo extends StatefulWidget {
  const DiffUtilSliverListDemo({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _DiffUtilSliverListDemoState createState() => _DiffUtilSliverListDemoState();
}

class _DiffUtilSliverListDemoState extends State<DiffUtilSliverListDemo> {
  int _counter = 0;

  List<int> list = [0];

  void _incrementCounter() {
    setState(() {
      _counter++;

      if (Random().nextInt(3) > 0 || list.isEmpty) {
        list = [...list, _counter];
      } else {
        list = [...list];
        list.removeAt(Random().nextInt(list.length));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("DiffUtilSliverList Demo"),
        ),
        body: CustomScrollView(
          slivers: [
            DiffUtilSliverList.fromList<int>(
              list,
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
              removeAnimationDuration: const Duration(milliseconds: 300),
              insertAnimationDuration: const Duration(milliseconds: 120),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: Icon(Icons.view_list),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  static const colors = [
    Colors.deepOrangeAccent,
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.yellowAccent
  ];
}
