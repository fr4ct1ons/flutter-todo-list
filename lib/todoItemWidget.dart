import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globalVars.dart' as globals;

class TodoItemWidget extends StatefulWidget {
  TodoItemWidget(
      {Key? key, required this.position, this.name = "", this.isDone = false})
      : super(key: key);

  int position = 0;
  String name;
  bool isDone;

  @override
  _TodoItemWidgetState createState() => _TodoItemWidgetState();
}

class _TodoItemWidgetState extends State<TodoItemWidget> {
  var textController = TextEditingController(text: "");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    textController = TextEditingController(text: widget.name);
    textController.addListener(_saveItemName);
  }

  void _saveItemName() {
    setState(() {
      widget.name = textController.text;
    });

    _saveData();
  }

  void _markIsDone(bool? val) {
    setState(() {
      widget.isDone = val!;
    });

    _saveData();
  }

  //TODO: Move the prefs part to initState, maybe?
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    globals.savedItems[widget.position] =
        "${widget.isDone ? 1 : 0}${widget.name}";
    prefs.setStringList("Data", globals.savedItems);
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: TextField(
        decoration: InputDecoration(labelText: 'To-do'),
        //onChanged: _saveItemName,
        controller: textController,
        enabled: !widget.isDone,
      ),
      value: widget.isDone,
      onChanged: (value) {
        setState(() {
          widget.isDone = value!;
        });
        _saveData();
      },
      controlAffinity: ListTileControlAffinity.leading,
      /*secondary: IconButton(
          icon: const Icon(Icons.restore_from_trash),
          onPressed: _onDelete,
        )*/
    );
  }
}
