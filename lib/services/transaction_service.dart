import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final _supabase = Supabase.instance.client;

  // Ambil semua transaksi
  Future<List<TransactionModel>> getAll() async {
    final response = await _supabase
        .from('transactions')
        .select()
        .order('tanggal', ascending: false);

    return (response as List).map((e) => TransactionModel.fromMap(e)).toList();
  }

  // Tambah transaksi baru
  Future<void> insert(TransactionModel transaction) async {
    await _supabase.from('transactions').insert(transaction.toMap());
  }

  // Update transaksi
  Future<void> update(Object id, TransactionModel transaction) async {
    await _supabase
        .from('transactions')
        .update(transaction.toMap())
        .eq('id', id);
  }

  // Hapus transaksi
  Future<void> delete(Object id) async {
    await _supabase.from('transactions').delete().eq('id', id);
  }

  // Hitung total saldo
  Future<Map<String, int>> getSummary() async {
    final data = await getAll();

    int pemasukan = 0;
    int pengeluaran = 0;

    for (var t in data) {
      if (t.tipe == 'pemasukan') {
        pemasukan += t.nominal;
      } else {
        pengeluaran += t.nominal;
      }
    }

    return {
      'pemasukan': pemasukan,
      'pengeluaran': pengeluaran,
      'saldo': pemasukan - pengeluaran,
    };
  }
}
