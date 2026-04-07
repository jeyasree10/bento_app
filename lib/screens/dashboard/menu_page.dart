import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/food_model.dart';
import '../../services/cart_service.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final CartService cartService = CartService();

  String selectedCategory = "Breakfast";

  final List<String> categories = [
    "Breakfast",
    "Lunch",
    "Chinese",
    "Snacks",
    "Beverages",
    "Fresh & Chilled Beverages",
    "Packaged Foods"
  ];

  @override
  Widget build(BuildContext context) {
    final items =
        foodList.where((e) => e.category == selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text("Menu"),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D1B2A),
      ),
      body: Column(
        children: [
          /// CATEGORY BAR
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (_, index) {
                final cat = categories[index];
                final isSelected = cat == selectedCategory;

                return GestureDetector(
                  onTap: () {
                    setState(() => selectedCategory = cat);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFA500)
                          : const Color(0xFF1B263B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),

          /// MENU GRID
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (_, index) {
                return _menuCard(items[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 MENU CARD
  Widget _menuCard(FoodItem item) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('cart').snapshots(),
      builder: (context, snapshot) {
        int qty = 0;

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            if (doc.id == item.name) {
              qty = doc['qty'];
            }
          }
        }

        return Card(
          color: const Color(0xFF1B263B),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              /// IMAGE
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    item.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              /// NAME
              Text(
                item.name,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),

              /// PRICE
              Text(
                "₹${item.price}",
                style: const TextStyle(color: Colors.grey),
              ),

              /// BUTTON SECTION
              Padding(
                padding: const EdgeInsets.all(6),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA500),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// ➖ REMOVE
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white),
                        onPressed: () async {
                          if (qty > 1) {
                            await FirebaseFirestore.instance
                                .collection('cart')
                                .doc(item.name)
                                .update({'qty': qty - 1});
                          } else if (qty == 1) {
                            await cartService.removeItem(item.name);
                          }
                        },
                      ),

                      /// COUNT
                      Text(
                        "$qty",
                        style: const TextStyle(color: Colors.white),
                      ),

                      /// ➕ ADD (🔥 UPDATED WITH SNACKBAR)
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () async {
                          await cartService.addToCart(
                            item.name,
                            int.parse(item.price),
                          );

                          /// ✅ SNACKBAR ADDED HERE
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${item.name} added to cart"),
                              duration: const Duration(seconds: 2),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
