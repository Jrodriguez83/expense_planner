import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/new_transaction.dart';
import '../widgets/transaction_list.dart';
import '../models/transactions.dart';
import '../widgets/chart.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool switchValue = true;
  var _isLoading = false;

  

  List<Transaction> get _recentTransactions {
    final userTransactions = Provider.of<Transactions>(context).userTransaction;
    return userTransactions.where((transaction) {
      return transaction.date.isAfter(DateTime.now().subtract(
        Duration(days: 7),
      ));
    }).toList();
  }

  void _showAddTransactionCard(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return NewTransaction();
        });
  }

  List<Widget> _buildLandscapeMode(
    MediaQueryData mediaQuery,
    AppBar appBar,
    Widget transactionList,
  ) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Show Chart'),
          Switch.adaptive(
              activeColor: Theme.of(context).accentColor,
              value: switchValue,
              onChanged: (value) {
                setState(() {
                  switchValue = value;
                });
              }),
        ],
      ),
      switchValue
          ? Container(
              height: (mediaQuery.size.height -
                      appBar.preferredSize.height -
                      mediaQuery.padding.top) *
                  0.7,
              child: Chart(_recentTransactions),
            )
          : transactionList,
    ];
  }

  List<Widget> _buildPortraitMode(
    MediaQueryData mediaQuery,
    AppBar appBar,
    Widget transactionList,
  ) {
    return [
      Container(
        height: (mediaQuery.size.height -
                appBar.preferredSize.height -
                mediaQuery.padding.top) *
            0.3,
        child: Chart(_recentTransactions),
      ),
      transactionList
    ];
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });
    Provider.of<Transactions>(context, listen: false).fetchAndSetData().then((_){
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    

    final appBar = AppBar(
      title: Text('Personal Expenses'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => _showAddTransactionCard(context),
        )
      ],
    );

    var transactionList = Container(
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
              mediaQuery.padding.top) *
          0.7,
      child: TransactionList(),
    );

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddTransactionCard(context),
      ),
      appBar: appBar,
      drawer: AppDrawer(),
      body: _isLoading? Center(child: CircularProgressIndicator(),) :SingleChildScrollView(
          child: RefreshIndicator(
            onRefresh: () => Provider.of<Transactions>(context).fetchAndSetData(),
                      child: Column(
              children: <Widget>[
                if (isLandscape)
                  ..._buildLandscapeMode(mediaQuery, appBar, transactionList),
                if (!isLandscape)
                  ..._buildPortraitMode(mediaQuery, appBar, transactionList),
              ],
            ),
          ),
        ),
    );
  }
}