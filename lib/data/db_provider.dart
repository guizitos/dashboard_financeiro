import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'dashboard_financeiro.db');

    return await openDatabase(
      dbPath,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            amount REAL,
            date TEXT,
            categoryId INTEGER,
            isExpense INTEGER
          );
        ''');

        // Seed categories - Receitas
        await db.insert('categories', {'name': 'Salário'});
        await db.insert('categories', {'name': 'Freelance'});
        await db.insert('categories', {'name': 'Investimentos'});
        await db.insert('categories', {'name': 'Vendas'});
        await db.insert('categories', {'name': 'Bonificação'});
        await db.insert('categories', {'name': 'Aluguel'});
        
        // Seed categories - Despesas
        await db.insert('categories', {'name': 'Alimentação'});
        await db.insert('categories', {'name': 'Transporte'});
        await db.insert('categories', {'name': 'Moradia'});
        await db.insert('categories', {'name': 'Saúde'});
        await db.insert('categories', {'name': 'Educação'});
        await db.insert('categories', {'name': 'Lazer'});
        await db.insert('categories', {'name': 'Compras'});
        await db.insert('categories', {'name': 'Contas'});
        await db.insert('categories', {'name': 'Streaming'});
        await db.insert('categories', {'name': 'Academia'});
        await db.insert('categories', {'name': 'Pet'});
        await db.insert('categories', {'name': 'Vestuário'});
        await db.insert('categories', {'name': 'Viagem'});
        await db.insert('categories', {'name': 'Presentes'});
        await db.insert('categories', {'name': 'Outros'});
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.insert('categories', {'name': 'Habitação'});
          await db.insert('categories', {'name': 'Saúde'});
          await db.insert('categories', {'name': 'Cuidados Pessoais'});
        }
        if (oldVersion < 3) {
          // Adicionar novas categorias de receitas
          await db.insert('categories', {'name': 'Freelance'});
          await db.insert('categories', {'name': 'Investimentos'});
          await db.insert('categories', {'name': 'Vendas'});
          await db.insert('categories', {'name': 'Bonificação'});
          await db.insert('categories', {'name': 'Aluguel'});
          
          // Adicionar novas categorias de despesas
          await db.insert('categories', {'name': 'Moradia'});
          await db.insert('categories', {'name': 'Educação'});
          await db.insert('categories', {'name': 'Lazer'});
          await db.insert('categories', {'name': 'Compras'});
          await db.insert('categories', {'name': 'Contas'});
          await db.insert('categories', {'name': 'Streaming'});
          await db.insert('categories', {'name': 'Academia'});
          await db.insert('categories', {'name': 'Pet'});
          await db.insert('categories', {'name': 'Vestuário'});
          await db.insert('categories', {'name': 'Viagem'});
          await db.insert('categories', {'name': 'Presentes'});
        }
      },
    );
  }

  Future close() async {
    final dbClient = await database;
    dbClient.close();
  }
}
