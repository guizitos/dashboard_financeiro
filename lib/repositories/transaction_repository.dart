import '../data/db_provider.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class TransactionRepository {
  Future<void> init() async {
    await DBProvider.db.database;
  }

  // -----------------------------
  // CRUD DE TRANSAÇÕES
  // -----------------------------

  Future<int> insertTransaction(TransactionModel t) async {
    final db = await DBProvider.db.database;
    return await db.insert('transactions', t.toMap());
  }

  Future<int> updateTransaction(TransactionModel t) async {
    final db = await DBProvider.db.database;
    return await db.update(
      'transactions',
      t.toMap(),
      where: 'id = ?',
      whereArgs: [t.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await DBProvider.db.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// BUSCA NORMAL (SEM CATEGORIA)
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await DBProvider.db.database;
    final res = await db.query('transactions', orderBy: 'date DESC');
    return res.map((e) => TransactionModel.fromMap(e)).toList();
  }

  /// BUSCA MELHORADA: TRANSAÇÕES + NOME DA CATEGORIA
  Future<List<Map<String, dynamic>>> getAllTransactionsWithCategory() async {
    final db = await DBProvider.db.database;
    final res = await db.rawQuery('''
      SELECT 
        t.id,
        t.title,
        t.amount,
        t.date,
        t.categoryId,
        t.isExpense,
        c.name as categoryName
      FROM transactions t
      LEFT JOIN categories c ON c.id = t.categoryId
      ORDER BY t.date DESC
    ''');

    return res;
  }

  // -----------------------------
  // CATEGORIAS
  // -----------------------------

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await DBProvider.db.database;
    final res = await db.query('categories', orderBy: 'name ASC');
    return res.map((e) => CategoryModel.fromMap(e)).toList();
  }

  Future<int> insertCategory(CategoryModel c) async {
    final db = await DBProvider.db.database;
    return db.insert('categories', c.toMap());
  }
}
