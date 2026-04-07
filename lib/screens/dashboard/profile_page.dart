import 'package:flutter/material.dart';
import '../../services/order_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text("Your Orders"),
        backgroundColor: const Color(0xFF0D1B2A),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: orderService.getOrders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!;

          if (orders.isEmpty) {
            return const Center(
              child: Text(
                "No Orders Yet",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B263B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TOKEN + STATUS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Token: ${order['token']}",
                          style: const TextStyle(color: Colors.orange),
                        ),
                        Text(
                          order['status'],
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// ITEMS
                    Column(
                      children: (order['items'] as List).map<Widget>((item) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${item['name']} x${item['qty']}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              "₹${item['price']}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        );
                      }).toList(),
                    ),

                    const Divider(color: Colors.grey),

                    /// TOTAL
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total",
                            style: TextStyle(color: Colors.white)),
                        Text(
                          "₹${order['total']}",
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
