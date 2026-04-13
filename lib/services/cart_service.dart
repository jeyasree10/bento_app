import 'package:cloud_firestore/cloud_firestore.dart';

class CartService {
  final CollectionReference cart =
      FirebaseFirestore.instance.collection('cart');

  /// 🔥 ADD TO CART (REAL-TIME + QTY)
  Future<void> addToCart(String name, int price) async {
    final doc = cart.doc(name);

    final snapshot = await doc.get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;

      int currentQty = data['qty'] ?? 0;

      await doc.update({
        'qty': currentQty + 1,
      });
    } else {
      await doc.set({
        'name': name,
        'price': price,
        'qty': 1,
        'time': DateTime.now(),
      });
    }
  }

  /// 🔥 REMOVE ITEM
  Future<void> removeItem(String name) async {
    await cart.doc(name).delete();
  }

  /// 🔥 DECREASE QTY
  Future<void> decreaseQty(String name) async {
    final doc = cart.doc(name);
    final snapshot = await doc.get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      int qty = data['qty'] ?? 1;

      if (qty > 1) {
        await doc.update({'qty': qty - 1});
      } else {
        await doc.delete();
      }
    }
  }

  /// 🔥 CLEAR CART
  Future<void> clearCart() async {
    final snapshot = await cart.get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// 🔥 REAL-TIME CART STREAM
  Stream<List<Map<String, dynamic>>> getCart() {
    return cart.snapshots().map((snapshot) => snapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).toList());
  }

  /// 🔥 CALCULATE TOTAL (REAL-TIME)
  int getTotal(List<Map<String, dynamic>> cartItems) {
    int total = 0;

    for (var item in cartItems) {
      total += ((item["price"] as num) * (item["qty"] as num)).toInt();
    }

    return total;
  }
}
