import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_event.dart';
import '../blocs/transaction/transaction_state.dart';
import '../models/transaction.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  double _amount = 0;
  bool _isExpense = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transações')),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                if (state is TransactionLoading) return const Center(child: CircularProgressIndicator());
                if (state is TransactionLoaded) {
                  return ListView.builder(
                    itemCount: state.transactions.length,
                    itemBuilder: (context, index) {
                      final tx = state.transactions[index];
                      return ListTile(
                        title: Text(tx.title),
                        subtitle: Text(tx.date.toIso8601String()),
                        trailing: Text(tx.amount.toStringAsFixed(2)),
                        onLongPress: () {
                          context.read<TransactionBloc>().add(DeleteTransaction(tx.id!));
                        },
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Título'),
                    onSaved: (v) => _title = v ?? '',
                    validator: (v) => (v==null || v.isEmpty) ? 'Obrigatório' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Valor'),
                    keyboardType: TextInputType.number,
                    onSaved: (v) => _amount = double.tryParse(v ?? '0') ?? 0,
                    validator: (v) => (v==null || v.isEmpty) ? 'Obrigatório' : null,
                  ),
                  Row(
                    children: [
                      const Text('Despesa'),
                      Switch(
                        value: _isExpense,
                        onChanged: (v) => setState(() => _isExpense = v),
                      ),
                      const Text('Receita'),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        final tx = TransactionModel(title: _title, amount: _amount, date: DateTime.now(), categoryId: 1, isExpense: _isExpense);
                        context.read<TransactionBloc>().add(AddTransaction(tx));
                      }
                    },
                    child: const Text('Adicionar'),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
