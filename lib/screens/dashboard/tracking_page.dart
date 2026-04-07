import 'dart:async';
import 'package:flutter/material.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  int seconds = 600; // 10 mins
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds > 0) {
        setState(() {
          seconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String formatTime(int sec) {
    int min = sec ~/ 60;
    int s = sec % 60;
    return "${min.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        title: const Text("Tracking"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔥 TOKEN BOX
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 2),
                borderRadius: BorderRadius.circular(30),
                color: Colors.orange,
              ),
              child: const Text(
                "Token No: 3404",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),

            const SizedBox(height: 30),

            /// 🔥 TRACKING STEPS
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStep(Icons.check_circle, "Order Accepted", true),
                _buildLine(true),
                _buildStep(Icons.restaurant, "Cooking", true),
                _buildLine(false),
                _buildStep(Icons.done_all, "Ready", false),
                _buildLine(false),
                _buildStep(Icons.delivery_dining, "Pick Up", false),
              ],
            ),

            const SizedBox(height: 40),

            /// 🔥 ESTIMATED TIME BOX
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 2),
                borderRadius: BorderRadius.circular(30),
                color: Colors.orange,
              ),
              child: const Text(
                "Estimated Time: 10 mins",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),

            /// 🔥 LIVE TIMER BOX (NEW POSITION)
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
      ),
    );
  }

  /// 🔥 STEP WIDGET
  Widget _buildStep(IconData icon, String text, bool isActive) {
    return Row(
      children: [
        Icon(
          icon,
          color: isActive ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.orange : Colors.grey,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  /// 🔥 LINE WIDGET
  Widget _buildLine(bool isActive) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      height: 30,
      width: 2,
      color: isActive ? Colors.green : Colors.grey,
    );
  }
}
