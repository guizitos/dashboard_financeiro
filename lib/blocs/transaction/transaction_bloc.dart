import 'package:bloc/bloc.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';
import '../../data/db_provider.dart';
import '../../models/transaction.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc() : super(TransactionInitial()) {
    on<LoadTransactions>((event, emit) async {
      emit(TransactionLoading());
      try {
        final db = await DBProvider.db.database;
        final res = await db.query('transactions', orderBy: 'date DESC');
        final txs = res.map((e) => TransactionModel.fromMap(e)).toList();
        emit(TransactionLoaded(txs));
      } catch (e) {
        emit(TransactionError(e.toString()));
      }
    });

    on<AddTransaction>((event, emit) async {
      if (state is TransactionLoaded) {
        final db = await DBProvider.db.database;
        await db.insert('transactions', event.transaction.toMap());
        add(LoadTransactions());
      }
    });

    on<UpdateTransaction>((event, emit) async {
      if (state is TransactionLoaded) {
        final db = await DBProvider.db.database;
        await db.update('transactions', event.transaction.toMap(), where: 'id = ?', whereArgs: [event.transaction.id]);
        add(LoadTransactions());
      }
    });

    on<DeleteTransaction>((event, emit) async {
      if (state is TransactionLoaded) {
        final db = await DBProvider.db.database;
        await db.delete('transactions', where: 'id = ?', whereArgs: [event.id]);
        add(LoadTransactions());
      }
    });
  }
}
