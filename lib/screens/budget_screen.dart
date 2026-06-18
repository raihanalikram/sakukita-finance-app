import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  static String _formatRupiah(double angka) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(angka);
  }

  static IconData _getIconForCategory(String kategori) {
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
      default:
        return Icons.category;
    }
  }

  static void tampilFormTambah(
    BuildContext context, {
    String? docId,
    String? initialKategori,
    double? initialNominal,
  }) {
    final nominalController = TextEditingController(
      text: initialNominal != null ? initialNominal.toStringAsFixed(0) : '',
    );
    String kategoriPilihan = initialKategori ?? 'Makan dan Minum';
    final List<String> kategoriList = [
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
    if (!kategoriList.contains(kategoriPilihan)) {
      kategoriPilihan = 'Pengeluaran Lainnya';
    }
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            docId == null ? 'Atur Anggaran' : 'Edit Anggaran',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    isExpanded:
                        true, // SOLUSI: Menyesuaikan lebar teks dengan ukuran layar
                    initialValue: kategoriPilihan,
                    decoration: InputDecoration(
                      labelText: 'Kategori Pengeluaran',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: kategoriList.map((String k) {
                      return DropdownMenuItem<String>(
                        value: k,
                        child: Row(
                          children: [
                            Icon(
                              _getIconForCategory(k),
                              size: 20,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(k, overflow: TextOverflow.ellipsis),
                            ), // SOLUSI: Mencegah teks menabrak batas
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? val) {
                      setState(() {
                        kategoriPilihan = val!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nominalController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Batas Maksimal (Rp)',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                double batas = double.tryParse(nominalController.text) ?? 0;
                if (batas > 0) {
                  if (docId == null) {
                    await FirebaseFirestore.instance.collection('budgets').add({
                      'userId': uid,
                      'kategoriNama': kategoriPilihan,
                      'nominalBatas': batas,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                  } else {
                    await FirebaseFirestore.instance
                        .collection('budgets')
                        .doc(docId)
                        .update({
                          'kategoriNama': kategoriPilihan,
                          'nominalBatas': batas,
                        });
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          docId == null
                              ? 'Anggaran berhasil disimpan!'
                              : 'Anggaran berhasil diperbarui!',
                        ),
                      ),
                    );
                  }
                }
              },
              child: Text(
                docId == null ? 'Simpan' : 'Perbarui',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Budgeting'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0.0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('transactions')
                .where('userId', isEqualTo: uid)
                .snapshots(),
            builder: (context, trxSnapshot) {
              Map<String, double> pengeluaranKategori = {};
              if (trxSnapshot.hasData) {
                DateTime waktuSekarang = DateTime.now();

                for (var doc in trxSnapshot.data!.docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  if (data['tipe'] == 'pengeluaran') {
                    Timestamp? timestampTrx = data['tanggal'];
                    if (timestampTrx != null) {
                      DateTime tanggalTrx = timestampTrx.toDate();
                      if (tanggalTrx.month == waktuSekarang.month &&
                          tanggalTrx.year == waktuSekarang.year) {
                        String kat = data['kategoriNama'] ?? 'Lainnya';
                        double nom = (data['nominal'] ?? 0).toDouble();
                        pengeluaranKategori[kat] =
                            (pengeluaranKategori[kat] ?? 0) + nom;
                      }
                    }
                  }
                }
              }

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('budgets')
                    .where('userId', isEqualTo: uid)
                    .snapshots(),
                builder: (context, budgetSnapshot) {
                  if (budgetSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!budgetSnapshot.hasData ||
                      budgetSnapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pie_chart_outline,
                            size: 80,
                            color: Colors.blue.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada target anggaran.\nKendalikan pengeluaranmu sekarang!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20.0),
                    itemCount: budgetSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var data =
                          budgetSnapshot.data!.docs[index].data()
                              as Map<String, dynamic>;
                      String docId = budgetSnapshot.data!.docs[index].id;

                      String namaKategori = data['kategoriNama'] ?? 'Kategori';
                      double nominalBatas = (data['nominalBatas'] ?? 0)
                          .toDouble();
                      double terpakai = pengeluaranKategori[namaKategori] ?? 0;

                      double persentase = nominalBatas > 0
                          ? (terpakai / nominalBatas)
                          : 0;

                      Color barColor = Colors.green;
                      if (persentase >= 0.9) {
                        barColor = Colors.red;
                      } else if (persentase >= 0.5) {
                        barColor = Colors.orange;
                      }

                      IconData kategoriIcon = _getIconForCategory(namaKategori);

                      return Card(
                        elevation: 0.0,
                        margin: const EdgeInsets.only(bottom: 16),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: barColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      kategoriIcon,
                                      color: barColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          namaKategori,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Batas: ${_formatRupiah(nominalBatas)}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          color: Colors.blue,
                                        ),
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          tampilFormTambah(
                                            context,
                                            docId: docId,
                                            initialKategori: namaKategori,
                                            initialNominal: nominalBatas,
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                'Hapus Anggaran?',
                                              ),
                                              content: const Text(
                                                'Apakah kamu yakin ingin menghapus batas anggaran ini?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text(
                                                    'Batal',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    FirebaseFirestore.instance
                                                        .collection('budgets')
                                                        .doc(docId)
                                                        .delete();
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text(
                                                    'Hapus',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: persentase > 1.0 ? 1.0 : persentase,
                                  backgroundColor: Colors.grey[200],
                                  color: barColor,
                                  minHeight: 10,
                                ),
                              ),
                              const SizedBox(height: 12),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Terpakai: ${_formatRupiah(terpakai)}',
                                    style: TextStyle(
                                      color: barColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${(persentase * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
