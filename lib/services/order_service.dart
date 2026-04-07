import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final CollectionReference orders =
      FirebaseFirestore.instance.collection('orders');

  /// 🔥 PLACE ORDER
  Future<void> placeOrder(
      List<Map<String, dynamic>> cartItems, int total) async {
    final int token = DateTime.now().millisecondsSinceEpoch % 10000;

    await orders.add({
      "items": cartItems,
      "total": total,
      "status": "Accepted", // initial status
      "token": token,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  /// 🔥 GET ALL ORDERS (REAL-TIME → PROFILE PAGE)
  Stream<List<Map<String, dynamic>>> getOrders() {
    return orders
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data["id"] = doc.id; // important for updates
              return data;
            }).toList());
  }

  /// 🔥 GET SINGLE ORDER (TRACKING PAGE)
  Stream<Map<String, dynamic>> getOrderById(String orderId) {
    return orders.doc(orderId).snapshots().map((doc) {
      return doc.data() as Map<String, dynamic>;
    });
  }

  /// 🔥 UPDATE STATUS (FOR TRACKING)
  Future<void> updateStatus(String orderId, String status) async {
    await orders.doc(orderId).update({
      "status": status,
    });
  }

  /// 🔥 OPTIONAL: AUTO STATUS FLOW (SIMULATION)
  Future<void> simulateOrderFlow(String orderId) async {
    await Future.delayed(const Duration(seconds: 5));
    await updateStatus(orderId, "Cooking");

    await Future.delayed(const Duration(seconds: 5));
    await updateStatus(orderId, "Ready");

    await Future.delayed(const Duration(seconds: 5));
    await updateStatus(orderId, "Picked");
  }
}
