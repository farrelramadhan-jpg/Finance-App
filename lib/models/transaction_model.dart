class TransactionModel {
  final Object? id;
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
    final rawId = map['id'];
    final rawNominal = map['nominal'];
    final rawTanggal = map['tanggal'];

    return TransactionModel(
      id: rawId,
      judul: map['judul']?.toString() ?? '',
      nominal: rawNominal is int
          ? rawNominal
          : int.tryParse(rawNominal?.toString() ?? '') ?? 0,
      tipe: map['tipe']?.toString() ?? '',
      kategori: map['kategori']?.toString() ?? '',
      catatan: map['catatan']?.toString(),
      tanggal: rawTanggal is DateTime
          ? rawTanggal
          : DateTime.parse(
              rawTanggal?.toString() ?? DateTime.now().toIso8601String(),
            ),
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
