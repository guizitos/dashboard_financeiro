import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_state.dart';
import '../blocs/transaction/transaction_event.dart';
import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_state.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../widgets/empty_state.dart';
import 'quick_add_transaction_screen.dart';
import '../utils/category_icons.dart';
import 'monthly_transactions_screen.dart';
// Tela principal do dashboard
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  int? selectedCategoryFilter; // null = todas categorias
  bool isFabOpen = false;
  AnimationController? _fabAnimationController;
  Animation<double>? _fabAnimation;
  Animation<double>? _scaleAnimation;
  Animation<double>? _rotationAnimation;

  final List<String> monthNames = const [
    'Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController!,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController!,
        curve: Curves.elasticOut,
      ),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(
        parent: _fabAnimationController!,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _fabAnimationController?.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      isFabOpen = !isFabOpen;
      if (isFabOpen) {
        _fabAnimationController?.forward();
      } else {
        _fabAnimationController?.reverse();
      }
    });
  }

  void _showAddTransaction(bool isExpense) {
    _toggleFab();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => QuickAddTransactionScreen(
          isExpense: isExpense,
          initialMonth: selectedMonth,
          initialYear: selectedYear,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          
          var slideTween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
          
          return SlideTransition(
            position: animation.drive(slideTween),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        fullscreenDialog: true,
      ),
    );
  }

  void _showYearSelector(BuildContext context) {
    final currentYear = DateTime.now().year;
    final startYear = 2000;
    final endYear = 2100;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selecione o Ano',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: endYear - startYear + 1,
                reverse: true,
                itemBuilder: (context, index) {
                  final year = endYear - index;
                  final isSelected = year == selectedYear;
                  final isCurrent = year == currentYear;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedYear = year);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.primaryContainer,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )
                            : null,
                        color: isSelected ? null : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: isCurrent && !isSelected
                            ? Border.all(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                width: 2,
                              )
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            year.toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.2)
                                    : Theme.of(context).colorScheme.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Atual',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selecione o Mês',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final isSelected = month == selectedMonth;
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedMonth = month);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.primaryContainer,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isSelected ? null : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            monthNames[index],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            month.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.8)
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  List<TransactionModel> _getFilteredTransactions(List<TransactionModel> all) {
    final period = all.where((t) => t.date.year == selectedYear && t.date.month == selectedMonth).toList();
    if (selectedCategoryFilter == null) return period;
    return period.where((t) => t.categoryId == selectedCategoryFilter).toList();
  }

  List<_MonthlyPoint> _computeMonthlyEvolution(List<TransactionModel> all) {
    final base = DateTime(selectedYear, selectedMonth, 1);
    final points = <_MonthlyPoint>[];
    for (int i = 5; i >= 0; i--) {
      final dt = DateTime(base.year, base.month - i, 1);
      final monthTx = all.where((t) => t.date.year == dt.year && t.date.month == dt.month).toList();
      double inc = 0, exp = 0;
      for (final t in monthTx) {
        if (t.isExpense) {
          exp += t.amount;
        } else {
          inc += t.amount;
        }
      }
      points.add(_MonthlyPoint(label: monthNames[dt.month-1], income: inc, expense: exp, balance: inc - exp));
    }
    if (selectedCategoryFilter != null) {
      // recalcula cada ponto apenas para a categoria selecionada
      return points.asMap().entries.map((e) {
        final idx = e.key; final original = e.value;
        final monthOffset = 5 - idx; // idx 0 = mais antigo
        final dt = DateTime(base.year, base.month - monthOffset, 1);
        final monthTx = all.where((t) => t.date.year == dt.year && t.date.month == dt.month && t.categoryId == selectedCategoryFilter).toList();
        double inc = 0, exp = 0;
        for (final t in monthTx) {
          if (t.isExpense) {
            exp += t.amount;
          } else {
            inc += t.amount;
          }
        }
        return _MonthlyPoint(label: original.label, income: inc, expense: exp, balance: inc - exp);
      }).toList();
    }
    return points;
  }

  String _categoryName(int id, List<CategoryModel> cats) {
    final found = cats.where((c) => c.id == id).toList();
    return found.isEmpty ? 'Sem categoria' : found.first.name;
  }

  Color _getCategoryColor(String categoryName) {
    final visual = getCategoryVisual(categoryName, Theme.of(context).colorScheme);
    return visual.color;
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('G-Finance')),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 200,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            if (_fabAnimation != null && _scaleAnimation != null) ...[
              // Receita (superior esquerdo)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: isFabOpen ? 100 : 0,
                left: isFabOpen ? MediaQuery.of(context).size.width / 2 - 120 : MediaQuery.of(context).size.width / 2 - 28,
                child: ScaleTransition(
                  scale: _scaleAnimation!,
                  child: FadeTransition(
                    opacity: _fabAnimation!,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                scheme.primaryContainer,
                                scheme.primary.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.primary.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () => _showAddTransaction(false),
                              child: Center(
                                child: Icon(
                                  Icons.arrow_upward_rounded,
                                  color: scheme.onPrimary,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Receitas',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Despesa (superior direito)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: isFabOpen ? 100 : 0,
                right: isFabOpen ? MediaQuery.of(context).size.width / 2 - 120 : MediaQuery.of(context).size.width / 2 - 28,
                child: ScaleTransition(
                  scale: _scaleAnimation!,
                  child: FadeTransition(
                    opacity: _fabAnimation!,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                scheme.errorContainer,
                                scheme.error.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.error.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () => _showAddTransaction(true),
                              child: Center(
                                child: Icon(
                                  Icons.arrow_downward_rounded,
                                  color: scheme.onError,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Despesas',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: scheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            // Botão principal
            Positioned(
              bottom: 0,
              child: RotationTransition(
                turns: _rotationAnimation ?? const AlwaysStoppedAnimation(0),
                child: FloatingActionButton(
                  heroTag: 'main',
                  onPressed: _toggleFab,
                  elevation: 6,
                  child: Icon(isFabOpen ? Icons.close : Icons.add),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
              icon: Icon(Icons.home_rounded, color: scheme.primary),
              iconSize: 28,
              onPressed: () {},
            ),
            const SizedBox(width: 80), // Espaço para o FAB
            IconButton(
              icon: Icon(Icons.list_alt_rounded, color: scheme.onSurface),
              iconSize: 28,
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => 
                      MonthlyTransactionsScreen(month: selectedMonth, year: selectedYear),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const curve = Curves.easeInOutCubic;
                      var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
                      var scaleTween = Tween<double>(begin: 0.95, end: 1.0).chain(CurveTween(curve: curve));
                      
                      return FadeTransition(
                        opacity: animation.drive(fadeTween),
                        child: ScaleTransition(
                          scale: animation.drive(scaleTween),
                          child: child,
                        ),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 350),
                    reverseTransitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, catState) {
          if (catState is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final categories = catState is CategoryLoaded ? catState.categories : <CategoryModel>[];
          return BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, txState) {
              if (txState is TransactionLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (txState is! TransactionLoaded) {
                return const EmptyState(title: 'Aguardando', message: 'Carregando dados...', icon: Icons.hourglass_empty);
              }
              final allTx = txState.transactions;
              final filtered = _getFilteredTransactions(allTx);

              double totalIncome = 0, totalExpense = 0;
              for (final t in filtered) { if (t.isExpense) totalExpense += t.amount; else totalIncome += t.amount; }
              final balance = totalIncome - totalExpense;

              final evolution = _computeMonthlyEvolution(allTx);
              final evoVals = [
                ...evolution.map((e)=> e.income),
                ...evolution.map((e)=> e.expense),
                ...evolution.map((e)=> e.balance),
              ];
              final maxY = (evoVals.isEmpty ? 0.0 : evoVals.reduce((a,b)=> a>b?a:b)) * 1.15 + 1.0;
              final minBalance = evolution.isEmpty ? 0.0 : evolution.map((e)=> e.balance).reduce((a,b)=> a<b?a:b);
              final minY = minBalance < 0 ? minBalance * 1.15 : 0.0;

              final expenseTx = filtered.where((t) => t.isExpense).toList();
              final Map<int,double> expenseByCat = {};
              for (final t in expenseTx) { expenseByCat[t.categoryId] = (expenseByCat[t.categoryId] ?? 0) + t.amount; }
              final expenseTotal = expenseByCat.values.fold(0.0, (p,e)=> p+e);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => _showMonthSelector(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              scheme.primaryContainer.withOpacity(0.3),
                              scheme.secondaryContainer.withOpacity(0.3),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: scheme.outline.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.chevron_left_rounded, color: scheme.primary),
                              onPressed: () {
                                setState(() {
                                  if (selectedMonth == 1) {
                                    selectedMonth = 12;
                                    if (selectedYear > 2000) selectedYear--;
                                  } else {
                                    selectedMonth--;
                                  }
                                });
                              },
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => _showYearSelector(context),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.calendar_month_rounded, color: scheme.primary, size: 24),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${monthNames[selectedMonth - 1]} / $selectedYear',
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
                            ),
                            IconButton(
                              icon: Icon(Icons.chevron_right_rounded, color: scheme.primary),
                              onPressed: () {
                                setState(() {
                                  if (selectedMonth == 12) {
                                    selectedMonth = 1;
                                    if (selectedYear < 2100) selectedYear++;
                                  } else {
                                    selectedMonth++;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height:16),
                    // Card de Saldo em destaque
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            scheme.tertiaryContainer,
                            scheme.tertiaryContainer.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.tertiary.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.account_balance_wallet_rounded, color: scheme.onSurface, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                'Saldo',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: scheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currency.format(balance),
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height:12),
                    Row(children:[
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                scheme.primaryContainer,
                                scheme.primaryContainer.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.primary.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.arrow_upward_rounded, size: 24, color: scheme.onSurface),
                              const SizedBox(height: 8),
                              Text(
                                'Receitas',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: scheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currency.format(totalIncome),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width:12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                scheme.errorContainer,
                                scheme.errorContainer.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.error.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.arrow_downward_rounded, size: 24, color: scheme.onSurface),
                              const SizedBox(height: 8),
                              Text(
                                'Despesas',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: scheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currency.format(totalExpense),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height:16),
                    SizedBox(
                      height:48,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children:[
                          Padding(
                            padding: const EdgeInsets.only(right:8),
                            child: ChoiceChip(
                              label: Row(mainAxisSize: MainAxisSize.min, children: [
                                _CategoryIconCircle(icon: Icons.apps_rounded, color: scheme.primary),
                                const SizedBox(width:6),
                                const Text('Todas')
                              ]),
                              selected: selectedCategoryFilter==null,
                              onSelected: (_)=> setState(()=> selectedCategoryFilter=null),
                            ),
                          ),
                          ...categories.map((c)=> Padding(
                            padding: const EdgeInsets.only(right:8),
                            child: ChoiceChip(
                              label: Row(mainAxisSize: MainAxisSize.min, children: [
                                Builder(builder: (context){
                                  final visual = getCategoryVisual(c.name, scheme);
                                  return _CategoryIconCircle(icon: visual.icon, color: visual.color);
                                }),
                                const SizedBox(width:6),
                                Text(c.name)
                              ]),
                              selected: selectedCategoryFilter==c.id,
                              onSelected: (_)=> setState(()=> selectedCategoryFilter=c.id),
                            ),
                          ))
                        ]),
                      ),
                    ),
                    const SizedBox(height:12),
                    SizedBox(
                      height:230,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                            Row(children:[Icon(Icons.timeline, size:18, color: scheme.primary), const SizedBox(width:6), Text('Evolução últimos 6 meses', style: Theme.of(context).textTheme.titleSmall)]),
                            const SizedBox(height:8),
                            Expanded(
                              child: LineChart(
                                LineChartData(
                                  minX:0,
                                  maxX:(evolution.length - 1).toDouble(),
                                  minY:minY,
                                  maxY:maxY,
                                  gridData: const FlGridData(show:true),
                                  borderData: FlBorderData(show:true),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles:true, getTitlesWidget:(value, meta){
                                      final idx = value.toInt();
                                      if (idx < 0 || idx >= evolution.length) return const SizedBox();
                                      return Padding(padding: const EdgeInsets.only(top:4), child: Text(evolution[idx].label.toUpperCase(), style: const TextStyle(fontSize:11)));
                                    })),
                                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles:true, reservedSize:46, getTitlesWidget:(v,m)=> Text(NumberFormat.compact(locale:'pt_BR').format(v), style: const TextStyle(fontSize:10)))),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles:false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles:false)),
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(spots:[for(int i=0;i<evolution.length;i++) FlSpot(i.toDouble(), evolution[i].income)], color: scheme.primary, isCurved:true, dotData: const FlDotData(show:false)),
                                    LineChartBarData(spots:[for(int i=0;i<evolution.length;i++) FlSpot(i.toDouble(), evolution[i].expense)], color: scheme.error, isCurved:true, dotData: const FlDotData(show:false)),
                                    LineChartBarData(spots:[for(int i=0;i<evolution.length;i++) FlSpot(i.toDouble(), evolution[i].balance)], color: scheme.tertiary, isCurved:true, dotData: const FlDotData(show:false)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height:8),
                            Wrap(spacing:12, runSpacing:4, children:[
                              _RowLegend(color: scheme.primary, text:'Receitas'),
                              _RowLegend(color: scheme.error, text:'Despesas'),
                              _RowLegend(color: scheme.tertiary, text:'Saldo'),
                            ])
                          ]),
                        ),
                      ),
                    ),
                    // Pizza despesas
                    SizedBox(
                      height:220,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(children:[
                            Expanded(
                              child: expenseByCat.isEmpty || expenseTotal==0 ? 
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.pie_chart_outline, size: 48, color: scheme.onSurfaceVariant.withOpacity(0.5)),
                                      const SizedBox(height: 12),
                                      Text('Nenhuma despesa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: scheme.onSurface)),
                                      const SizedBox(height: 4),
                                      Text('Sem dados no período', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                                    ],
                                  ),
                                ) :
                                PieChart(
                                  PieChartData(
                                    sections: List.generate(expenseByCat.length, (i){
                                      final entry = expenseByCat.entries.toList()[i];
                                      final percent = (entry.value / expenseTotal) * 100;
                                      final cat = categories.firstWhere((c) => c.id == entry.key, orElse: () => CategoryModel(id: entry.key, name: 'Sem categoria'));
                                      return PieChartSectionData(
                                        value: entry.value,
                                        color: _getCategoryColor(cat.name),
                                        title: '${percent.toStringAsFixed(0)}%',
                                        radius: 50,
                                        titleStyle: const TextStyle(fontSize:12, fontWeight: FontWeight.bold, color: Colors.white),
                                      );
                                    }),
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 28,
                                  ),
                                ),
                            ),
                            const SizedBox(width:12),
                            SizedBox(
                              width:200,
                              child: ListView(
                                children: expenseByCat.entries.map((e){
                                  final cat = categories.firstWhere((c)=> c.id == e.key, orElse: ()=> CategoryModel(id:e.key, name:'Sem categoria'));
                                  final color = _getCategoryColor(cat.name);
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical:6),
                                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children:[
                                      Container(width:14, height:14, color: color),
                                      const SizedBox(width:8),
                                      Expanded(child: Text('${cat.name}: ${currency.format(e.value)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                    ]),
                                  );
                                }).toList(),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(height:12),

                    // Lista
                    filtered.isEmpty ? 
                      const SizedBox(
                        height: 200,
                        child: EmptyState(title: 'Nenhuma transação', message: 'Use o botão para adicionar.', icon: Icons.receipt_long_outlined),
                      ) :
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        itemBuilder: (context, i){
                          final t = filtered[i];
                          final key = Key('tx-${t.id ?? i}-${t.date.toIso8601String()}');
                          return Dismissible(
                            key: key,
                            direction: DismissDirection.horizontal,
                            background: Container(color: Colors.green, alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left:16), child: const Row(children:[Icon(Icons.edit_outlined, color: Colors.white), SizedBox(width:8), Text('Editar', style: TextStyle(color: Colors.white))])),
                            secondaryBackground: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right:16), child: const Row(mainAxisAlignment: MainAxisAlignment.end, children:[Icon(Icons.delete_outline, color: Colors.white), SizedBox(width:8), Text('Deletar', style: TextStyle(color: Colors.white))])),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (dCtx) => _EditTransactionSheet(context: context, dCtx: dCtx, transaction: t, categories: categories),
                                );
                                return false;
                              } else if (direction == DismissDirection.endToStart) {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (dCtx) => AlertDialog(
                                    icon: Icon(Icons.warning_amber_rounded, color: Theme.of(dCtx).colorScheme.error, size: 48),
                                    title: const Text('Confirmar exclusão'),
                                    content: Text('Excluir "${t.title}"?'),
                                    actions: [
                                      TextButton(onPressed: ()=> Navigator.of(dCtx).pop(false), child: const Text('Cancelar')),
                                      FilledButton(onPressed: ()=> Navigator.of(dCtx).pop(true), style: FilledButton.styleFrom(backgroundColor: Theme.of(dCtx).colorScheme.error), child: const Text('Excluir')),
                                    ],
                                  ),
                                );
                                if (confirmed == true) {
                                  context.read<TransactionBloc>().add(DeleteTransaction(t.id!));
                                  return true;
                                }
                                return false;
                              }
                              return false;
                            },
                            child: Card(
                              child: ListTile(
                                leading: Builder(builder: (context){
                                  final catName = _categoryName(t.categoryId, categories);
                                  final visual = getCategoryVisual(catName, scheme);
                                  return CircleAvatar(
                                    backgroundColor: visual.color.withOpacity(0.15),
                                    foregroundColor: visual.color,
                                    child: Icon(visual.icon, size:20),
                                  );
                                }),
                                title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${_categoryName(t.categoryId, categories)} • ${DateFormat('dd/MM').format(t.date)}'),
                                trailing: Text(currency.format(t.amount), style: TextStyle(color: t.isExpense ? scheme.error : scheme.primary, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryIconCircle extends StatelessWidget {
  final IconData icon; final Color color;
  const _CategoryIconCircle({required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Icon(icon, size:14, color: color),
    );
  }
}


class _EditTransactionSheet extends StatefulWidget {
  final BuildContext context;
  final BuildContext dCtx;
  final TransactionModel transaction;
  final List<CategoryModel> categories;

  const _EditTransactionSheet({
    required this.context,
    required this.dCtx,
    required this.transaction,
    required this.categories,
  });

  @override
  State<_EditTransactionSheet> createState() => _EditTransactionSheetState();
}

class _EditTransactionSheetState extends State<_EditTransactionSheet> {
  late TextEditingController titleCtrl;
  late TextEditingController amountCtrl;
  late int selectedCategory;
  late bool isExpense;
  late DateTime selectedDate;

  double _parseCurrency(String input, [double fallback = 0.0]) {
    try {
      return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
          .parse(input)
          .toDouble();
    } catch (_) {
      try {
        return NumberFormat.currency(locale: 'pt_BR', symbol: '')
            .parse(input)
            .toDouble();
      } catch (_) {
        final cleaned = input.replaceAll(RegExp(r'[^0-9,.-]'), '');
        final alt = cleaned.replaceAll('.', '').replaceAll(',', '.');
        return double.tryParse(alt) ?? fallback;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.transaction.title);
    amountCtrl = TextEditingController(
      text: NumberFormat.currency(locale: 'pt_BR', symbol: '')
          .format(widget.transaction.amount),
    );
    selectedCategory = widget.transaction.categoryId;
    isExpense = widget.transaction.isExpense;
    selectedDate = widget.transaction.date;
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: isExpense
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Transação'),
        content: const Text('Tem certeza que deseja excluir esta transação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.context
          .read<TransactionBloc>()
          .add(DeleteTransaction(widget.transaction.id!));
      Navigator.of(widget.dCtx).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Editar Transação',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(widget.dCtx).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Campo Título
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Campo Valor
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: amountCtrl,
                  decoration: InputDecoration(
                    labelText: 'Valor',
                    prefixIcon: const Icon(Icons.payments_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(height: 16),

              // Campo Data
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(20),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Data',
                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                    ),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(selectedDate),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Campo Categoria
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<int>(
                  value: selectedCategory,
                  isExpanded: true,
                  menuMaxHeight: 400,
                  decoration: InputDecoration(
                    labelText: 'Categoria',
                    prefixIcon: const Icon(Icons.category_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                  ),
                  items: widget.categories.map((category) {
                    final visual = getCategoryVisual(category.name, colorScheme);
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: visual.color.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              visual.icon,
                              color: visual.color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              category.name,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedCategory = value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Switch Tipo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                          color: isExpense ? colorScheme.error : colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Tipo de Transação',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          isExpense ? 'Despesa' : 'Receita',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isExpense ? colorScheme.error : colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Switch(
                          value: isExpense,
                          onChanged: (value) => setState(() => isExpense = value),
                          activeColor: colorScheme.error,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botões
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botão Excluir
                  IconButton(
                    onPressed: _showDeleteConfirmation,
                    icon: const Icon(Icons.delete_rounded),
                    color: colorScheme.error,
                    iconSize: 28,
                  ),
                  const Spacer(),
                  // Botão Cancelar
                  TextButton(
                    onPressed: () => Navigator.of(widget.dCtx).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  // Botão Salvar
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isExpense
                              ? [
                                  colorScheme.errorContainer,
                                  colorScheme.error.withOpacity(0.8),
                                ]
                              : [
                                  colorScheme.primaryContainer,
                                  colorScheme.primary.withOpacity(0.8),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (isExpense ? colorScheme.error : colorScheme.primary)
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          final newTitle = titleCtrl.text.trim();
                          final newAmount = _parseCurrency(
                            amountCtrl.text,
                            widget.transaction.amount,
                          );
                          final upd = TransactionModel(
                            id: widget.transaction.id,
                            title: newTitle.isEmpty
                                ? widget.transaction.title
                                : newTitle,
                            amount: newAmount,
                            date: selectedDate,
                            categoryId: selectedCategory,
                            isExpense: isExpense,
                          );
                          widget.context
                              .read<TransactionBloc>()
                              .add(UpdateTransaction(upd));
                          Navigator.of(widget.dCtx).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Salvar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthlyPoint { final String label; final double income; final double expense; final double balance; _MonthlyPoint({required this.label, required this.income, required this.expense, required this.balance}); }
class _RowLegend extends StatelessWidget { final Color color; final String text; const _RowLegend({required this.color, required this.text}); @override Widget build(BuildContext context){ return Row(mainAxisSize: MainAxisSize.min, children:[ Container(width:12, height:12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))), const SizedBox(width:6), Text(text, style: Theme.of(context).textTheme.bodySmall) ]); }}
