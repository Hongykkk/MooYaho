import 'package:flutter/material.dart';
import 'home.dart';

class Assignment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      routes: {
        '/home': (context) => HomePage(),
      },
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

class MyAssignmentPage extends StatefulWidget {
  const MyAssignmentPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyAssignmentPageState createState() => _MyAssignmentPageState();
}

class _MyAssignmentPageState extends State<MyAssignmentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text("Hello"),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Text("Hello"),
              ],
            ),
          )
        ],
      ),
    );
  }
}
