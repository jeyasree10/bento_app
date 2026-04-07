import 'package:flutter/material.dart';
import '../../services/cart_service.dart';
import 'profile_page.dart';

class DashboardPage extends StatelessWidget {
  final String userName;

  const DashboardPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final cartService = CartService();

    final menu = [
      {
        "name": "Masala Dosa",
        "price": 40,
        "image":
            "https://images.pexels.com/photos/12392915/pexels-photo-12392915.jpeg"
      },
      {
        "name": "Mango Milkshake",
        "price": 50,
        "image":
            "https://media.istockphoto.com/id/953714424/photo/mango-lassi-or-smoothie-in-big-glasses-with-curd-cut-fruit-pieces-and-blender.jpg?s=612x612&w=is&k=20&c=o4MjPIAt24gKDeQsX30kDFfUfGnO__atdL0eX5aSX6I="
      },
      {
        "name": "Idli",
        "price": 30,
        "image": "https://foodish-api.com/images/idly/idly18.jpg"
      },
      {
        "name": "Medu Vada",
        "price": 30,
        "image":
            "https://www.secondrecipe.com/wp-content/uploads/2019/12/medu-wada-674x900.jpg"
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),

      // ✅ APPBAR ADDED HERE
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        title: const Text("Dashboard"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfilePage(),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : "U",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HELLO TEXT
            Text(
              "Hello, $userName 👋",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const Text(
              "Today's special",
              style: TextStyle(
                fontSize: 18,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            /// MENU GRID
            Expanded(
              child: GridView.builder(
                itemCount: menu.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final item = menu[index];

                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B263B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        /// IMAGE
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: Image.network(
                              item['image'] as String,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),

                        /// NAME
                        Text(
                          item['name'] as String,
                          style: const TextStyle(color: Colors.white),
                        ),

                        /// PRICE
                        Text(
                          "₹${item['price']}",
                          style: const TextStyle(color: Colors.white),
                        ),

                        /// BUTTON
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          onPressed: () async {
                            await cartService.addToCart(
                              item['name'] as String,
                              item['price'] as int,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${item['name']} added to cart"),
                                duration: const Duration(seconds: 2),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child: const Text("Add"),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
