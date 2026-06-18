import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TabunganScreen extends StatelessWidget {
  const TabunganScreen({super.key});

  static String _formatRupiah(double angka) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(angka);
  }

  static void tampilFormTambah(
    BuildContext context, {
    String? docId,
    String? initialNama,
    double? initialTarget,
    Timestamp? initialTenggat,
  }) {
    final namaController = TextEditingController(text: initialNama ?? '');
    final targetController = TextEditingController(
      text: initialTarget != null ? initialTarget.toStringAsFixed(0) : '',
    );
    DateTime selectedDate =
        initialTenggat?.toDate() ??
        DateTime.now().add(const Duration(days: 30));
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            docId == null ? 'Buat Target Tabungan' : 'Edit Target',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: namaController,
                      decoration: InputDecoration(
                        labelText: 'Untuk apa tabungan ini?',
                        hintText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: targetController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Target Nominal (Rp)',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Target Tercapai Pada:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      subtitle: Text(
                        DateFormat('dd MMMM yyyy').format(selectedDate),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(
                        Icons.calendar_month,
                        color: Colors.blue,
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                    ),
                  ],
                ),
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
                double target = double.tryParse(targetController.text) ?? 0;
                if (namaController.text.isNotEmpty && target > 0) {
                  if (docId == null) {
                    await FirebaseFirestore.instance.collection('savings').add({
                      'userId': uid,
                      'namaTarget': namaController.text,
                      'targetNominal': target,
                      'terkumpul': 0.0,
                      'tenggatWaktu': Timestamp.fromDate(selectedDate),
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                  } else {
                    await FirebaseFirestore.instance
                        .collection('savings')
                        .doc(docId)
                        .update({
                          'namaTarget': namaController.text,
                          'targetNominal': target,
                          'tenggatWaktu': Timestamp.fromDate(selectedDate),
                        });
                  }
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text(
                'Simpan',
                style: TextStyle(
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

  static void tampilFormSetor(
    BuildContext context,
    String docId,
    double terkumpulSaatIni,
    double targetNominal,
  ) {
    final setorController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Setor Tabungan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: setorController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Nominal Setoran (Rp)',
            prefixText: 'Rp ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              double setor = double.tryParse(setorController.text) ?? 0;
              if (setor > 0) {
                double totalBaru = terkumpulSaatIni + setor;
                if (totalBaru > targetNominal) totalBaru = targetNominal;
                await FirebaseFirestore.instance
                    .collection('savings')
                    .doc(docId)
                    .update({'terkumpul': totalBaru});
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text(
              'Setor',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Target Tabungan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0.0,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('savings')
            .where('userId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.savings_outlined,
                    size: 80,
                    color: Colors.blue.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada target tabungan.\nYuk mulai wujudkan mimpimu!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              String docId = snapshot.data!.docs[index].id;

              String namaTarget = data['namaTarget'] ?? 'Tabungan';
              double targetNominal = (data['targetNominal'] ?? 0).toDouble();
              double terkumpul = (data['terkumpul'] ?? 0).toDouble();
              Timestamp? tenggatWaktu = data['tenggatWaktu'];

              double persentase = targetNominal > 0
                  ? (terkumpul / targetNominal)
                  : 0;
              bool isTercapai = terkumpul >= targetNominal;

              DateTime targetDate = tenggatWaktu?.toDate() ?? DateTime.now();
              int sisaHari = targetDate.difference(DateTime.now()).inDays;
              double sisaNominal = targetNominal - terkumpul;

              String rekomendasiTeks = '';
              if (isTercapai) {
                rekomendasiTeks =
                    '🎉 Selamat! Target tabunganmu telah tercapai!';
              } else if (sisaHari <= 0) {
                rekomendasiTeks =
                    'Waktu tenggat telah habis. Yuk perbarui targetmu!';
              } else {
                double perHari = sisaNominal / sisaHari;
                double perMinggu = perHari * 7;
                rekomendasiTeks =
                    'Sisihkan ${_formatRupiah(perHari)} / hari\natau ${_formatRupiah(perMinggu)} / minggu';
              }

              return Card(
                elevation: 0.0,
                margin: const EdgeInsets.only(bottom: 20),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  namaTarget,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Target: ${_formatRupiah(targetNominal)}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.blue,
                                ),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                onPressed: () => tampilFormTambah(
                                  context,
                                  docId: docId,
                                  initialNama: namaTarget,
                                  initialTarget: targetNominal,
                                  initialTenggat: tenggatWaktu,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection('savings')
                                      .doc(docId)
                                      .delete();
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
                          color: isTercapai ? Colors.green : Colors.blue,
                          minHeight: 12,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Terkumpul: ${_formatRupiah(terkumpul)}',
                            style: TextStyle(
                              color: isTercapai ? Colors.green : Colors.blue,
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
                      const Divider(height: 30),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isTercapai
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isTercapai
                                  ? Icons.check_circle
                                  : Icons.lightbulb_outline,
                              color: isTercapai ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                rekomendasiTeks,
                                style: TextStyle(
                                  color: isTercapai
                                      ? Colors.green[800]
                                      : Colors.orange[800],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (!isTercapai)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.blue,
                            ),
                            label: const Text(
                              'Setor Tabungan',
                              style: TextStyle(color: Colors.blue),
                            ),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(color: Colors.blue),
                            ),
                            onPressed: () => tampilFormSetor(
                              context,
                              docId,
                              terkumpul,
                              targetNominal,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
