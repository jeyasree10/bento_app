import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackingPage extends StatelessWidget {
  final String orderId;

  const TrackingPage({super.key, required this.orderId});

  /// 🔥 STATUS COLOR LOGIC
  Color getStatusColor(String currentStatus, String step) {
    List<String> steps = ["Accepted", "Preparing", "Ready", "Completed"];

    int currentIndex = steps.indexOf(currentStatus);
    int stepIndex = steps.indexOf(step);

    if (stepIndex <= currentIndex) {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }

  /// 🔥 TIMER LOGIC (SAFE)
  String getRemainingTime(Timestamp? createdAt, String prepTime) {
    if (createdAt == null || prepTime.isEmpty) return "Waiting...";

    final created = createdAt.toDate();
    final prepMinutes = int.tryParse(prepTime) ?? 0;

    final endTime = created.add(Duration(minutes: prepMinutes));
    final now = DateTime.now();

    final diff = endTime.difference(now);

    if (diff.isNegative) {
      return "Ready";
    }

    int min = diff.inMinutes;
    int sec = diff.inSeconds % 60;

    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    print("TRACKING ORDER ID: $orderId"); // 🔥 DEBUG

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        title: const Text("Tracking"),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .snapshots(),
        builder: (context, snapshot) {
          /// 🔹 LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          /// 🔹 ERROR
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          /// 🔹 NO DATA
          if (!snapshot.hasData) {
            return const Center(child: Text("No data"));
          }

          final doc = snapshot.data!;

          /// 🔹 DOCUMENT NOT FOUND
          if (!doc.exists) {
            return const Center(child: Text("Order not found"));
          }

          final rawData = doc.data();

          /// 🔹 NULL SAFETY
          if (rawData == null) {
            return const Center(child: Text("No data available"));
          }

          final data = rawData as Map<String, dynamic>;

          /// 🔹 SAFE VALUES
          final String status = data['status'] ?? "Accepted";
          final token = data['token'] ?? "";
          final String prepTime = data['prepTime'] ?? "";

          Timestamp? createdAt;
          if (data['createdAt'] is Timestamp) {
            createdAt = data['createdAt'];
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// 🔥 TOKEN
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange, width: 2),
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.orange,
                  ),
                  child: Text(
                    "Token No: $token",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 30),

                /// 🔥 STATUS STEPS
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStep(Icons.check_circle, "Accepted",
                        getStatusColor(status, "Accepted")),
                    _buildLine(getStatusColor(status, "Preparing")),
                    _buildStep(Icons.restaurant, "Preparing",
                        getStatusColor(status, "Preparing")),
                    _buildLine(getStatusColor(status, "Ready")),
                    _buildStep(Icons.done_all, "Ready",
                        getStatusColor(status, "Ready")),
                    _buildLine(getStatusColor(status, "Completed")),
                    _buildStep(Icons.delivery_dining, "Pick Up",
                        getStatusColor(status, "Completed")),
                  ],
                ),

                const SizedBox(height: 40),

                /// 🔥 ESTIMATED TIME
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange, width: 2),
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.orange,
                  ),
                  child: Text(
                    prepTime.isEmpty
                        ? "Waiting for prep time"
                        : "Estimated Time: $prepTime mins",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔥 LIVE TIMER
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange, width: 2),
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.orange,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Live Time",
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        getRemainingTime(createdAt, prepTime),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 🔥 STEP UI
  Widget _buildStep(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(color: color, fontSize: 16),
        ),
      ],
    );
  }

  /// 🔥 LINE UI
  Widget _buildLine(Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      height: 30,
      width: 2,
      color: color,
    );
  }
}
