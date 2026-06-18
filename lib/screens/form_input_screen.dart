import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class FormInputScreen extends StatefulWidget {
  final String? docId, initialTipe, initialKategori, initialCatatan;
  final double? initialNominal;
  final Timestamp? initialTanggal;

  const FormInputScreen({
    super.key,
    this.docId,
    this.initialTipe,
    this.initialNominal,
    this.initialKategori,
    this.initialCatatan,
    this.initialTanggal,
  });

  @override
  State<FormInputScreen> createState() => _FormInputScreenState();
}

class _FormInputScreenState extends State<FormInputScreen> {
  late String _tipeTransaksi, _kategori;
  late TextEditingController _nominalController, _catatanController;
  late DateTime _selectedDate;

  final List<String> _kategoriPengeluaran = [
    'Makan dan Minum',
    'Belanja',
    'Bensin',
    'Transportasi',
    'Tagihan',
    'Kesehatan',
    'Asuransi',
    'Donasi',
    'Investasi',
    'Pengeluaran Lainnya',
  ];
  final List<String> _kategoriPemasukan = [
    'Gaji',
    'Bonus',
    'Pemberian',
    'Hasil Investasi',
    'Pemasukan Lainnya',
  ];

  IconData _getIconForCategory(String kategori) {
    switch (kategori) {
      case 'Makan dan Minum':
        return Icons.restaurant;
      case 'Belanja':
        return Icons.shopping_bag;
      case 'Bensin':
        return Icons.local_gas_station;
      case 'Transportasi':
        return Icons.directions_car;
      case 'Tagihan':
        return Icons.receipt_long;
      case 'Kesehatan':
        return Icons.medical_services;
      case 'Asuransi':
        return Icons.security;
      case 'Donasi':
        return Icons.favorite;
      case 'Investasi':
        return Icons.trending_up;
      case 'Gaji':
        return Icons.work;
      case 'Bonus':
        return Icons.stars;
      case 'Pemberian':
        return Icons.card_giftcard;
      case 'Hasil Investasi':
        return Icons.trending_up;
      default:
        return Icons.category;
    }
  }

  @override
  void initState() {
    super.initState();
    _tipeTransaksi = widget.initialTipe == 'pemasukan'
        ? 'Pemasukan'
        : 'Pengeluaran';

    String nominalText = widget.initialNominal != null
        ? widget.initialNominal!.toStringAsFixed(0)
        : '';
    _nominalController = TextEditingController(text: nominalText);
    _catatanController = TextEditingController(
      text: widget.initialCatatan ?? '',
    );

    List<String> listAktif = _tipeTransaksi == 'Pemasukan'
        ? _kategoriPemasukan
        : _kategoriPengeluaran;
    _kategori = widget.initialKategori ?? listAktif.first;
    if (!listAktif.contains(_kategori)) _kategori = 'Lainnya';

    _selectedDate = widget.initialTanggal?.toDate() ?? DateTime.now();
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _simpanKeFirebase() async {
    if (_nominalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal tidak boleh kosong!')),
      );
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final nominal = double.tryParse(_nominalController.text) ?? 0;

    try {
      if (widget.docId == null) {
        await FirebaseFirestore.instance.collection('transactions').add({
          'userId': uid,
          'tipe': _tipeTransaksi.toLowerCase(),
          'nominal': nominal,
          'kategoriNama': _kategori,
          'catatan': _catatanController.text,
          'tanggal': Timestamp.fromDate(_selectedDate),
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await FirebaseFirestore.instance
            .collection('transactions')
            .doc(widget.docId)
            .update({
              'tipe': _tipeTransaksi.toLowerCase(),
              'nominal': nominal,
              'kategoriNama': _kategori,
              'catatan': _catatanController.text,
              'tanggal': Timestamp.fromDate(_selectedDate),
            });
      }
      navigator.pop();
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> currentKategoriList = _tipeTransaksi == 'Pemasukan'
        ? _kategoriPemasukan
        : _kategoriPengeluaran;

    Color activeColor = _tipeTransaksi == 'Pemasukan'
        ? Colors.green
        : Colors.red;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.docId == null ? 'Catat Transaksi' : 'Edit Transaksi',
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.blue,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _tipeTransaksi = 'Pengeluaran';
                          _kategori = _kategoriPengeluaran.first;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _tipeTransaksi == 'Pengeluaran'
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Pengeluaran',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _tipeTransaksi == 'Pengeluaran'
                                    ? Colors.red
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _tipeTransaksi = 'Pemasukan';
                          _kategori = _kategoriPemasukan.first;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _tipeTransaksi == 'Pemasukan'
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Pemasukan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _tipeTransaksi == 'Pemasukan'
                                    ? Colors.green
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    elevation: 0.0,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Nominal',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nominalController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: activeColor,
                            ),
                            decoration: InputDecoration(
                              prefixText: 'Rp ',
                              prefixStyle: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                              hintText: '0',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    elevation: 0.0,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.calendar_month,
                                color: Colors.blue,
                              ),
                            ),
                            title: const Text(
                              'Tanggal',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            subtitle: Text(
                              DateFormat('dd MMMM yyyy').format(_selectedDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _pilihTanggal,
                          ),
                          const Divider(height: 30),

                          DropdownButtonFormField<String>(
                            initialValue: _kategori,
                            decoration: const InputDecoration(
                              labelText: 'Kategori',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                            ),
                            icon: const Icon(Icons.chevron_right),
                            items: currentKategoriList
                                .map(
                                  (k) => DropdownMenuItem(
                                    value: k,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _getIconForCategory(k),
                                          size: 22,
                                          color: Colors.grey[700],
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          k,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _kategori = val!),
                          ),
                          const Divider(height: 30),

                          TextField(
                            controller: _catatanController,
                            decoration: InputDecoration(
                              labelText: 'Catatan (Opsional)',
                              hintText: 'Tulis keterangan...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                              prefixIcon: Icon(
                                Icons.notes,
                                color: Colors.grey[700],
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 40,
                              ),
                            ),
                            maxLines: 2,
                            minLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _simpanKeFirebase,
              style: ElevatedButton.styleFrom(
                backgroundColor: activeColor,
                foregroundColor: Colors.white,
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                widget.docId == null
                    ? 'Simpan Transaksi'
                    : 'Perbarui Transaksi',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
