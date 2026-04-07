import 'package:flutter/material.dart';

class SeatPage extends StatefulWidget {
  const SeatPage({super.key});

  @override
  State<SeatPage> createState() => _SeatPageState();
}

class _SeatPageState extends State<SeatPage> {
  // 0 = available, 1 = selected, 2 = occupied
  List<int> seats = List.generate(30, (index) => 0);

  void toggleSeat(int index) {
    if (seats[index] == 2) return;

    setState(() {
      seats[index] = seats[index] == 1 ? 0 : 1;
    });
  }

  Color getColor(int status) {
    switch (status) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        centerTitle: true,
        title: const Text("Select Seats"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🪑 SEATS GRID
            Expanded(
              child: GridView.builder(
                itemCount: seats.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => toggleSeat(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: getColor(seats[index]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            /// 🚪 DOOR + 🧼 WASH BASIN (BOTTOM RIGHT)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                /// DOOR
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.door_front_door,
                          color: Colors.white, size: 18),
                      SizedBox(width: 5),
                      Text("Door", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                /// WASH BASIN
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.cyan),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.wash, color: Colors.cyan, size: 18),
                      SizedBox(width: 5),
                      Text("Wash Basin", style: TextStyle(color: Colors.cyan)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// 🧱 COUNTER (FULL WIDTH BOTTOM)
            Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.brown,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "COUNTER",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// 🎨 LEGEND
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Legend(color: Colors.green, text: "Available"),
                Legend(color: Colors.orange, text: "Selected"),
                Legend(color: Colors.red, text: "Occupied"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 LEGEND
class Legend extends StatelessWidget {
  final Color color;
  final String text;

  const Legend({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
