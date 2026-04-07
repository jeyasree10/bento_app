import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartService = CartService();
    final orderService = OrderService();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        title: const Text("Cart"),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: cartService.getCart(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final cartItems = snapshot.data!;

          if (cartItems.isEmpty) {
            return const Center(
              child: Text(
                "Cart is Empty 🛒",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          final total = cartService.getTotal(cartItems);

          return Column(
            children: [
              /// 🧾 CART ITEMS
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B263B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// 🍔 NAME + PRICE
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "₹${item['price']}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),

                          /// ➕➖ QTY CONTROL
                          Row(
                            children: [
                              /// ➖
                              IconButton(
                                onPressed: () {
                                  cartService.decreaseQty(item['name']);
                                },
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.orange),
                              ),

                              Text(
                                "${item['qty']}",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),

                              /// ➕
                              IconButton(
                                onPressed: () {
                                  cartService.addToCart(
                                      item['name'], item['price']);
                                },
                                icon: const Icon(Icons.add_circle,
                                    color: Colors.orange),
                              ),
                            ],
                          ),

                          /// ❌ DELETE
                          IconButton(
                            onPressed: () {
                              cartService.removeItem(item['name']);
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              /// 💰 TOTAL + ORDER
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF1B263B),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    /// TOTAL
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          "₹$total",
                          style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    /// PLACE ORDER BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          await orderService.placeOrder(cartItems, total);
                          await cartService.clearCart();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Order Placed Successfully ✅")),
                          );
                        },
                        child: const Text(
                          "Place Order",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
