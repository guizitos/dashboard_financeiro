import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_state.dart';
import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_state.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../utils/category_icons.dart';

class MonthlyTransactionsScreen extends StatefulWidget {
  final int month; final int year;
  const MonthlyTransactionsScreen({super.key, required this.month, required this.year});

  @override
  State<MonthlyTransactionsScreen> createState() => _MonthlyTransactionsScreenState();
}

class _MonthlyTransactionsScreenState extends State<MonthlyTransactionsScreen> {
  late int selectedMonth;
  late int selectedYear;

  final List<String> monthNames = const [
    'Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'
  ];

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.month;
    selectedYear = widget.year;
    initializeDateFormatting('pt_BR', null);
  }

  String _categoryName(int id, List<CategoryModel> categories) {
    final c = categories.firstWhere((e)=> e.id == id, orElse: ()=> CategoryModel(id: id, name: 'N/D'));
    return c.name;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final currency = NumberFormat.currency(locale:'pt_BR', symbol:'R\$');
    final monthNames = const ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Transações - ${monthNames[selectedMonth-1]}/$selectedYear'),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.home_rounded, color: scheme.onSurface),
              iconSize: 28,
              onPressed: () => Navigator.of(context).pop(),
            ),
            IconButton(
              icon: Icon(Icons.list_alt_rounded, color: scheme.primary),
              iconSize: 28,
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, catState){
          final categories = catState is CategoryLoaded ? catState.categories : <CategoryModel>[];
          return BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, txState){
              if (txState is TransactionLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (txState is! TransactionLoaded) {
                return const Center(child: Text('Carregando...'));
              }
              final monthTx = txState.transactions.where((t)=> t.date.month==selectedMonth && t.date.year==selectedYear).toList();
              if (monthTx.isEmpty) {
                return Center(child: Text('Nenhuma transação em ${monthNames[selectedMonth-1]}/$selectedYear'));
              }
              monthTx.sort((a,b)=> b.date.compareTo(a.date));
              double income=0, expense=0; for(final t in monthTx){ if(t.isExpense) expense+=t.amount; else income+=t.amount; }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  scheme.primaryContainer,
                                  scheme.primaryContainer.withOpacity(0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: scheme.primary.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.arrow_upward_rounded, color: scheme.onSurface, size: 24),
                                const SizedBox(height: 8),
                                Text(
                                  'Receitas',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: scheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currency.format(income),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  scheme.errorContainer,
                                  scheme.errorContainer.withOpacity(0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: scheme.error.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.arrow_downward_rounded, color: scheme.onSurface, size: 24),
                                const SizedBox(height: 8),
                                Text(
                                  'Despesas',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: scheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currency.format(expense),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _groupByDay(monthTx).length,
                      itemBuilder: (context, i){
                        final dayGroup = _groupByDay(monthTx)[i];
                        final date = dayGroup['date'] as DateTime;
                        final transactions = dayGroup['transactions'] as List<TransactionModel>;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 20, 4, 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: scheme.primary,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatDayHeader(date),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: scheme.onSurface,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...transactions.map((t) {
                              final catName = _categoryName(t.categoryId, categories);
                              final visual = getCategoryVisual(catName, scheme);
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: scheme.outline.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: visual.color.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(visual.icon, size: 24, color: visual.color),
                                  ),
                                  title: Text(
                                    t.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      catName,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: scheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                  trailing: Text(
                                    currency.format(t.amount),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: t.isExpense ? scheme.error : scheme.primary,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _groupByDay(List<TransactionModel> transactions) {
    final grouped = <String, List<TransactionModel>>{};
    for (final tx in transactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(tx.date);
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }
    final result = grouped.entries.map((entry) {
      return {
        'date': DateTime.parse(entry.key),
        'transactions': entry.value,
      };
    }).toList();
    result.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return result;
  }

  String _formatDayHeader(DateTime date) {
    const weekDays = [
      'segunda-feira',
      'terça-feira',
      'quarta-feira',
      'quinta-feira',
      'sexta-feira',
      'sábado',
      'domingo',
    ];
    final dayName = weekDays[date.weekday - 1];
    return '$dayName, ${date.day}';
  }
}
