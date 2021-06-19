import 'dart:convert';
// import 'dart:html';
import "dart:io";
import 'dart:async';
import 'dart:developer';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import "package:firebase_storage/firebase_storage.dart";
import "package:firebase_auth/firebase_auth.dart";
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
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
  //라벨 이름 string 반환
  @override
  String toString() {
    return '${labelName}';
  }
}

class MyAssignmentPage extends StatefulWidget {
  const MyAssignmentPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyAssignmentPageState createState() => _MyAssignmentPageState();
}

class _MyAssignmentPageState extends State<MyAssignmentPage> {
  //final _formKey = GlobalKey<FormState>();
  //final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final nameController = TextEditingController();
  final titleController = TextEditingController();
  final work_uidController = TextEditingController();
  final labelController = TextEditingController();
  final emailController = TextEditingController();

  final labels = <Label>[];

  ColorSwatch _tempMainColor;
  Color _tempShadeColor;
  ColorSwatch _mainColor = Colors.blue;
  Color _shadeColor = Colors.blue[800];

  bool _initialized = false;
  bool _error = false;

  void initializerFlutterFire() async {
    try {
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  List<File> _images = [];
  File _image;
  final picker = ImagePicker();
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User _user;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  String _profileImageURL = "";

  @override
  void initState() {
    initializerFlutterFire();
    super.initState();
    //_prepareService();
  }

  void _prepareService() async {
    _user = await _firebaseAuth.currentUser;
  }

  Future<void> getImage() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery, maxHeight: 500, maxWidth: 500);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _images.add(_image);
        print(pickedFile);
        print(_image);
      } else {
        print("No image selected");
      }
    });
  }
  /*
  Future<void> _uploadImageToStorage(ImageSource source) async {
    await Firebase.initializeApp();
    try {
      print("try");
      final pickedFile = await ImagePicker().getImage(source: source);
      print("$pickedFile");
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print("No Image Selected");
          return;
        }
      });
      print("$_image");

      Reference storageReference =
          await _firebaseStorage.ref().child("profile/1");
      print("profile참조 완료");
      UploadTask storageUploadTask = storageReference.putFile(_image);

      String downloadURL = await storageReference.getDownloadURL();

      setState(() {
        _profileImageURL = downloadURL;
      });
    } on FirebaseAuthException catch (e) {
      print("error");
    }
  }*/

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
    nameController.dispose();
    titleController.dispose();
    work_uidController.dispose();
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
    if (_error) {
      return Text("error");
    }
    if (!_initialized) {
      return Text("initialized error");
    }
    return Scaffold(
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "사용자 이름",
                    ),
                    controller: nameController,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "제목",
                    ),
                    controller: titleController,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "작업 고유번호",
                    ),
                    controller: work_uidController,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Label List",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(border: Border.all()),
                    child: ListView(
                      primary: false,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: labels
                          .map((label) => _buildItemWidget(label, _mainColor))
                          .toList(),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: CircleAvatar(
                              backgroundColor: _mainColor,
                              child: Text("Main"),
                            )),
                      ),
                      Flexible(
                        flex: 5,
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "label 입력",
                          ),
                          controller: labelController,
                        ),
                      ),
                      Flexible(
                          child: SizedBox(
                        width: 10,
                      )),
                      Flexible(
                          child: ElevatedButton(
                        onPressed: () =>
                            addLabel(Label(labelController.text, _mainColor)),
                        child: Text("추가"),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          onPrimary: Colors.black,
                          textStyle: TextStyle(fontSize: 9),
                        ),
                      )),
                      Flexible(
                          child: SizedBox(
                        width: 10,
                      )),
                      Flexible(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _openColorPicker,
                            child: Text(
                              "label's color",
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Colors.black,
                              textStyle: TextStyle(fontSize: 11),
                            ),
                          )),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 10, 25, 10),
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "완료 시 받을 이메일",
                      ),
                      controller: emailController,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Container(
                            padding: EdgeInsets.fromLTRB(10, 0, 5, 10),
                            child: ElevatedButton(
                              onPressed: () => {
                                //Firestore.instance.collection(city).document('Attractions').updateData({"data": FieldValue.arrayUnion(obj)});
                                firestore.collection('users').add({
                                  'user name': '${nameController.text}',
                                  'title': '${titleController.text}',
                                  'work_uid': '${work_uidController.text}',
                                  // 'label': [labels[0], labels[1]],
                                  'email': '${emailController.text}',
                                  'timestamp': DateTime.now(),
                                  // 'name': FirebaseAuth.instance.currentUser!.displayName,
                                  // 'userId': FirebaseAuth.instance.currentUser!.uid,
                                }),
                              },
                              child: Text("생성"),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: Colors.black,
                                textStyle: TextStyle(fontSize: 13),
                              ),
                            )),
                      ),
                      Flexible(
                          child: Container(
                              padding: EdgeInsets.fromLTRB(10, 0, 5, 10),
                              child: ElevatedButton(
                                onPressed: () {},
                                child: Text("취소"),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                  onPrimary: Colors.black,
                                  textStyle: TextStyle(fontSize: 13),
                                ),
                              ))),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      IconButton(
                        icon: Icon(Icons.add_a_photo),
                        onPressed: () {
                          getImage();
                        },
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Center(
                        child: (_image != null)
                            ? CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.transparent,
                                child: ClipOval(
                                  child: Image.network(
                                    _image.path,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ))
                            : Text("No Image"),
                      ),
                    ],
                  ),
                ],
              ),
            )));
  }
}
