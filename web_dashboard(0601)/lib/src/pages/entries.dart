// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../api/api.dart';

class EntriesPage extends StatefulWidget {
  @override
  _EntriesPageState createState() => _EntriesPageState();
}

class _EntriesPageState extends State<EntriesPage> {
  @override
  Widget build(BuildContext context) {
    return Row();
  }
}

class EntriesList extends StatefulWidget {
  final Category category;
  final EntryApi api;

  EntriesList({
    @required this.category,
    @required this.api,
  }) : super(key: ValueKey(category.id));

  @override
  _EntriesListState createState() => _EntriesListState();
}

class _EntriesListState extends State<EntriesList> {
  @override
  Widget build(BuildContext context) {
    return Row();
  }

  Widget _buildLoadingIndicator() {
    return Center(child: CircularProgressIndicator());
  }
}

class EntryTile extends StatelessWidget {
  final Category category;
  final Entry entry;

  EntryTile({
    this.category,
    this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return Row();
  }
}
