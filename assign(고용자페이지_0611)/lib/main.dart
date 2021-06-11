import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyAssignmentPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class Label {
  String labelName;
  Color labelColor;
  Label(this.labelName, this.labelColor);
}

class MyAssignmentPage extends StatefulWidget {
  const MyAssignmentPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyAssignmentPageState createState() => _MyAssignmentPageState();
}

class _MyAssignmentPageState extends State<MyAssignmentPage> {
  //final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final labelController = TextEditingController();
  final emailController = TextEditingController();

  final labels = <Label>[];

  ColorSwatch _tempMainColor;
  Color _tempShadeColor;
  ColorSwatch _mainColor = Colors.blue;
  Color _shadeColor = Colors.blue[800];

  void _openDialog(String title, Widget content) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(6.0),
            title: Text(title),
            content: content,
            actions: [
              ElevatedButton(
                  onPressed: Navigator.of(context).pop, child: Text("Cancel")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop;
                    setState(() => _mainColor = _tempMainColor);
                  },
                  child: Text("Submit")),
            ],
          );
        });
  }

  void _openColorPicker() async {
    _openDialog(
      "Color Picker",
      MaterialColorPicker(
        selectedColor: _mainColor,
        onMainColorChange: (color) => setState(() => _tempMainColor = color),
        onBack: () => print("Back button pressed"),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    subtitleController.dispose();
    labelController.dispose();
    super.dispose();
  }

  void addLabel(Label label) {
    setState(() {
      labels.add(label);
      labelController.text = '';
    });
  }

  void removeLabel(Label label) {
    setState(() {
      labels.remove(label);
    });
  }

  Widget _buildItemWidget(Label label, Color _mainColor) {
    return ListTile(
      onTap: () {},
      leading: CircleAvatar(
        backgroundColor: label.labelColor,
        child: Text("Main"),
      ),
      title: Text(
        label.labelName,
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete_forever),
        onPressed: () => removeLabel(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.all(12.0),
                    child: Column(children: [
                      TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "제목",
                        ),
                        controller: titleController,
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "부제목",
                        ),
                        controller: subtitleController,
                      ),
                    ]),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Text(
                          "label 설정",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(border: Border.all()),
                            child: ListView(
                              children: labels
                                  .map((label) =>
                                      _buildItemWidget(label, _mainColor))
                                  .toList(),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                      padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                      child: CircleAvatar(
                                        backgroundColor: _mainColor,
                                        child: Text("Main"),
                                      ))),
                              Expanded(
                                flex: 4,
                                child: TextField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "label 입력",
                                  ),
                                  controller: labelController,
                                ),
                              ),
                              Expanded(
                                  child: Container(
                                      padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                                      child: ElevatedButton(
                                        onPressed: () => addLabel(Label(
                                            labelController.text, _mainColor)),
                                        child: Text("추가"),
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.white,
                                          onPrimary: Colors.black,
                                          textStyle: TextStyle(fontSize: 11),
                                        ),
                                      ))),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ElevatedButton(
                                onPressed: _openColorPicker,
                                child: const Text("Select your label's color"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(child: Text("이미지 리스트 컨테이너")),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20, 10, 25, 10),
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "완료 시 받을 이메일",
                      ),
                      controller: emailController,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                          padding: EdgeInsets.fromLTRB(10, 0, 5, 10),
                          child: ElevatedButton(
                            onPressed: () => {},
                            child: Text("생성"),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Colors.black,
                              textStyle: TextStyle(fontSize: 13),
                            ),
                          )),
                      Container(
                          padding: EdgeInsets.fromLTRB(10, 0, 5, 10),
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text("취소"),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Colors.black,
                              textStyle: TextStyle(fontSize: 13),
                            ),
                          ))
                    ],
                  )),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
