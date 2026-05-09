class TransactionModel {
  final String? id;
  final String judul;
  final int nominal;
  final String tipe; // 'pemasukan' atau 'pengeluaran'
  final String kategori;
  final String? catatan;
  final DateTime tanggal;

  TransactionModel({
    this.id,
    required this.judul,
    required this.nominal,
    required this.tipe,
    required this.kategori,
    this.catatan,
    required this.tanggal,
  });

  // Konversi dari Supabase (Map) ke Model
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      judul: map['judul'],
      nominal: map['nominal'],
      tipe: map['tipe'],
      kategori: map['kategori'],
      catatan: map['catatan'],
      tanggal: DateTime.parse(map['tanggal']),
    );
  }

  // Konversi dari Model ke Map (untuk kirim ke Supabase)
  Map<String, dynamic> toMap() {
    return {
      'judul': judul,
      'nominal': nominal,
      'tipe': tipe,
      'kategori': kategori,
      'catatan': catatan,
      'tanggal': tanggal.toIso8601String(),
    };
  }
}
