// cart_page.dart  ─  BENTO
// KEY FIX: After placeOrder() succeeds, navigates directly to
// TrackingPage with the real Firestore orderId.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import 'dashboard/tracking_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _placing = false;

  static const _bg = Color(0xFF0D1B2A);
  static const _card = Color(0xFF1B263B);

  @override
  Widget build(BuildContext context) {
    final cartSvc = CartService();
    final orderSvc = OrderService();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('My Cart'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: cartSvc.getCart(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.orange));
          }
          final items = snap.data!;

          if (items.isEmpty) {
            return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                          color: _card, shape: BoxShape.circle),
                      child: const Icon(Icons.shopping_cart_outlined,
                          color: Colors.orange, size: 48),
                    ),
                    const SizedBox(height: 16),
                    const Text('Cart is empty',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text('Add something delicious!',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ]),
            );
          }

          final total = cartSvc.getTotal(items);
          final gst = (total * 0.05).round();
          final grand = total + gst;

          return Column(children: [
            // Items list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  final name = (item['name'] ?? '') as String;
                  final price = ((item['price'] as num?)?.toInt()) ?? 0;
                  final qty = ((item['qty'] as num?)?.toInt()) ?? 1;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: _card, borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(Icons.fastfood_rounded,
                            color: Colors.orange, size: 22),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name.trim(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text('₹$price each',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 11)),
                        ],
                      )),
                      // Qty controls
                      _qtyBtn(Icons.remove_rounded,
                          () => cartSvc.decreaseQty(name)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('$qty',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                      ),
                      _qtyBtn(Icons.add_rounded,
                          () => cartSvc.addToCart(name, price)),
                      const SizedBox(width: 8),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('₹${price * qty}',
                                style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                            GestureDetector(
                              onTap: () => cartSvc.removeItem(name),
                              child: const Icon(Icons.delete_outline_rounded,
                                  color: Colors.red, size: 17),
                            ),
                          ]),
                    ]),
                  );
                },
              ),
            ),

            // Bill summary + Place Order
            Container(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              decoration: const BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(children: [
                _billRow('Subtotal', '₹$total'),
                const SizedBox(height: 5),
                _billRow('GST (5%)', '₹$gst'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: Color(0xFF243447)),
                ),
                _billRow('Total', '₹$grand', bold: true),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      disabledBackgroundColor: Colors.orange.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13)),
                    ),
                    onPressed: _placing
                        ? null
                        : () => _placeOrder(
                            context, items, total, cartSvc, orderSvc),
                    child: _placing
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : Text('Place Order  •  ₹$grand',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                  ),
                ),
              ]),
            ),
          ]);
        },
      ),
    );
  }

  // ── Place order → navigate to Tracking ─────────────────────────
  Future<void> _placeOrder(
    BuildContext context,
    List<Map<String, dynamic>> items,
    int total,
    CartService cartSvc,
    OrderService orderSvc,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _snack(context, 'Please login first ❌', err: true);
      return;
    }

    setState(() => _placing = true);
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final name =
          userDoc.data()?['name'] ?? user.email?.split('@')[0] ?? 'Guest';

      // placeOrder returns the real Firestore document ID
      final orderId = await orderSvc.placeOrder(
          userName: name, cartItems: items, total: total);

      await cartSvc.clearCart();

      if (!mounted) return;

      // Navigate DIRECTLY to tracking with the real orderId
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TrackingPage(orderId: orderId)),
      );
    } catch (e) {
      debugPrint('ORDER ERROR: $e');
      if (mounted)
        _snack(context, 'Something went wrong ❌ Try again', err: true);
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.12),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Icon(icon, color: Colors.orange, size: 15),
        ),
      );

  Widget _billRow(String label, String value, {bool bold = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: bold ? Colors.white : Colors.grey,
                  fontSize: bold ? 15 : 12,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  color: bold ? Colors.orange : Colors.grey,
                  fontSize: bold ? 17 : 12,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      );

  void _snack(BuildContext ctx, String msg, {bool err = false}) =>
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: err ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
}
