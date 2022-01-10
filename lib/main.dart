import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'todoItemWidget.dart';
import 'globalVars.dart' as globals;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2-Do',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: '2-Do'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  final _itemWidgets = <TodoItemWidget>[];
  var tempPrefs;

  @override
  void initState() {
    super.initState();
    _getSavedData();
  }

  //TODO: Use something other than SharedPreferences
  Future<void> _getSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    var items = prefs.getStringList("Data");
    tempPrefs = prefs;
    if (items == null) {
      return;
    }

    globals.savedItems = items;

    for (var i = 0; i < items.length; i++) {
      if (items[i].isEmpty) {
        continue;
      }
      bool newIsDone = items[i][0] == '0' ? false : true;
      String newName = '';
      if (items[i].length > 1) {
        newName = items[i].substring(1, items[i].length);
      }

      TodoItemWidget newItem = TodoItemWidget(
        position: i,
        name: newName,
        isDone: newIsDone,
      );

      setState(() {
        _itemWidgets.add(newItem);
      });
    }
  }

  void _addTodoItem() {
    setState(() {
      TodoItemWidget item = TodoItemWidget(
        position: _itemWidgets.length,
      );
      _itemWidgets.add(item);
      _counter++;
    });

    globals.savedItems.add("");
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList("Data", globals.savedItems);
  }

  Widget _createRow(int index) {
    return Dismissible(
      child: _itemWidgets[index],
      key: UniqueKey(),
      onDismissed: (direction) {
        setState(() {
          _itemWidgets.removeAt(index);
          globals.savedItems.removeAt(index);
          for (var i = index; i < _itemWidgets.length; i++) {
            _itemWidgets[i].position = i;
          }
        });
        _saveData();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
          //padding: EdgeInsets.all(16.0),
          itemCount: _itemWidgets.length,
          itemBuilder: (context, position) {
            return _createRow(position);
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodoItem,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
