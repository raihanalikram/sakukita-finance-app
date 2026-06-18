import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'form_input_screen.dart';
import 'profil_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSaldoTersembunyi = false;

  String _formatRupiah(double angka) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(angka);
  }

  final List<Color> _kategoriColors = const [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.tealAccent,
    Colors.pinkAccent,
    Colors.amberAccent,
    Colors.indigoAccent,
    Colors.cyanAccent,
    Colors.brown,
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
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final String namaUser =
        FirebaseAuth.instance.currentUser?.displayName ?? 'Pengguna';
    final String namaPanggilan = namaUser.split(' ')[0];

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        double totalPemasukan = 0;
        double totalPengeluaran = 0;
        Map<String, double> pengeluaranKategori = {};

        List<QueryDocumentSnapshot> docs = [];
        if (snapshot.hasData) {
          docs = List.from(snapshot.data!.docs);

          docs.sort((a, b) {
            Timestamp tA =
                (a.data() as Map<String, dynamic>)['tanggal'] ??
                Timestamp.now();
            Timestamp tB =
                (b.data() as Map<String, dynamic>)['tanggal'] ??
                Timestamp.now();
            return tB.compareTo(tA);
          });

          for (var doc in docs) {
            var data = doc.data() as Map<String, dynamic>;
            double nominal = (data['nominal'] ?? 0).toDouble();

            if (data['tipe'] == 'pemasukan') {
              totalPemasukan += nominal;
            } else if (data['tipe'] == 'pengeluaran') {
              totalPengeluaran += nominal;
              String kat = data['kategoriNama'] ?? 'Lainnya';
              pengeluaranKategori[kat] =
                  (pengeluaranKategori[kat] ?? 0) + nominal;
            }
          }
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Selamat datang,',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  namaPanggilan,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfilScreen(),
                                ),
                              );
                            },
                            child: const CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.blue,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.lightBlueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Total Saldo',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isSaldoTersembunyi = !_isSaldoTersembunyi;
                                  });
                                },
                                child: Icon(
                                  _isSaldoTersembunyi
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isSaldoTersembunyi
                                ? 'Rp ••••••••'
                                : _formatRupiah(
                                    totalPemasukan - totalPengeluaran,
                                  ),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildIncomeExpense(
                                  'Pemasukan',
                                  totalPemasukan,
                                  Icons.arrow_downward,
                                  true,
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.white54,
                                ),
                                _buildIncomeExpense(
                                  'Pengeluaran',
                                  totalPengeluaran,
                                  Icons.arrow_upward,
                                  false,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    if (totalPengeluaran > 0) ...[
                      const Text(
                        'Distribusi Pengeluaran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            height: 160,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: PieChart(
                                    PieChartData(
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 40,
                                      sections: _buildPieSections(
                                        pengeluaranKategori,
                                        totalPengeluaran,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: _buildLegend(pengeluaranKategori),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    const Text(
                      'Transaksi Terakhir',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (docs.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Text(
                            'Belum ada transaksi.\nYuk catat transaksi pertamamu!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        itemBuilder: (context, index) =>
                            _buildTransactionItem(context, docs[index]),
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIncomeExpense(
    String title,
    double amount,
    IconData icon,
    bool isIncome,
  ) {
    String tanda = isIncome ? '+' : '-';
    String displayAmount = _isSaldoTersembunyi
        ? '$tanda Rp •••••'
        : '$tanda ${_formatRupiah(amount)}';

    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            displayAmount,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    QueryDocumentSnapshot document,
  ) {
    var data = document.data() as Map<String, dynamic>;
    String docId = document.id;
    bool isPengeluaran = data['tipe'] == 'pengeluaran';
    Color warnaIcon = isPengeluaran ? Colors.red : Colors.green;
    IconData icon = _getIconForCategory(data['kategoriNama'] ?? 'Lainnya');
    String tandaUang = isPengeluaran ? '-' : '+';
    String displayNominal = _isSaldoTersembunyi
        ? '$tandaUang Rp •••••'
        : '$tandaUang ${_formatRupiah((data['nominal'] ?? 0).toDouble())}';

    Timestamp? timestamp = data['tanggal'];
    String tanggalTeks = timestamp != null
        ? DateFormat('dd MMM yyyy').format(timestamp.toDate())
        : '';
    String subtitleTeks = data['catatan']?.isNotEmpty == true
        ? '$tanggalTeks • ${data['catatan']}'
        : tanggalTeks;

    // --- PENERAPAN DISMISSIBLE (GESER UNTUK AKSI) ---
    return Dismissible(
      key: Key(docId),
      direction: DismissDirection.horizontal,
      // Background geser ke Kanan (Edit)
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      // Background geser ke Kiri (Hapus)
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Geser ke Kanan: Buka Form Edit, batalkan dismiss (return false)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormInputScreen(
                docId: docId,
                initialTipe: data['tipe'],
                initialNominal: (data['nominal'] ?? 0).toDouble(),
                initialKategori: data['kategoriNama'],
                initialCatatan: data['catatan'],
                initialTanggal: data['tanggal'],
              ),
            ),
          );
          return false;
        } else if (direction == DismissDirection.endToStart) {
          // Geser ke Kiri: Tampilkan Konfirmasi Hapus
          return await showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Hapus Transaksi?'),
              content: const Text(
                'Apakah kamu yakin ingin menghapus data ini?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('transactions')
                        .doc(docId)
                        .delete();
                    if (context.mounted) Navigator.pop(context, true);
                  },
                  child: const Text(
                    'Hapus',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        }
        return false;
      },
      child: Card(
        elevation: 0,
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: warnaIcon.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: warnaIcon),
          ),
          title: Text(
            data['kategoriNama'] ?? 'Tanpa Kategori',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitleTeks, style: const TextStyle(fontSize: 12)),
          // Tombol edit/hapus dihilangkan, ruang teks jadi luas!
          trailing: Text(
            displayNominal,
            style: TextStyle(
              color: warnaIcon,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(
    Map<String, double> data,
    double total,
  ) {
    int i = 0;
    return data.entries.map((entry) {
      final double percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        color: _kategoriColors[(i++) % _kategoriColors.length],
        value: entry.value,
        title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
        radius: 40,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(Map<String, double> data) {
    int i = 0;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _kategoriColors[(i++) % _kategoriColors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
