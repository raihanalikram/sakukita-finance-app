import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'form_input_screen.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  final List<String> _namaBulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  String _formatRupiah(double angka) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(angka);
  }

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
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0.0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Periode:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        DropdownButton<int>(
                          value: _selectedMonth,
                          underline: const SizedBox(),
                          items: List.generate(12, (index) {
                            return DropdownMenuItem(
                              value: index + 1,
                              child: Text(_namaBulan[index]),
                            );
                          }),
                          onChanged: (value) {
                            setState(() {
                              _selectedMonth = value!;
                            });
                          },
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<int>(
                          value: _selectedYear,
                          underline: const SizedBox(),
                          items: List.generate(6, (index) {
                            int year = 2024 + index;
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }),
                          onChanged: (value) {
                            setState(() {
                              _selectedYear = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('transactions')
                      .where('userId', isEqualTo: uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('Belum ada riwayat transaksi.'),
                      );
                    }

                    List<QueryDocumentSnapshot> filteredDocs = snapshot
                        .data!
                        .docs
                        .where((doc) {
                          var data = doc.data() as Map<String, dynamic>;
                          Timestamp? timestamp = data['tanggal'];
                          if (timestamp == null) return false;
                          DateTime date = timestamp.toDate();
                          return date.month == _selectedMonth &&
                              date.year == _selectedYear;
                        })
                        .toList();

                    filteredDocs.sort((a, b) {
                      Timestamp tA =
                          (a.data() as Map<String, dynamic>)['tanggal'] ??
                          Timestamp.now();
                      Timestamp tB =
                          (b.data() as Map<String, dynamic>)['tanggal'] ??
                          Timestamp.now();
                      return tB.compareTo(tA);
                    });

                    double totalMasukBulanIni = 0;
                    double totalKeluarBulanIni = 0;

                    for (var doc in filteredDocs) {
                      var data = doc.data() as Map<String, dynamic>;
                      double nominal = (data['nominal'] ?? 0).toDouble();
                      if (data['tipe'] == 'pemasukan') {
                        totalMasukBulanIni += nominal;
                      } else {
                        totalKeluarBulanIni += nominal;
                      }
                    }

                    return ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        Card(
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildRingkasanItem(
                                  'Pemasukan',
                                  '+ ${_formatRupiah(totalMasukBulanIni)}',
                                  Colors.green,
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.grey.shade300,
                                ),
                                _buildRingkasanItem(
                                  'Pengeluaran',
                                  '- ${_formatRupiah(totalKeluarBulanIni)}',
                                  Colors.red,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Petunjuk: Geser transaksi ke Kiri/Kanan untuk Edit atau Hapus',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),

                        if (filteredDocs.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 40.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.event_busy,
                                    size: 64,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tidak ada transaksi di bulan ini.',
                                    style: TextStyle(color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...filteredDocs.map((document) {
                            var data = document.data() as Map<String, dynamic>;
                            String docId = document.id;

                            bool isPengeluaran = data['tipe'] == 'pengeluaran';
                            Color warnaIcon = isPengeluaran
                                ? Colors.red
                                : Colors.green;
                            IconData icon = _getIconForCategory(
                              data['kategoriNama'] ?? 'Lainnya',
                            );
                            String tandaUang = isPengeluaran ? '-' : '+';

                            Timestamp? timestamp = data['tanggal'];
                            String tanggalTeks = timestamp != null
                                ? DateFormat(
                                    'dd MMM yyyy',
                                  ).format(timestamp.toDate())
                                : '';
                            String subtitleTeks =
                                data['catatan']?.isNotEmpty == true
                                ? '$tanggalTeks • ${data['catatan']}'
                                : tanggalTeks;

                            // --- PENERAPAN DISMISSIBLE (GESER UNTUK AKSI) ---
                            return Dismissible(
                              key: Key(docId),
                              direction: DismissDirection.horizontal,
                              background: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                              ),
                              secondaryBackground: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                alignment: Alignment.centerRight,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FormInputScreen(
                                        docId: docId,
                                        initialTipe: data['tipe'],
                                        initialNominal: (data['nominal'] ?? 0)
                                            .toDouble(),
                                        initialKategori: data['kategoriNama'],
                                        initialCatatan: data['catatan'],
                                        initialTanggal: data['tanggal'],
                                      ),
                                    ),
                                  );
                                  return false;
                                } else if (direction ==
                                    DismissDirection.endToStart) {
                                  return await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Hapus Transaksi?'),
                                        content: const Text(
                                          'Apakah kamu yakin ingin menghapus data ini?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text(
                                              'Batal',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection('transactions')
                                                  .doc(docId)
                                                  .delete();
                                              if (context.mounted) {
                                                Navigator.pop(context, true);
                                              }
                                            },
                                            child: const Text(
                                              'Hapus',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                                return false;
                              },
                              child: Card(
                                elevation: 0.0,
                                color: Colors.white,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: warnaIcon.withOpacity(0.1),
                                    child: Icon(icon, color: warnaIcon),
                                  ),
                                  title: Text(
                                    data['kategoriNama'] ?? 'Tanpa Kategori',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    subtitleTeks,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  // Teks nominal kini bebas bernapas!
                                  trailing: Text(
                                    '$tandaUang ${_formatRupiah((data['nominal'] ?? 0).toDouble())}',
                                    style: TextStyle(
                                      color: warnaIcon,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRingkasanItem(String title, String amount, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
