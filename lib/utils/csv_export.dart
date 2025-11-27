import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction.dart';

class CsvExport {
  static String transactionsToCsv(List<TransactionModel> txs) {
    final rows = <List<dynamic>>[];
    rows.add(['id', 'title', 'amount', 'date', 'categoryId', 'isExpense']);
    for (var t in txs) {
      rows.add([
        t.id,
        t.title,
        t.amount,
        t.date.toIso8601String(),
        t.categoryId,
        t.isExpense ? 1 : 0
      ]);
    }
    return const ListToCsvConverter().convert(rows);
  }

  static Future<String> saveCsvToFile(String csvContent, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(csvContent);
    return file.path;
  }

  static Future<void> saveAndShareCsv(String csvContent, String filename) async {
    final path = await saveCsvToFile(csvContent, filename);
    await Share.shareXFiles(
      [XFile(path)],
      text: 'Export de transações',
    );
  }
}
