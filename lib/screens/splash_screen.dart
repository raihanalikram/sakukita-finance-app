import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSplashScreen();
  }

  void _startSplashScreen() {
    // Durasi splash screen (3 detik)
    _timer = Timer(const Duration(seconds: 3), () {
      _checkUserStatus();
    });
  }

  void _checkUserStatus() {
    // Mencegah error jika layar terlanjur ditutup
    if (!mounted) return;

    // CEK LOGIKA: Apakah user sudah login di Firebase?
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Jika sudah login, langsung ke Dashboard (MainScreen)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      // Jika belum login, arahkan ke halaman Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    // Membatalkan timer jika aplikasi ditutup tiba-tiba (mencegah memory leak)
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Background Gradient Azure yang senada dengan Tema
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.lightBlueAccent],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo SakuKita di tengah
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 100,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'SakuKita',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Smart Digital Wallet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 60),
            // Loading Indicator Putih
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
