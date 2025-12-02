import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_event.dart';
import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_state.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../utils/category_icons.dart';
//Tela para adicionar transações rapidamente
class QuickAddTransactionScreen extends StatefulWidget {
  final bool isExpense;
  final int? initialMonth;
  final int? initialYear;
  
  const QuickAddTransactionScreen({
    super.key,
    required this.isExpense,
    this.initialMonth,
    this.initialYear,
  });

  @override
  State<QuickAddTransactionScreen> createState() => _QuickAddTransactionScreenState();
}

class _QuickAddTransactionScreenState extends State<QuickAddTransactionScreen> {
  String displayAmount = '0';
  late DateTime selectedDate;
  int? selectedCategoryId;
  final TextEditingController descriptionCtrl = TextEditingController();
  final FocusNode descriptionFocus = FocusNode();
  bool isEnteringAmount = true;

  @override
  void initState() {
    super.initState();
    // Inicializa a data com o mês/ano selecionado no dashboard
    final month = widget.initialMonth ?? DateTime.now().month;
    final year = widget.initialYear ?? DateTime.now().year;
    selectedDate = DateTime(year, month, DateTime.now().day);
  }

  @override
  void dispose() {
    descriptionCtrl.dispose();
    descriptionFocus.dispose();
    super.dispose();
  }

  void _onNumberTap(String number) {
    setState(() {
      if (displayAmount == '0') {
        displayAmount = number;
      } else if (displayAmount.length < 12) {
        displayAmount += number;
      }
    });
  }

  void _onDecimalTap() {
    if (!displayAmount.contains(',')) {
      setState(() {
        displayAmount += ',';
      });
    }
  }

  void _onBackspace() {
    setState(() {
      if (displayAmount.length > 1) {
        displayAmount = displayAmount.substring(0, displayAmount.length - 1);
      } else {
        displayAmount = '0';
      }
    });
  }

  double _parseAmount() {
    try {
      final cleaned = displayAmount.replaceAll('.', '').replaceAll(',', '.');
      return double.parse(cleaned);
    } catch (_) {
      return 0.0;
    }
  }

