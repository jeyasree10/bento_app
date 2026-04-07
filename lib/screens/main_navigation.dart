import 'package:flutter/material.dart';

// IMPORT YOUR PAGES (adjust paths if needed)
import 'dashboard/dashboard_page.dart';
import 'dashboard/menu_page.dart';
import 'dashboard/seat_page.dart';
import 'dashboard/tracking_page.dart';
import 'cart_page.dart';

class MainNavigation extends StatefulWidget {
  final String userName;

  const MainNavigation({super.key, required this.userName});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState(); // ✅ VERY IMPORTANT ()

    _pages = [
      DashboardPage(userName: widget.userName),
      MenuPage(),
      CartPage(),
      TrackingPage(),
      SeatPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) {
          setState(() {
            _index = value;
          });
        },
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: "Menu",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: "Track",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_seat),
            label: "Seats",
          ),
        ],
      ),
    );
  }
}
