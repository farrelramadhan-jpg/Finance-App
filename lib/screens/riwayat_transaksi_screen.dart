import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../utils/currency_formatter.dart';
import '../widgets/transaction_card.dart';

class RiwayatTransaksiScreen extends StatefulWidget {
  const RiwayatTransaksiScreen({super.key});

  @override
  State<RiwayatTransaksiScreen> createState() => _RiwayatTransaksiScreenState();
}

class _RiwayatTransaksiScreenState extends State<RiwayatTransaksiScreen> {
  final TransactionService _transactionService = TransactionService();
  List<TransactionModel> _allTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllTransactions();
  }

  Future<void> _loadAllTransactions() async {
    setState(() => _isLoading = true);
    try {
      final transactions = await _transactionService.getAll();
      if (!mounted) return;
      setState(() {
        _allTransactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    }
  }

  Map<String, List<TransactionModel>> get _transaksiPerTanggal {
    final Map<String, List<TransactionModel>> grouped = {};
    for (final t in _allTransactions) {
      final key = DateFormat('yyyy-MM-dd').format(t.tanggal);
      grouped.putIfAbsent(key, () => []).add(t);
    }
    // Urutkan transaksi dalam setiap hari dari terbaru ke terlama
    for (final list in grouped.values) {
      list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    }
    // Urutkan tanggal dari terbaru ke terlama
    final sortedKeys = grouped.keys.toList()..sort((a, b) => a.compareTo(b));
    return {for (final k in sortedKeys.reversed) k: grouped[k]!};
  }

  String _formatTanggalHeader(String dateKey) {
    final date = DateTime.parse(dateKey);
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }

  int _totalPerTanggal(List<TransactionModel> transaksi) {
    int total = 0;
    for (final t in transaksi) {
      if (t.tipe == 'pemasukan') {
        total += t.nominal;
      } else {
        total -= t.nominal;
      }
    }
    return total;
  }

  Future<void> _confirmDeleteTransaction(TransactionModel transaksi) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2130),
          title: const Text(
            'Hapus Transaksi',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Apakah kamu yakin ingin menghapus transaksi ini?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      if (transaksi.id == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: ID transaksi tidak valid')),
          );
        }
        return;
      }

      try {
        await _transactionService.delete(transaksi.id!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil dihapus')),
        );
        await _loadAllTransactions();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus transaksi: $e')),
          );
        }
      }
    }
  }

  void _showTransactionActions(TransactionModel transaksi) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF12141E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFE74C3C),
                ),
                title: const Text(
                  'Hapus Transaksi',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteTransaction(transaksi);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12141E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12141E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF4A90D9)),
              )
            : _allTransactions.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 56,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada transaksi',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadAllTransactions,
                color: const Color(0xFF4A90D9),
                backgroundColor: const Color(0xFF1E2130),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: SizedBox.fromSize()),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final entries = _transaksiPerTanggal.entries.toList();
                        final entry = entries[index];
                        final dateKey = entry.key;
                        final transaksi = entry.value;
                        final totalHari = _totalPerTanggal(transaksi);
                        final isPositif = totalHari >= 0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatTanggalHeader(dateKey),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${isPositif ? '+' : ''}${CurrencyFormatter.format(totalHari.abs())}',
                                    style: TextStyle(
                                      color: isPositif
                                          ? const Color(0xFF2ECC71)
                                          : const Color(0xFFE74C3C),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ...transaksi.map(
                                (t) => TransactionCard(
                                  transaction: t,
                                  onTap: () => _showTransactionActions(t),
                                ),
                              ),
                            ],
                          ),
                        );
                      }, childCount: _transaksiPerTanggal.length),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
              ),
      ),
    );
  }
}
