import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🔥 ADD THIS
import 'tracking_page.dart';

class OrdersPage extends StatefulWidget {
  final Map<String, int> cart;
  final List<Map<String, dynamic>> items;

  const OrdersPage({super.key, required this.cart, required this.items});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late Map<String, int> _cart;
  bool _orderPlaced = false;

  @override
  void initState() {
    super.initState();
    _cart = Map.from(widget.cart);
  }

  int get _subtotal {
    int total = 0;
    _cart.forEach((name, qty) {
      final item = widget.items.firstWhere(
        (i) => i['name'] == name,
        orElse: () => {'price': 0},
      );
      total += (item['price'] as int) * qty;
    });
    return total;
  }

  int get _gst => (_subtotal * 0.05).round();
  int get _total => _subtotal + _gst;

  /// 🔥 NEW FUNCTION (SAVE TO FIRESTORE)
  Future<void> _placeOrder() async {
    final itemsList = _cart.entries.map((e) {
      return {
        "name": e.key,
        "qty": e.value,
      };
    }).toList();

    await FirebaseFirestore.instance.collection('orders').add({
      "items": itemsList,
      "total": _total,
      "status": "Pending",
      "time": FieldValue.serverTimestamp(),
    });

    setState(() {
      _orderPlaced = true;
      _cart.clear(); // optional
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: const Color(0xFF1B263B),
      ),
      body: _orderPlaced ? _successView() : _mainView(),
    );
  }

  Widget _mainView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          ..._cart.entries.map((e) {
            final item = widget.items.firstWhere(
              (i) => i['name'] == e.key,
              orElse: () => {'price': 0},
            );
            return _cartItem(e.key, e.value, item['price']);
          }),
          const SizedBox(height: 16),
          _pickupSection(),
          const SizedBox(height: 16),
          _summarySection(),
        ],
      ),
    );
  }

  Widget _cartItem(String name, int qty, int price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.fastfood, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis),
                Text("₹$price each",
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.white),
                onPressed: () {
                  setState(() {
                    if (qty == 1) {
                      _cart.remove(name);
                    } else {
                      _cart[name] = qty - 1;
                    }
                  });
                },
              ),
              Text("$qty", style: const TextStyle(color: Colors.white)),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  setState(() => _cart[name] = qty + 1);
                },
              ),
            ],
          ),
          Text("₹${price * qty}", style: const TextStyle(color: Colors.orange)),
        ],
      ),
    );
  }

  Widget _pickupSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Pickup Details", style: TextStyle(color: Colors.white)),
          SizedBox(height: 8),
          Text("Express Counter (5-8 min)",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  /// 🔥 UPDATED BUTTON HERE
  Widget _summarySection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _row("Subtotal", "₹$_subtotal"),
          _row("GST", "₹$_gst"),
          const Divider(color: Colors.grey),
          _row("Total", "₹$_total", bold: true),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _placeOrder, // 🔥 CHANGED
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text("Place Order ₹$_total"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String t, String v, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(t,
            style: TextStyle(
                color: Colors.grey, fontWeight: bold ? FontWeight.bold : null)),
        Text(v,
            style: TextStyle(
                color: Colors.white,
                fontWeight: bold ? FontWeight.bold : null)),
      ],
    );
  }

  Widget _successView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 20),
          const Text("Order Placed!",
              style: TextStyle(color: Colors.white, fontSize: 22)),
          const SizedBox(height: 10),
          Text("₹$_total",
              style: const TextStyle(color: Colors.orange, fontSize: 20)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TrackingPage()),
              );
            },
            child: const Text("Track Order"),
          ),
        ],
      ),
    );
  }
}
