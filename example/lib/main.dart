import 'dart:math';

import 'package:diffutil_sliverlist/diffutil_sliverlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(const DiffUtilSliverListDemo());

class DiffUtilSliverListDemo extends StatefulWidget {
  const DiffUtilSliverListDemo({super.key});

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
        list.add(_counter);
      } else {
        list.removeAt(Random().nextInt(list.length));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          appBar: AppBar(
            bottom:
                TabBar(tabs: [Tab(text: "example 1"), Tab(text: "example 2")]),
          ),
          body: TabBarView(
            children: [
              Scaffold(
                  floatingActionButton: FloatingActionButton(
                    onPressed: _incrementCounter,
                    tooltip: 'Increment',
                    child: Icon(Icons.view_list),
                  ), // This tr
                  body: CustomScrollView(
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
                        removeAnimationDuration:
                            const Duration(milliseconds: 300),
                        insertAnimationDuration:
                            const Duration(milliseconds: 120),
                      ),
                    ],
                  )),
              CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "FIRST LIST",
                          style: Theme.of(context).textTheme.subtitle2,
                        )),
                  ),
                  ExpandableLists(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "SECOND LIST",
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                  ),
                  ExpandableLists(),
                ],
              ),
            ],
          ),
        ),
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

class ExpandableLists extends StatefulWidget {
  @override
  _ExpandableListsState createState() => _ExpandableListsState();
}

class _ExpandableListsState extends State<ExpandableLists> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return DiffUtilSliverList.fromKeyedWidgetList(
      children: [
        ListTile(
          key: Key("1"),
          title: Text("first"),
          trailing: Icon(Icons.chevron_right),
        ),
        ListTile(
          key: Key("2"),
          title: Text("second"),
          trailing: Icon(Icons.chevron_right),
        ),
        if (this.expanded)
          for (int i = 3; i < 6; i++)
            ListTile(
              key: Key(i.toString()),
              title: Text("index: $i"),
              trailing: Icon(Icons.chevron_right),
            ),
        ListTile(
          key: Key("expand_collapse"),
          onTap: () => setState(() {
            expanded = !expanded;
          }),
          title: Text(
            expanded ? "collapse" : "expand",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more),
        )
      ],
      insertAnimationBuilder: (context, animation, child) => SizeTransition(
          sizeFactor: animation.drive(Tween<double>(begin: 0.7, end: 1)),
          axisAlignment: 0,
          child: FadeTransition(
            opacity: animation,
            child: child,
          )),
      removeAnimationBuilder: (context, animation, child) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          axisAlignment: 0,
          child: child,
        ),
      ),
    );
  }
}
