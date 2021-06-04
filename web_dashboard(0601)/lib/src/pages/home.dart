// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'next.dart';
import 'auth_dialog.dart';

import '../widgets/third_party/adaptive_scaffold.dart';
import 'dashboard.dart';
import 'entries.dart';
import '../utils/auth.dart';

BuildContext homecontext;

class HomePage extends StatefulWidget {
  HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pageIndex = 0;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/next': (context) => NextPage(),
        '/board': (context) => DashboardPage(),
        // '/login': (context) => LoginPage(),
      },
      title: '무야호 그만큼 신나신다는거조',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AdaptiveScaffold(
        title: Text('무야호 그만큼 신나신다는거조'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                userEmail == null
                    ? Container(
                        child: ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AuthDialog(),
                              );
                            },
                            icon: Icon(Icons.account_circle, size: 20),
                            label: Text("Sign In")),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: imageUrl != null
                                ? NetworkImage(imageUrl)
                                : null,
                            child: imageUrl == null
                                ? Icon(
                                    Icons.account_circle,
                                    size: 40,
                                  )
                                : Container(),
                          ),
                          SizedBox(width: 10),
                          Text(
                            name ?? userEmail,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white70,
                            ),
                          )
                        ],
                      ),
                SizedBox(width: 20),
                userEmail != null
                    ? Container(
                        child: ElevatedButton(
                          onPressed: _isProcessing
                              ? null
                              : () async {
                                  setState(() {
                                    _isProcessing = true;
                                  });
                                  await signOut().then((result) {
                                    print(result);
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        fullscreenDialog: true,
                                        builder: (context) => HomePage(),
                                      ),
                                    );
                                  }).catchError((error) {
                                    print('Sign Out Error: $error');
                                  });
                                  setState(() {
                                    _isProcessing = false;
                                  });
                                },
                          child: _isProcessing
                              ? CircularProgressIndicator()
                              : Text(
                                  'Sign out',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      )
                    : Container(),
                userEmail != null ? SizedBox(height: 20) : Container(),
              ],
            ),
          ),
        ],
        currentIndex: _pageIndex,
        destinations: [
          AdaptiveScaffoldDestination(title: 'Home', icon: Icons.home),
          AdaptiveScaffoldDestination(title: 'Entries', icon: Icons.list),
          AdaptiveScaffoldDestination(title: 'Settings', icon: Icons.settings),
        ],
        body: _pageAtIndex(_pageIndex),
        onNavigationIndexChange: (newIndex) {
          setState(() {
            _pageIndex = newIndex;
          });
        },
        // floatingActionButton:
        //     _hasFloatingActionButton ? _buildFab(context) : null,
      ),
    );
  }

  // bool get _hasFloatingActionButton {
  //   if (_pageIndex == 2) return false;
  //   return true;
  // }

  // FloatingActionButton _buildFab(BuildContext context) {
  //   return FloatingActionButton(
  //     child: Icon(Icons.add),
  //     onPressed: () => _handleFabPressed(),
  //   );
  // }

  // void _handleFabPressed() {}

  // Future<void> _handleSignOut() async {}

  static Widget _pageAtIndex(int index) {
    if (index == 0) {
      return DashboardPage();
    }

    if (index == 1) {
      return EntriesPage();
    }

    return Center(child: Text('Settings page'));
  }
}
