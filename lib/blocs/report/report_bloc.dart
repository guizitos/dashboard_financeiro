import 'package:bloc/bloc.dart';
import '../../data/db_provider.dart';
import '../../models/transaction.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  ReportBloc() : super(ReportInitial()) {
    on<GenerateReport>((event, emit) async {
      emit(ReportLoading());
      try {
        final db = await DBProvider.db.database;
        final res = await db.query('transactions');
        final txs = res.map((e) => TransactionModel.fromMap(e)).toList();
        final filtered = txs.where((t) => t.date.isAfter(event.from.subtract(const Duration(seconds:1))) && t.date.isBefore(event.to.add(const Duration(days:1)))).toList();
        final Map<String, double> totals = {};
        for (var t in filtered) {
          final cat = t.categoryId.toString();
          totals[cat] = (totals[cat] ?? 0) + t.amount;
        }
        emit(ReportGenerated(totals));
      } catch (e) {
        emit(ReportError(e.toString()));
      }
    });
  }
}
