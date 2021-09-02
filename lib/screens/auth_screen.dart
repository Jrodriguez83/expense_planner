import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/auth.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).accentColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    color: Colors.blue.withOpacity(0.2),
                    padding: EdgeInsets.all(30),
                    margin: EdgeInsets.all(20),
                    child: Text(
                      'Personal Expenses',
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                  ),
                  AuthCard(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

enum AuthMode {
  SignUp,
  LogIn,
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  var _authMode = AuthMode.LogIn;
  var _formKey = GlobalKey<FormState>();
  var _passwordController = TextEditingController();
  var _isLoading = false;
  var _authData = {
    'email': '',
    'password': '',
  };

  void _changeAuthMode() {
    if (_authMode == AuthMode.SignUp) {
      setState(() {
        _authMode = AuthMode.LogIn;
      });
    } else {
      setState(() {
        _authMode = AuthMode.SignUp;
      });
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    setState(() {
      _isLoading = true;
    });

    if (_authMode == AuthMode.SignUp) {
      await Provider.of<Auth>(context, listen: false).signUp(
        _authData['email'],
        _authData['password'],
      );
    } else {
      await Provider.of<Auth>(context, listen: false).signIn(
        _authData['email'],
        _authData['password'],
      );
    }

    var error = await Provider.of<Auth>(context)
        .errorMessage(_authData['email'], _authData['password'], _authMode == AuthMode.LogIn ? 'signin':'signup');
    if(error != null){
    var errorMessage = 'An error has occured';
    if (error.contains('EMAIL_EXISTS')) {
      errorMessage = 'This email address is already in use.';
    } else if (error.contains('INVALID_EMAIL')) {
      errorMessage = 'This is not a valid email address';
    } else if (error.contains('WEAK_PASSWORD')) {
      errorMessage = 'This password is too weak.';
    } else if (error.contains('EMAIL_NOT_FOUND')) {
      errorMessage = 'Could not find a user with that email.';
    } else if (error.contains('INVALID_PASSWORD')) {
      errorMessage = 'Invalid password.';
    }
    setState(() {
      _isLoading = false;
    });
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('An error has happened'),
              content: Text(errorMessage),
            ));
  }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: deviceSize.width * 0.1),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (!value.contains('@') || value.isEmpty) {
                      return 'Invalid email';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password'),
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length <= 6) {
                      return 'Password is too short';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                if (_authMode == AuthMode.SignUp)
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    validator: (value) {
                      if (value.isEmpty || value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: _isLoading ? Center(child: CircularProgressIndicator(),): FlatButton(
                    padding: EdgeInsets.all(10),
                    child:
                        Text(_authMode == AuthMode.LogIn ? 'LOGIN' : 'SIGNUP'),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    onPressed: () {
                      _submitData();
                    },
                  ),
                ),
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.LogIn ? 'SIGNUP' : 'LOGIN'}  INSTEAD'),
                  onPressed: _changeAuthMode,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
