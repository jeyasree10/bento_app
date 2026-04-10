import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final CollectionReference orders =
      FirebaseFirestore.instance.collection('orders');

  /// 🔥 PLACE ORDER (RETURN ORDER ID)
  Future<String> placeOrder({
    required String userName,
    required List<Map<String, dynamic>> cartItems,
    required int total,
  }) async {
    final counterRef = _db.collection('counters').doc('orderCounter');

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    String orderId = "";

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterRef);

      int currentToken = 0;

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        currentToken = data['value'] ?? 0;
      }

      int newToken = currentToken + 1;

      /// ✅ Update counter
      transaction.set(counterRef, {"value": newToken});

      /// ✅ Create order
      final newOrderRef = orders.doc();
      orderId = newOrderRef.id; // 🔥 IMPORTANT

      transaction.set(newOrderRef, {
        "token": newToken,
        "userName": userName,
        "userId": user.uid, // 🔥 MAIN FIX
        "items": cartItems,
        "total": total,
        "status": "Accepted",
        "prepTime": "",
        "createdAt": FieldValue.serverTimestamp(),
      });
    });

    return orderId; // 🔥 RETURN ID FOR TRACKING
  }

  /// 🔥 GET ONLY CURRENT USER ORDERS
  Stream<List<Map<String, dynamic>>> getOrders() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return orders
        .where("userId", isEqualTo: user.uid)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data["id"] = doc.id; // 🔥 VERY IMPORTANT
              return data;
            }).toList());
  }

  /// 🔥 GET SINGLE ORDER (SAFE VERSION)
  Stream<Map<String, dynamic>?> getOrderById(String orderId) {
    return orders.doc(orderId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null; // ✅ FIX FOR RED SCREEN ERROR
      }

      final data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      return data;
    });
  }

  /// 🔥 UPDATE STATUS
  Future<void> updateStatus(String orderId, String status) async {
    await orders.doc(orderId).update({
      "status": status,
    });
  }

  /// 🔥 UPDATE PREP TIME
  Future<void> updatePrepTime(String orderId, String time) async {
    await orders.doc(orderId).update({
      "prepTime": time,
    });
  }

  /// 🔥 OPTIONAL: SIMULATION FLOW
  Future<void> simulateOrderFlow(String orderId) async {
    await Future.delayed(const Duration(seconds: 5));
    await updateStatus(orderId, "Preparing");

    await Future.delayed(const Duration(seconds: 5));
    await updateStatus(orderId, "Ready");

    await Future.delayed(const Duration(seconds: 5));
    await updateStatus(orderId, "Completed");
  }
}
