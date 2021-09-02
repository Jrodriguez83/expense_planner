import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../models/transactions.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var _isLoading = false;

  void _saveColor(String color) {
    setState(() {
      _isLoading = true;
    });

    Provider.of<Transactions>(context).saveThemeData(color).then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text('Chage theme color'),
            Container(
              margin: EdgeInsets.all(10),
              color: Colors.red,
              height: 30,
              child: GestureDetector(
                onTap: () => _saveColor('red'),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              color: Colors.purple,
              height: 30,
              child: GestureDetector(
                onTap: () => _saveColor('purple'),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              color: Colors.green,
              height: 30,
              child: GestureDetector(
                onTap: () => _saveColor('green'),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              color: Colors.blue,
              height: 30,
              child: GestureDetector(
                onTap: () => _saveColor('blue'),
              ),
            ),
            if (_isLoading)
              Container(
                margin: EdgeInsets.all(15),
                padding: EdgeInsets.all(10),
                child: Text('Loading color...'),
              )
          ],
        ),
      ),
    );
  }
}
