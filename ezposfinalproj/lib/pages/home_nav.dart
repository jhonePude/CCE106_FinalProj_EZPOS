import 'package:flutter/material.dart';
import '../data/style.dart';
import 'pos_page.dart';
import 'inventory_page.dart';
import 'history_page.dart';
import 'login_page.dart';
import 'loading_page.dart';
import '../services/auth_service.dart';
import '../widgets/app_modals.dart'; // ADDED TO SUPPORT THE CONFIRMATION DIALOG

class HomeNav extends StatefulWidget {
  const HomeNav({super.key});
  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {
  int _currentIndex = 0;
  final List<Widget> _pages = [const POSPage(), const InventoryPage(), const HistoryPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        height: 80, 
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black, width: 1))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _navItem(0, Icons.computer, "POS"), 
          _navItem(1, Icons.inventory_2_outlined, "STOCK"), 
          _navItem(2, Icons.history, "HISTORY"), 
          _navItem(3, Icons.logout, "LOGOUT")
        ]),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () async {
        if (index == 3) {
          // TRiggers confirmation using your themed modal rather than logging out instantly
          AppModals.showConfirmation(
            context: context,
            title: "LOG OUT OF YOUR ACCOUNT?",
            icon: Icons.logout,
            actionColor: AppColors.errorRed,
            onConfirm: () async {
              await AuthService().signOut(); // Sign out from Firebase
              if (mounted) {
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => const LoadingPage(message: "Logging out...", nextPage: LoginPage())
                  )
                );
              }
            },
          );
        } else {
          setState(() => _currentIndex = index);
        }
      },
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.all(8), 
          decoration: isActive ? neoBox(color: AppColors.softYellow, shadow: 1, radius: 8) : null, 
          child: Icon(icon, color: isActive ? Colors.black : Colors.grey) // Changed to Black for visibility
        ),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
      ]),
    );
  }
}