  void _showDescriptionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _DescriptionDialog(
        initialText: descriptionCtrl.text,
        onSave: (text) {
          setState(() {
            descriptionCtrl.text = text;
          });
        },
      ),
    );
  }

  void _save() {
    final amount = _parseAmount();
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um valor válido')),
      );
      return;
    }

    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma categoria')),
      );
      return;
    }

    final tx = TransactionModel(
      id: null,
      title: descriptionCtrl.text.trim().isEmpty ? (widget.isExpense ? 'Despesa' : 'Receita') : descriptionCtrl.text.trim(),
      amount: amount,
      date: selectedDate,
      categoryId: selectedCategoryId!,
      isExpense: widget.isExpense,
    );

    context.read<TransactionBloc>().add(AddTransaction(tx));
    
    // Feedback visual e transição suave ao fechar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              widget.isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(widget.isExpense ? 'Despesa adicionada!' : 'Receita adicionada!'),
          ],
        ),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: widget.isExpense 
            ? Theme.of(context).colorScheme.error 
            : Theme.of(context).colorScheme.primary,
      ),
    );
    
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: scheme.surface.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Column(
        children: [
          // Header com gradiente
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 100, 24, 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isExpense
                    ? [scheme.errorContainer, scheme.error.withOpacity(0.3)]
                    : [scheme.primaryContainer, scheme.primary.withOpacity(0.3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: scheme.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.isExpense ? 'Nova Despesa' : 'Nova Receita',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: widget.isExpense ? scheme.error : scheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    setState(() => isEnteringAmount = true);
                    FocusScope.of(context).unfocus();
                  },
                  child: Text(
                    currency.format(_parseAmount()),
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                      letterSpacing: -2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descrição
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surface,
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
                      controller: descriptionCtrl,
                      focusNode: descriptionFocus,
                      readOnly: true,
                      enableInteractiveSelection: false,
                      onTap: () {
                        setState(() => isEnteringAmount = false);
                        _showDescriptionDialog();
                      },
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Descrição',
                        hintText: 'O que foi?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: scheme.surface,
                        prefixIcon: Icon(Icons.edit_note_rounded, color: scheme.primary),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Data
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surface,
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
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(context).colorScheme.copyWith(
                                  primary: widget.isExpense ? scheme.error : scheme.primary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Data',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: scheme.surface,
                          prefixIcon: Icon(Icons.calendar_today_rounded, color: scheme.primary),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(selectedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Categoria
                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      if (state is CategoryLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      List<CategoryModel> categories = state is CategoryLoaded ? state.categories : <CategoryModel>[];
                      
                      // Categorias de receitas
                      final receitaCategorias = ['salário', 'salario', 'freelance', 'investimentos', 'vendas', 'bonificação', 'bonificacao', 'aluguel'];
                      
                      if (!widget.isExpense) {
                        // Receita: mostrar apenas categorias de receita
                        categories = categories.where((c) {
                          final n = c.name.toLowerCase();
                          return receitaCategorias.any((rc) => n.contains(rc));
                        }).toList();
                      } else {
                        // Despesa: ocultar categorias de receita
                        categories = categories.where((c) {
                          final n = c.name.toLowerCase();
                          return !receitaCategorias.any((rc) => n.contains(rc));
                        }).toList();
                      }
                      
                      if (categories.isNotEmpty && selectedCategoryId == null) {
                        selectedCategoryId = categories.first.id;
                      }
                      if (categories.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            !widget.isExpense
                                ? 'Nenhuma categoria de receita disponível.'
                                : 'Nenhuma categoria de despesa disponível.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        );
                      }
                      return Container(
                        decoration: BoxDecoration(
                          color: scheme.surface,
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
                          value: selectedCategoryId,
                          decoration: InputDecoration(
                            labelText: 'Categoria',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: scheme.surface,
                            prefixIcon: Icon(Icons.label_rounded, color: scheme.primary),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          ),
                          isExpanded: true,
                          menuMaxHeight: 400,
                          items: categories.map((cat) {
                            final visual = getCategoryVisual(cat.name, scheme);
                            return DropdownMenuItem(
                              value: cat.id,
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: visual.color.withOpacity(0.15),
                                    ),
                                    child: Icon(visual.icon, size: 20, color: visual.color),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      cat.name,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => selectedCategoryId = v),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Área inferior: teclado numérico ou apenas ações
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: isEnteringAmount
                ? Container(
                    key: const ValueKey('keyboard'),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        _buildKeyboardRow(['1', '2', '3']),
                        _buildKeyboardRow(['4', '5', '6']),
                        _buildKeyboardRow(['7', '8', '9']),
                        _buildKeyboardRow([',', '0', 'backspace']),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    side: BorderSide(color: scheme.outline),
                                  ),
                                  child: const Text('Cancelar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: widget.isExpense
                                          ? [scheme.error, scheme.error.withOpacity(0.8)]
                                          : [scheme.primary, scheme.primary.withOpacity(0.8)],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (widget.isExpense ? scheme.error : scheme.primary).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _save,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: const Text(
                                      'Adicionar',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    key: const ValueKey('actions'),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              side: BorderSide(color: scheme.outline),
                            ),
                            child: const Text('Cancelar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: widget.isExpense
                                    ? [scheme.error, scheme.error.withOpacity(0.8)]
                                    : [scheme.primary, scheme.primary.withOpacity(0.8)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: (widget.isExpense ? scheme.error : scheme.primary).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _save,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text(
                                'Adicionar',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((key) => _buildKeyboardButton(key)).toList(),
      ),
    );
  }

  Widget _buildKeyboardButton(String key) {
    final scheme = Theme.of(context).colorScheme;
    final isSpecial = key == 'backspace' || key == ',';
    
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (key == 'backspace') {
                _onBackspace();
              } else if (key == ',') {
                _onDecimalTap();
              } else {
                _onNumberTap(key);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: isSpecial ? scheme.surfaceContainerHighest : scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: scheme.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Center(
                child: key == 'backspace'
                    ? Icon(Icons.backspace_rounded, color: scheme.onSurface, size: 24)
                    : Text(
                        key,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget separado para o dialog de descrição
class _DescriptionDialog extends StatefulWidget {
  final String initialText;
  final Function(String) onSave;

  const _DescriptionDialog({
    required this.initialText,
    required this.onSave,
  });

  @override
  State<_DescriptionDialog> createState() => _DescriptionDialogState();
}

class _DescriptionDialogState extends State<_DescriptionDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Descrição'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'O que foi?',
          border: OutlineInputBorder(),
        ),
        maxLength: 50,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_controller.text);
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
