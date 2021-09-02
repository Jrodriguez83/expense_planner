import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/auth.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            AppBar(
              title: Text('Personal Expenses'),
              automaticallyImplyLeading: false,
            ),
            SizedBox(
              height: 4,
            ),
            ListTile(
              leading: Icon(Icons.attach_money),
              title: Text('Log and check expenses', style: TextStyle(
                fontSize: 20
              ),),
              onTap: () => Navigator.of(context).pushReplacementNamed('/')
            ),
            SizedBox(
              height: 4,
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings', style: TextStyle(
                fontSize: 20
              )),
              onTap: () => Navigator.of(context).pushReplacementNamed('settings_screen'),
            ),
            SizedBox(
              height: 4,
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('LogOut', style: TextStyle(
                fontSize: 20
              )),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/');
                Provider.of<Auth>(context).logOut();
              },
            )
          ],
        ),
      ),
    );
  }
}
