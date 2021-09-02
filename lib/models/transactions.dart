import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;

  Transaction({
    @required this.id,
    @required this.title,
    @required this.amount,
    @required this.date,
  });
}

class Transactions with ChangeNotifier {
  String token;
  String userId;
  var themeData = {'name': ''};

  Transactions({@required this.token, @required this.userId});

  final List<Transaction> _userTransactions = [];

  List<Transaction> get userTransaction {
    return [..._userTransactions];
  }

  Future<void> fetchAndSetData() async {
    final url =
        'https://personal-expenses-8d51b.firebaseio.com/transactions.json?auth=$token&orderBy="creatorId"&equalTo="$userId"';

    try {
      loadThemeData();
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      _userTransactions.clear();
      extractedData.forEach((transactionId, transactionData) {
        _userTransactions.add(Transaction(
          id: transactionId,
          title: transactionData['title'],
          amount: transactionData['amount'],
          date: DateTime.parse(transactionData['date']),
        ));
      });
    } catch (error) {
      print('Error: ${error.toString()}');
      throw error;
    }

    notifyListeners();
  }

  Future<void> addNewTransaction(
      String title, double amount, DateTime date) async {
    final url =
        'https://personal-expenses-8d51b.firebaseio.com/transactions.json?auth=$token';

    final response = await http.post(url,
        body: json.encode({
          'title': title,
          'amount': amount,
          'date': date.toIso8601String(),
          'creatorId': userId
        }));

    _userTransactions.add(Transaction(
      id: json.decode(response.body)['name'],
      title: title,
      amount: amount,
      date: date,
    ));

    notifyListeners();
  }

  Future<void> updateData(
      String transId, String title, double amount, DateTime date) async {
    final url =
        'https://personal-expenses-8d51b.firebaseio.com/transactions/$transId.json?auth=$token';

    final index = userTransaction.indexWhere((test) => test.id == transId);

    if (index >= 0) {
      await http.patch(url, body: json.encode({
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
      }));
      userTransaction[index] = Transaction(
        id: transId,
        title: title,
        amount: amount,
        date: date,
      );
    fetchAndSetData();
    }
    notifyListeners();
  }

  Future<void> delete(int index, String transId) async {
    final url =
        'https://personal-expenses-8d51b.firebaseio.com/transactions/$transId.json?auth=$token';

    await http.delete(url);

    _userTransactions.removeAt(index);

    notifyListeners();
  }

  Future<void> saveThemeData(String color) async {
    var url =
        'https://personal-expenses-8d51b.firebaseio.com/personalization.json?auth=$token';

    themeData['name'] = color;

    var response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      response = await http.post(url,
          body: json.encode({
            'color': themeData['name'],
            'creatorId': userId,
          }));
      notifyListeners();
      return;
    }
    var loadedData = {
      'name': '',
      'color': '',
      'creatodId': '',
    };
    extractedData.forEach((perId, perData) {
      loadedData['name'] = perId;
      loadedData['color'] = perData['color'];
      loadedData['creatorId'] = perData['creatorId'];
    });
    if (loadedData['creatorId'].contains(userId)) {
      url =
          'https://personal-expenses-8d51b.firebaseio.com/personalization/${loadedData['name']}.json?auth=$token';
      response = await http.patch(url,
          body: json.encode({
            'color': themeData['name'],
          }));
    }
    notifyListeners();
  }

  Future<void> loadThemeData() async {
    final url =
        'https://personal-expenses-8d51b.firebaseio.com/personalization.json?auth=$token&orderBy="creatorId"&equalTo="$userId"';

    final response = await http.get(url);

    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    var loadedData = {
      'name': '',
      'color': '',
      'creatodId': '',
    };
    extractedData.forEach((perId, perData) {
      loadedData['name'] = perId;
      loadedData['color'] = perData['color'];
      loadedData['creatorId'] = perData['creatorId'];
    });

    saveThemeData(loadedData['color']);
  }

  MaterialColor themeColor() {
    switch (themeData['name']) {
      case 'red':
        return Colors.red;
        break;
      case 'purple':
        return Colors.purple;
        break;
      case 'green':
        return Colors.green;
        break;
      case 'blue':
        return Colors.blue;
      default:
        return Colors.purple;
    }
  }
}
