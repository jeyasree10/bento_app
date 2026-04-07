import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  final Map<String, int> cart;

  const HistoryPage({super.key, required this.cart});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _orders = [
    {
      'id':
          "#B${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
      'date': 'Today, 12:30 PM',
      'items': ['Masala Dosa', 'Samosa'],
      'total': 115,
      'status': 'Delivered',
      'emoji': '✅',
    },
    {
      'id':
          "#B${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
      'date': DateTime.now().toString(),
      'items': ['Masala Dosa', 'Samosa'],
      'total': 120,
      'status': 'Delivered',
      'emoji': '✅',
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_selectedFilter == 'All') return _orders;
    return _orders.where((o) => o['status'] == _selectedFilter).toList();
  }

  int get _total => _orders.fold(0, (a, o) => a + (o['total'] as int));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text("Order History"),
        backgroundColor: const Color(0xFF1B263B),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔥 FILTER
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Delivered', 'Cancelled'].map((f) {
                    final sel = _selectedFilter == f;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilter = f),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                sel ? Colors.orange : const Color(0xFF1B263B),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              color: sel ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "${_filtered.length} orders",
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 10),

              /// 📦 ORDER LIST
              ..._filtered.map((order) => _orderCard(order)),

              const SizedBox(height: 16),

              /// 📊 SUMMARY
              _summaryCard(),
            ],
          ),
        ),
      ),
    );
  }

  /// 📦 ORDER CARD
  Widget _orderCard(Map<String, dynamic> order) {
    final delivered = order['status'] == 'Delivered';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP ROW
          Row(
            children: [
              Text(order['id'], style: const TextStyle(color: Colors.white)),
              const SizedBox(width: 8),
              Text(order['emoji']),
              const Spacer(),
              Flexible(
                child: Text(
                  order['date'],
                  style: const TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// ITEMS
          Text(
            (order['items'] as List).join(', '),
            style: const TextStyle(color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 6),

          /// PRICE + BUTTON
          Row(
            children: [
              Text(
                "₹${order['total']}",
                style: const TextStyle(color: Colors.orange),
              ),
              const Spacer(),
              if (delivered)
                TextButton(onPressed: () {}, child: const Text("Reorder")),
            ],
          ),
        ],
      ),
    );
  }

  /// 📊 SUMMARY
  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _row("Total Orders", "${_orders.length}"),
          _row("Amount Spent", "₹$_total"),
        ],
      ),
    );
  }

  Widget _row(String t, String v) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(t, style: const TextStyle(color: Colors.grey)),
        Text(v, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
