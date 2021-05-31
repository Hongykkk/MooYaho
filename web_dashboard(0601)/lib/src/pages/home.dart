// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js';

import 'package:flutter/material.dart';
import "dart:html";
import "dart:math";
import "dart:ui" as ui;
import "package:flutter/foundation.dart";
import "package:flutter/services.dart" show rootBundle;
import "dart:async";
import "dart:typed_data";
import 'next.dart';

import '../widgets/third_party/adaptive_scaffold.dart';
import 'dashboard.dart';
import 'entries.dart';

BuildContext homecontext;

class HomePage extends StatefulWidget {
  HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/next': (context) => NextPage(),
        '/board': (context) => DashboardPage(),
      },
      title: '무야호 그만큼 신나신다는거조',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AdaptiveScaffold(
        title: Text('무야호 그만큼 신나신다는거조'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              style: TextButton.styleFrom(primary: Colors.white),
              onPressed: () => _handleSignOut(),
              child: Text('Sign Out'),
            ),
          )
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
        floatingActionButton:
            _hasFloatingActionButton ? _buildFab(context) : null,
      ),
    );
  }

  bool get _hasFloatingActionButton {
    if (_pageIndex == 2) return false;
    return true;
  }

  FloatingActionButton _buildFab(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () => _handleFabPressed(),
    );
  }

  void _handleFabPressed() {}

  Future<void> _handleSignOut() async {}

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
