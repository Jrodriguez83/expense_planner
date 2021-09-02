import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transactions.dart';

class NewTransaction extends StatefulWidget {
  final String id;
  NewTransaction([this.id]);
  @override
  _NewTransactionState createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  var _isUpdating = false;
  Transaction transToEdit;

  DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      transToEdit = Provider.of<Transactions>(context, listen: false)
          .userTransaction
          .firstWhere((test) => test.id == widget.id);

      titleController.text = transToEdit.title;
      amountController.text = transToEdit.amount.toString();
      _selectedDate = transToEdit.date;
      _isUpdating = true;
    }
  }

  void submitData() {
    if (amountController.text.isEmpty) {
      return;
    }
    final enteredTitle = titleController.text;
    final enteredAmount = double.parse(amountController.text);

    if (enteredTitle.isEmpty || enteredAmount <= 0 || _selectedDate == null) {
      return;
    }
    if (_isUpdating) {
    
      Provider.of<Transactions>(context, listen: false)
          .updateData(widget.id, enteredTitle, enteredAmount, _selectedDate);
          Navigator.of(context).pop();
      return;
    }
    Provider.of<Transactions>(context, listen: false)
        .addNewTransaction(enteredTitle, enteredAmount, _selectedDate);

    Navigator.of(context).pop();
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((datePicked) {
      if (datePicked == null) {
        return;
      }
      setState(() {
        _selectedDate = datePicked;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        child: Container(
          padding: EdgeInsets.only(
            top: 10,
            left: 10,
            right: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 10,
          ),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                ),
                Container(
                  height: 60,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                            _selectedDate == null
                                ? 'No Date'
                                : 'Picked Date: ${DateFormat.yMd().format(_selectedDate)}',
                            style: TextStyle(
                              fontSize: 20,
                            )),
                      ),
                      FlatButton(
                        child: Text(
                          'Select Date',
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).primaryColorDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          _showDatePicker();
                        },
                      )
                    ],
                  ),
                ),
                RaisedButton(
                  color: Theme.of(context).primaryColor,
                  textColor: Theme.of(context).textTheme.button.color,
                  child: Text(_isUpdating ? 'Update Transaction':'Add Transaction'),
                  onPressed: () => submitData(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
