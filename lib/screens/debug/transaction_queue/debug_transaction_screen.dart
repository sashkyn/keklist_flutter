import 'package:flutter/material.dart';
import 'package:keklist/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/helpers/bloc_utils.dart';
import 'package:keklist/helpers/extensions/dispose_bag.dart';

final class DebugTransactionsScreen extends StatefulWidget {
  const DebugTransactionsScreen({super.key});

  @override
  State<DebugTransactionsScreen> createState() => DebugTransactionsScreenState();
}

final class DebugTransactionsScreenState extends State<DebugTransactionsScreen> with DisposeBag {
  final List<String> _transactions = [];

  @override
  void initState() {
    super.initState();

    subscribeTo<MindBloc>(onNewState: (state) {
      switch (state) {
        case MindTransactions state:
          setState(() {
            _transactions
              ..clear()
              ..addAll(state.transactions.map((e) => e.toString()));
          });
      }
    })?.disposed(by: this);

    sendEventTo<MindBloc>(MindGetTransactionList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: ListView.builder(
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_transactions[index]),
          );
        },
      ),
    );
  }
}
