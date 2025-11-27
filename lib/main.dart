import 'package:dashboard_financeiro/blocs/category/category_event.dart';
import 'package:dashboard_financeiro/blocs/transaction/transaction_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'blocs/transaction/transaction_bloc.dart';
import 'blocs/category/category_bloc.dart';
import 'blocs/filter/filter_bloc.dart';
import 'blocs/report/report_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => TransactionBloc()..add(LoadTransactions())),
      BlocProvider(create: (_) => CategoryBloc()..add(LoadCategories())),
      BlocProvider(create: (_) => FilterBloc()),
      BlocProvider(create: (_) => ReportBloc()),
    ],
    child: const MyApp(),
  ));
}
