import 'package:flutter/material.dart';
import 'dashboard/dashboard_page.dart';
import 'dashboard/menu_page.dart';
import 'dashboard/tracking_page.dart';
import 'dashboard/seat_page.dart';
import 'dashboard/history_page.dart';
import 'cart_page.dart';
import '../services/order_service.dart';

class MainNavigation extends StatefulWidget {
  final String userName;
  const MainNavigation({super.key, required this.userName});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(userName: widget.userName),
      const MenuPage(),
      const CartPage(),
      _AutoTrack(), // Track — auto-detects active order
      const HistoryPage(), // History tab
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (v) => setState(() => _index = v),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_rounded), label: 'Menu'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_rounded), label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(Icons.delivery_dining_rounded), label: 'Track'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded), label: 'History'),
        ],
      ),
    );
  }
}

// Finds user's latest active order and feeds it to TrackingPage
class _AutoTrack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: OrderService().getOrders(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0D1B2A),
            body:
                Center(child: CircularProgressIndicator(color: Colors.orange)),
          );
        }
        final orders = snap.data ?? [];
        final active = orders
            .where(
                (o) => o['status'] != 'Completed' && o['status'] != 'Cancelled')
            .toList();
        if (active.isEmpty) return const TrackingPage(orderId: 'dummy');
        return TrackingPage(orderId: active.first['id'] ?? 'dummy');
      },
    );
  }
}
