# 👛 SakuKita - Aplikasi Manajemen Keuangan Pribadi

SakuKita adalah sistem manajemen keuangan digital berbasis *mobile* yang dirancang untuk membantu pengguna melacak arus kas, mengendalikan batas anggaran bulanan, dan merencanakan target tabungan secara cerdas. 

Aplikasi ini dibangun menggunakan kerangka kerja **Flutter** untuk menghasilkan antarmuka yang sangat responsif, serta diintegrasikan dengan **Firebase Cloud Firestore** untuk sinkronisasi data yang mulus secara *real-time*.

## ✨ Fitur Unggulan

* 📊 **Pencatatan Arus Kas Real-Time:** Catat pemasukan dan pengeluaran harian dengan cepat. Data langsung tersinkronisasi ke *Cloud* dalam hitungan milidetik.
* 🛡️ **Privacy Sensor (Sensor Saldo):** Lindungi privasi finansialmu di ruang publik. Ketuk ikon 👁️ untuk menyamarkan seluruh nominal uang di layar secara instan.
* 🎯 **Smart Budgeting:** Tetapkan batas pengeluaran per kategori. Sistem dibekali *Filter Temporal* cerdas yang akan mereset uang "Terpakai" kembali ke Rp 0 setiap pergantian bulan.
* 🐷 **Asisten Target Tabungan:** Wujudkan impian finansialmu! Sistem akan mengalkulasi sisa waktu dan memberikan rekomendasi nominal setoran harian/mingguan yang dinamis.
* 👆 **Navigasi Swipe-to-Action:** Antarmuka modern yang hemat ruang. Cukup geser (*swipe*) kartu riwayat transaksi ke kanan untuk **Edit**, atau ke kiri untuk **Hapus**.
* 💰 **Format Rupiah Otomatis:** Keterbacaan data maksimal dengan tipografi mata uang lokal (contoh: `Rp 1.500.000`).

## 🛠️ Teknologi yang Digunakan (Tech Stack)

* **Front-End:** [Flutter](https://flutter.dev/) (SDK) & Dart
* **Back-End (BaaS):** Google Firebase
* **Autentikasi:** Firebase Authentication (Email & Password)
* **Basis Data:** Cloud Firestore (NoSQL Document-Based)

Dikembangkan oleh:
Raihan Al Ikram (24076095) Pendidikan Teknik Informatika | Departemen Teknik Elektronika | Fakultas Teknik | Universitas Negeri Padang