import 'package:expense_plannerr/widgets/new_transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transactions.dart';

class TransactionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final transactions = Provider.of<Transactions>(context, listen: true);
    final userTransactions = transactions.userTransaction;
    return Container(
      child: userTransactions.isEmpty
          ? LayoutBuilder(
              builder: ((context, constraints) {
                return Column(
                  children: <Widget>[
                    Text(
                      'No data has been entered',
                      style: Theme.of(context).textTheme.title,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: constraints.maxHeight * 0.6,
                      child: Image.asset(
                        'assets/images/waiting.png',
                        fit: BoxFit.cover,
                      ),
                    )
                  ],
                );
              }),
            )
          : ListView.builder(
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (ctx) =>
                            NewTransaction(userTransactions[index].id));
                  },
                  child: TransactionItem(
                    transaction: userTransactions[index],
                    transactions: transactions,
                    index: index,
                  ),
                );
              },
              itemCount: userTransactions.length,
            ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  const TransactionItem({
    Key key,
    this.transaction,
    this.transactions,
    this.index
  }) : super(key: key);

  
  final Transaction transaction;
  final int index;
  final Transactions transactions;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          child: Text('\$${transaction.amount}'),
        ),
        title: Text(
          '${transaction.title}',
          style: Theme.of(context).textTheme.title,
        ),
        subtitle:
            Text('${DateFormat.yMMMd().format(transaction.date)}'),
        trailing: MediaQuery.of(context).size.width > 460
            ? FlatButton.icon(
                onPressed: () =>
                    transactions.delete(index, transaction.id),
                icon: Icon(
                  Icons.delete,
                  color: Theme.of(context).errorColor,
                ),
                label: Text('Delete'),
              )
            : IconButton(
                icon: Icon(Icons.delete),
                color: Theme.of(context).errorColor,
                onPressed: () =>
                    transactions.delete(index, transaction.id),
              ),
      ),
    );
  }
}
