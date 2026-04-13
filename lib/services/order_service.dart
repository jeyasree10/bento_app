import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference orders =
      FirebaseFirestore.instance.collection('orders');

  // Place a new order — returns the Firestore document ID
  Future<String> placeOrder({
    required String userName,
    required List<Map<String, dynamic>> cartItems,
    required int total,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final counterRef = _db.collection('counters').doc('orderCounter');
    String orderId = '';

    await _db.runTransaction((tx) async {
      final snap = await tx.get(counterRef);
      int current = 0;
      if (snap.exists && snap.data() != null) {
        current = (snap.data() as Map<String, dynamic>)['value'] ?? 0;
      }
      final token = current + 1;
      tx.set(counterRef, {'value': token});

      final ref = orders.doc();
      orderId = ref.id;
      tx.set(ref, {
        'token': token,
        'userName': userName,
        'userId': user.uid,
        'items': cartItems,
        'total': total,
        'status': 'Accepted',
        'prepTime': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    return orderId;
  }

  // Stream all orders for the current user, newest first
  Stream<List<Map<String, dynamic>>> getOrders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return orders
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              data['id'] = d.id;
              return data;
            }).toList());
  }

  // Stream a single order by ID
  Stream<Map<String, dynamic>?> getOrderById(String orderId) {
    return orders.doc(orderId).snapshots().map((d) {
      if (!d.exists || d.data() == null) return null;
      final data = d.data() as Map<String, dynamic>;
      data['id'] = d.id;
      return data;
    });
  }

  Future<void> updateStatus(String id, String status) =>
      orders.doc(id).update({'status': status});

  Future<void> updatePrepTime(String id, String time) =>
      orders.doc(id).update({'prepTime': time});
}
