import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'form_input_screen.dart';
import 'riwayat_screen.dart';
import 'budget_screen.dart';
import 'tabungan_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const RiwayatScreen(),
    const BudgetScreen(),
    const TabunganScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentIndex == 2) {
            BudgetScreen.tampilFormTambah(context);
          } else if (_currentIndex == 3) {
            TabunganScreen.tampilFormTambah(context);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FormInputScreen()),
            );
          }
        },
        backgroundColor: Colors.blue,
        elevation: 4.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.savings), label: 'Tabungan'),
        ],
      ),
    );
  }
}
