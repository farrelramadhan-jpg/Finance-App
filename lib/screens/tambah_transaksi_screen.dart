import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TambahTransaksiScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const TambahTransaksiScreen({super.key, this.transaction});

  @override
  State<TambahTransaksiScreen> createState() => _TambahTransaksiScreenState();
}

class _TambahTransaksiScreenState extends State<TambahTransaksiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _nominalController = TextEditingController();
  final _kategoriController = TextEditingController();
  final _catatanController = TextEditingController();
  final TransactionService _transactionService = TransactionService();

  String _selectedType = 'pemasukan';
  DateTime _selectedTanggal = DateTime.now();

  final List<String> _kategoriOptions = [
    'Gaji',
    'Belanja',
    'Transportasi',
    'Makanan & Minum',
    'Tagihan',
    'Investasi',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final t = widget.transaction!;
      _judulController.text = t.judul;
      _nominalController.text = t.nominal.toString();
      _kategoriController.text = t.kategori;
      _catatanController.text = t.catatan ?? '';
      _selectedType = t.tipe;
      _selectedTanggal = t.tanggal;
    } else {
      _kategoriController.text = _kategoriOptions.first;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _nominalController.dispose();
    _kategoriController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final nominal =
        int.tryParse(_nominalController.text.replaceAll('.', '')) ?? 0;
    if (nominal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal harus lebih besar dari 0')),
      );
      return;
    }

    final transaction = TransactionModel(
      id: widget.transaction?.id,
      judul: _judulController.text.trim(),
      nominal: nominal,
      tipe: _selectedType,
      kategori: _kategoriController.text.trim(),
      catatan: _catatanController.text.trim().isEmpty
          ? null
          : _catatanController.text.trim(),
      tanggal: _selectedTanggal,
    );

    try {
      if (widget.transaction == null) {
        await _transactionService.insert(transaction);
      } else {
        await _transactionService.update(widget.transaction!.id!, transaction);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.transaction == null
                ? 'Transaksi berhasil ditambahkan'
                : 'Transaksi berhasil diperbarui',
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan transaksi: $e')),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedTanggal,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4A90D9),
              onPrimary: Colors.white,
              surface: Color(0xFF1E2130),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF12141E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTanggal = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transaction != null;
    return Scaffold(
      backgroundColor: const Color(0xFF12141E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12141E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          isEdit ? 'Edit Transaksi' : 'Tambah Transaksi',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1F2B),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Transaksi',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Masukkan semua informasi transaksi dengan jelas agar laporan keuangan tetap rapi dan mudah dilacak.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _buildBadge(
                          label: _selectedType == 'pemasukan'
                              ? 'Penerimaan'
                              : 'Pengeluaran',
                          icon: _selectedType == 'pemasukan'
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: _selectedType == 'pemasukan'
                              ? const Color(0xFF2ECC71)
                              : const Color(0xFFE74C3C),
                        ),
                        const SizedBox(width: 10),
                        _buildBadge(
                          label:
                              '${_selectedTanggal.day.toString().padLeft(2, '0')}/${_selectedTanggal.month.toString().padLeft(2, '0')}/${_selectedTanggal.year}',
                          icon: Icons.calendar_month,
                          color: const Color(0xFF4A90D9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF171A24),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jenis Aksi',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionChip(
                              label: 'Menerima',
                              selected: _selectedType == 'pemasukan',
                              activeColor: const Color(0xFF2ECC71),
                              onTap: () =>
                                  setState(() => _selectedType = 'pemasukan'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionChip(
                              label: 'Mengirim',
                              selected: _selectedType == 'pengeluaran',
                              activeColor: const Color(0xFFE74C3C),
                              onTap: () =>
                                  setState(() => _selectedType = 'pengeluaran'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _judulController,
                        label: 'Judul Transaksi',
                        hintText: 'Contoh: Gaji bulan Mei',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Judul wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      _buildTextField(
                        controller: _nominalController,
                        label: 'Nominal',
                        hintText: '100000',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nominal wajib diisi';
                          }
                          final parsed = int.tryParse(
                            value.replaceAll('.', ''),
                          );
                          if (parsed == null || parsed <= 0) {
                            return 'Masukkan nominal yang valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      _buildDropdownField(
                        label: 'Kategori',
                        value: _kategoriController.text,
                        items: _kategoriOptions,
                        onChanged: (value) {
                          setState(() {
                            _kategoriController.text = value ?? '';
                          });
                        },
                      ),
                      const SizedBox(height: 18),
                      _buildTextField(
                        controller: _catatanController,
                        label: 'Catatan (opsional)',
                        hintText: 'Contoh: Transfer ke rekening BRI',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Tanggal Transaksi',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2130),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_selectedTanggal.day.toString().padLeft(2, '0')}/${_selectedTanggal.month.toString().padLeft(2, '0')}/${_selectedTanggal.year}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF4A90D9),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _saveTransaction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A90D9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isEdit ? 'Perbarui Transaksi' : 'Simpan Transaksi',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF191D27),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF191D27),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: const Color(0xFF12141E),
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white70,
              ),
              style: const TextStyle(color: Colors.white),
              items: items
                  .map(
                    (option) => DropdownMenuItem(
                      value: option,
                      child: Text(
                        option,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionChip({
    required String label,
    required bool selected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? activeColor : const Color(0xFF1E2130),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? activeColor : Colors.white12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF13151F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

