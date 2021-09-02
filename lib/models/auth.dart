import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expirationDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_token != null &&
        _expirationDate.isAfter(DateTime.now()) &&
        _expirationDate != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<String> errorMessage(
      String email, String password, String action) async {
    final auth = {'signin': 'signInWithPassword', 'signup': 'signUp'};

    var authMode = auth[action];
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$authMode?key=AIzaSyBBjjrno7Dd-xLGd9rByHzMUYbMie9Gnao';

    final response = await http.post(url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }));

    final responseData = json.decode(response.body);

    if (responseData['error'] != null) {
      return responseData['error']['message'];
    }
    return null;
  }

  Future<void> _authenticate(
      String email, String password, String authMode) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$authMode?key=AIzaSyBBjjrno7Dd-xLGd9rByHzMUYbMie9Gnao';

    final response = await http.post(url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }));

    final responseData = json.decode(response.body);

    if (responseData['error'] != null) {
      return;
    }
    _token = responseData['idToken'];
    _userId = responseData['localId'];
    _expirationDate = DateTime.now().add(
      Duration(
        seconds: int.parse(responseData['expiresIn']),
      ),
    );

    final preferences = await SharedPreferences.getInstance();
    final encodedData = json.encode({
      'token': _token,
      'userId': _userId,
      'expirationDate': _expirationDate.toIso8601String(),
    });
    preferences.setString('userData', encodedData);

    _autoLogout();
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    _authenticate(email, password, 'signUp');
  }

  Future<void> signIn(String email, String password) async {
    _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final preferences = await SharedPreferences.getInstance();
    if (!preferences.containsKey('userData')) {
      return false;
    }
    final extractedData =
        json.decode(preferences.getString('userData')) as Map<String, dynamic>;
    final expirationDate = DateTime.parse(extractedData['expirationDate']);
    print('$expirationDate');

    if (expirationDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedData['token'];
    _userId = extractedData['userId'];
    _expirationDate = expirationDate;
    notifyListeners();
    return true;
  }

  Future<void> logOut() async {
    _userId = null;
    _token = null;
    _expirationDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();

    preferences.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expirationDate.difference(DateTime.now()).inSeconds;

    _authTimer = Timer(Duration(seconds: timeToExpiry), logOut);
  }
}
