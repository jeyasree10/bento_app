import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/order_service.dart';

class TrackingPage extends StatefulWidget {
  final String orderId;

  const TrackingPage({super.key, required this.orderId});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  int seconds = 0;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  /// 🔥 START TIMER
  void startTimer(int prepMinutes) {
    timer?.cancel();
    seconds = prepMinutes * 60;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds > 0) {
        setState(() {
          seconds--;
        });
      } else {
        t.cancel();
      }
    });
  }

  String formatTime(int sec) {
    int min = sec ~/ 60;
    int s = sec % 60;
    return "${min.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    print("🔥 TRACKING PAGE ID: ${widget.orderId}");

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        title: const Text("Tracking"),
        centerTitle: true,
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: OrderService().getOrderById(widget.orderId),
        builder: (context, snapshot) {
          /// 🔄 LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          /// ❌ ERROR
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error loading order",
                  style: TextStyle(color: Colors.white)),
            );
          }

          /// ❌ NO DATA
          if (!snapshot.hasData || snapshot.data == null) {
            print("❌ ORDER DATA NULL");
            return const Center(
              child: Text(
                "Order not found",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final order = snapshot.data!;
          print("✅ ORDER DATA: $order");

          final status = order['status'] ?? "Accepted";
          final token = order['token'] ?? "";
          final prepTime = order['prepTime'] ?? "0";

          /// 🔥 START TIMER WHEN PREP TIME EXISTS
          if (prepTime != "" && seconds == 0) {
            startTimer(int.tryParse(prepTime) ?? 0);
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
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    "Token No: $token",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(height: 30),

                /// 🔥 STATUS STEPS
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStep("Accepted", status),
                    _buildLine(status, "Accepted"),
                    _buildStep("Preparing", status),
                    _buildLine(status, "Preparing"),
                    _buildStep("Ready", status),
                    _buildLine(status, "Ready"),
                    _buildStep("Completed", status),
                  ],
                ),

                const SizedBox(height: 40),

                /// 🔥 ESTIMATED TIME
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    "Estimated Time: $prepTime mins",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔥 LIVE TIMER
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      const Text("Live Time",
                          style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 5),
                      Text(
                        formatTime(seconds),
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

  /// 🔥 STEP LOGIC
  Widget _buildStep(String step, String status) {
    bool active = _isActive(step, status);

    return Row(
      children: [
        Icon(
          Icons.check_circle,
          color: active ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 10),
        Text(
          step,
          style: TextStyle(
            color: active ? Colors.orange : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildLine(String status, String step) {
    bool active = _isActive(step, status);

    return Container(
      margin: const EdgeInsets.only(left: 10),
      height: 30,
      width: 2,
      color: active ? Colors.green : Colors.grey,
    );
  }

  /// 🔥 STATUS FLOW
  bool _isActive(String step, String status) {
    const steps = ["Accepted", "Preparing", "Ready", "Completed"];
    return steps.indexOf(step) <= steps.indexOf(status);
  }
}
