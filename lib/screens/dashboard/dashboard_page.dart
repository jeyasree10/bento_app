// dashboard_page.dart  ─  BENTO
// ══════════════════════════════════════════════════════════════════════
// CAROUSEL: Reads `todays_special` collection from Firestore in
// real-time. Admin adds items via admin dashboard → they appear here
// instantly. Each slide shows image, name, price, discount badge.
// Auto-slides every 3 seconds. No flicker. Works offline with fallback.
// ══════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import 'profile_page.dart';
import 'tracking_page.dart';
import 'menu_page.dart';

class DashboardPage extends StatefulWidget {
  final String userName;
  const DashboardPage({super.key, required this.userName});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final PageController _pageCtrl =
      PageController(viewportFraction: 0.9, initialPage: 0);
  final CartService _cart = CartService();

  int _currentSlide = 0;
  Timer? _autoScroll;

  // Specials from Firestore — null means still loading
  List<Map<String, dynamic>>? _specials;

  // Fallback popular items when todays_special is empty
  static const _popular = [
    {
      'name': 'Masala Dosa',
      'price': 40,
      'tag': 'Breakfast',
      'image':
          'https://images.pexels.com/photos/12392915/pexels-photo-12392915.jpeg'
    },
    {
      'name': 'Veg Biryani',
      'price': 80,
      'tag': 'Lunch',
      'image':
          'https://media.istockphoto.com/id/1292442851/photo/traditional-hyderabadi-vegetable-veg-dum-biryani-with-mixed-veggies-served-with-mixed-raita.jpg?s=2048x2048&w=is&k=20&c=c37wtHYCYKFOBkAv22hMioLVn7_eGc6VpD4yRQOSLB0='
    },
    {
      'name': 'Samosa',
      'price': 15,
      'tag': 'Snacks',
      'image':
          'https://media.istockphoto.com/id/2148933061/photo/selective-focus-samosa-spiced-potato-filled-pastry-crispy-savory-popular-indian-snack-with.jpg?s=2048x2048&w=is&k=20&c=aTAALtTKdMxwp57zdwo1kN_5vWV9_BOOdmOLvlgO3Os='
    },
    {
      'name': 'Cold Coffee',
      'price': 35,
      'tag': 'Beverage',
      'image':
          'https://media.istockphoto.com/id/528637592/photo/homemade-coffee-cocktail-with-whipped-cream-and-liquid-chocolate.jpg?s=612x612&w=is&k=20&c=qR051xBjB7-bs10lw8_61nocDMBwNsA4w9rByZfo_ak='
    },
    {
      'name': 'Pav Bhaji',
      'price': 70,
      'tag': 'Lunch',
      'image':
          'https://media.istockphoto.com/id/1205948695/photo/paav-bhaji.jpg?s=1024x1024&w=is&k=20&c=2V0yOEglnkcuo1hX2v0tA_DTlF9PWy6yWDZoPCmDzO0='
    },
    {
      'name': 'Idli (3pc)',
      'price': 30,
      'tag': 'Breakfast',
      'image':
          'https://media.istockphoto.com/id/1265553451/photo/south-indian-food-uttapam.jpg?s=1024x1024&w=is&k=20&c=vxsP5epoo-PFVwpVQJZjvUzIHQsHGw8LaOC8of4x3GQ='
    },
  ];

  // Grid items for "Popular Items"
  static const _gridItems = [
    {
      'name': 'Masala Dosa',
      'price': 40,
      'tag': 'Breakfast',
      'image':
          'https://images.pexels.com/photos/12392915/pexels-photo-12392915.jpeg'
    },
    {
      'name': 'Veg Biryani',
      'price': 80,
      'tag': 'Lunch',
      'image':
          'https://media.istockphoto.com/id/1292442851/photo/traditional-hyderabadi-vegetable-veg-dum-biryani-with-mixed-veggies-served-with-mixed-raita.jpg?s=2048x2048&w=is&k=20&c=c37wtHYCYKFOBkAv22hMioLVn7_eGc6VpD4yRQOSLB0='
    },
    {
      'name': 'Samosa',
      'price': 15,
      'tag': 'Snacks',
      'image':
          'https://media.istockphoto.com/id/2148933061/photo/selective-focus-samosa-spiced-potato-filled-pastry-crispy-savory-popular-indian-snack-with.jpg?s=2048x2048&w=is&k=20&c=aTAALtTKdMxwp57zdwo1kN_5vWV9_BOOdmOLvlgO3Os='
    },
    {
      'name': 'Cold Coffee',
      'price': 35,
      'tag': 'Beverage',
      'image':
          'https://media.istockphoto.com/id/528637592/photo/homemade-coffee-cocktail-with-whipped-cream-and-liquid-chocolate.jpg?s=612x612&w=is&k=20&c=qR051xBjB7-bs10lw8_61nocDMBwNsA4w9rByZfo_ak='
    },
    {
      'name': 'Pav Bhaji',
      'price': 70,
      'tag': 'Lunch',
      'image':
          'https://media.istockphoto.com/id/1205948695/photo/paav-bhaji.jpg?s=1024x1024&w=is&k=20&c=2V0yOEglnkcuo1hX2v0tA_DTlF9PWy6yWDZoPCmDzO0='
    },
    {
      'name': 'Idli (3pc)',
      'price': 30,
      'tag': 'Breakfast',
      'image':
          'https://media.istockphoto.com/id/1265553451/photo/south-indian-food-uttapam.jpg?s=1024x1024&w=is&k=20&c=vxsP5epoo-PFVwpVQJZjvUzIHQsHGw8LaOC8of4x3GQ='
    },
    {
      'name': 'Poha',
      'price': 25,
      'tag': 'Breakfast',
      'image':
          'https://media.istockphoto.com/id/1294024658/photo/indian-street-food-poha.jpg?s=612x612&w=is&k=20&c=SU1uIe7lXotH-sKhxtnRLbzhPw-mS-lMFGGeaVRUkW4='
    },
    {
      'name': 'Hakka Noodles',
      'price': 55,
      'tag': 'Chinese',
      'image':
          'https://media.istockphoto.com/id/1159004298/photo/schezwan-noodles-with-vegetables-in-a-plate.jpg?s=612x612&w=is&k=20&c=pT6fa6qNBekfXon8wNnOpegLyRKmJIbZPBkCysQM7Dc='
    },
    {
      'name': 'Mango Lassi',
      'price': 45,
      'tag': 'Beverage',
      'image':
          'https://media.istockphoto.com/id/953714424/photo/mango-lassi-or-smoothie-in-big-glasses-with-curd-cut-fruit-pieces-and-blender.jpg?s=612x612&w=is&k=20&c=o4MjPIAt24gKDeQsX30kDFfUfGnO__atdL0eX5aSX6I='
    },
  ];

  @override
  void initState() {
    super.initState();
    _listenSpecials();
  }

  @override
  void dispose() {
    _autoScroll?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  // ── Real-time listener for todays_special ─────────────────
  void _listenSpecials() {
    FirebaseFirestore.instance.collection('todays_special').snapshots().listen(
        (snap) {
      if (!mounted) return;
      final list = snap.docs
          .map((d) => <String, dynamic>{'id': d.id, ...d.data()})
          .where((s) => s['outOfStock'] != true)
          .toList();
      setState(() => _specials = list);
      _resetAutoScroll(list.isNotEmpty ? list.length : _popular.length);
    }, onError: (_) {
      if (!mounted) return;
      setState(() => _specials = []);
      _resetAutoScroll(_popular.length);
    });
  }

  void _resetAutoScroll(int count) {
    _autoScroll?.cancel();
    if (count < 2) return;
    _autoScroll = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_pageCtrl.hasClients) return;
      final next = (_currentSlide + 1) % count;
      _pageCtrl.animateToPage(next,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  // Slides = Firestore specials if admin added any, else popular fallback
  List<Map<String, dynamic>> get _slides {
    final s = _specials;
    if (s == null) return []; // still loading
    if (s.isEmpty) return List<Map<String, dynamic>>.from(_popular);
    return s;
  }

  static const _bg = Color(0xFF0D1B2A);
  static const _card = Color(0xFF1B263B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('BENTO',
            style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontSize: 20)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfilePage())),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.orange,
                child: Text(
                  widget.userName.isNotEmpty
                      ? widget.userName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Greeting ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hello, ${widget.userName} 👋',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const Text("What's on your plate today?",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
          ),

          // ── Live order mini-tracker ───────────────────────
          _LiveOrderBanner(),

          // ── Carousel header ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Text("🔥 Today's Special",
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  // "LIVE" dot when Firestore specials are loaded
                  if (_specials != null && _specials!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text('LIVE',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ]),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const MenuPage())),
                  child: const Text('See all →',
                      style: TextStyle(color: Colors.orange, fontSize: 12)),
                ),
              ],
            ),
          ),

          // ── CAROUSEL ─────────────────────────────────────
          _specials == null
              // Still loading from Firestore
              ? const SizedBox(
                  height: 190,
                  child: Center(
                      child: CircularProgressIndicator(color: Colors.orange)),
                )
              : _slides.isEmpty
                  // Should never happen (fallback covers it) but just in case
                  ? const SizedBox(height: 0)
                  : SizedBox(
                      height: 190,
                      child: PageView.builder(
                        controller: _pageCtrl,
                        itemCount: _slides.length,
                        onPageChanged: (i) => setState(() => _currentSlide = i),
                        itemBuilder: (_, i) =>
                            _buildSlide(_slides[i], i == _currentSlide),
                      ),
                    ),

          // ── Dot indicators ────────────────────────────────
          if (_slides.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: i == _currentSlide ? 20 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == _currentSlide
                          ? Colors.orange
                          : Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),

          // ── Popular Items ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Popular Items',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const MenuPage())),
                  child: const Text('See all →',
                      style: TextStyle(color: Colors.orange, fontSize: 12)),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _gridItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.60,
              ),
              itemBuilder: (_, i) => _gridCard(_gridItems[i]),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Carousel slide ────────────────────────────────────────
  Widget _buildSlide(Map<String, dynamic> s, bool active) {
    final name = (s['name'] ?? 'Special') as String;
    final price = ((s['price'] ?? 0) as num).toInt();
    final disc = ((s['discountPercent'] ?? 0) as num).toInt();
    final tag = (s['tag'] ?? "Today's Special") as String;
    final imgUrl = (s['image'] ?? '') as String;
    final discPrice = disc > 0 ? (price * (1 - disc / 100)).round() : price;

    return AnimatedScale(
      scale: active ? 1.0 : 0.94,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 12,
                offset: const Offset(0, 5))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(fit: StackFit.expand, children: [
            // Background image
            imgUrl.isNotEmpty
                ? Image.network(imgUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        color: _card,
                        child: const Icon(Icons.restaurant,
                            color: Colors.orange, size: 48)),
                    loadingBuilder: (_, child, p) => p == null
                        ? child
                        : Container(
                            color: _card,
                            child: const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.orange, strokeWidth: 2))))
                : Container(
                    color: _card,
                    child: const Icon(Icons.restaurant,
                        color: Colors.orange, size: 48)),

            // Dark gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.82)],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),

            // Top-left badge
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: disc > 0 ? Colors.orange : Colors.green.shade700,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(tag,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ),

            // Bottom info + add button
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 6)
                            ])),
                    const SizedBox(height: 3),
                    Row(children: [
                      if (disc > 0) ...[
                        Text('₹$price',
                            style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Colors.grey.shade400)),
                        const SizedBox(width: 6),
                      ],
                      Text('₹$discPrice',
                          style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      if (disc > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20)),
                          child: Text('$disc% OFF',
                              style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ]),
                  ],
                )),
                // Add to cart button
                GestureDetector(
                  onTap: () async {
                    await _cart.addToCart(name, discPrice);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('$name added to cart ✅'),
                        backgroundColor: Colors.green.shade700,
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: const BoxDecoration(
                        color: Colors.orange, shape: BoxShape.circle),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Grid card (smaller) ──────────────────────────────────
  Widget _gridCard(Map<String, dynamic> item) {
    final name = item['name'] as String;
    final price = item['price'] as int;
    final img = item['image'] as String;

    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: SizedBox(
            height: 78,
            width: double.infinity,
            child: Image.network(img,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    color: _bg,
                    child: const Icon(Icons.fastfood,
                        color: Colors.orange, size: 28)),
                loadingBuilder: (_, child, p) => p == null
                    ? child
                    : Container(
                        color: _bg,
                        child: const Center(
                            child: CircularProgressIndicator(
                                color: Colors.orange, strokeWidth: 1.5)))),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
          child: Column(children: [
            Text(name.trim(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center),
            const SizedBox(height: 1),
            Text('₹$price',
                style: const TextStyle(color: Colors.grey, fontSize: 10)),
            const SizedBox(height: 5),
            SizedBox(
              width: double.infinity,
              height: 26,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7)),
                ),
                onPressed: () async {
                  await _cart.addToCart(name, price);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('$name added ✅'),
                      backgroundColor: Colors.green.shade700,
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ));
                  }
                },
                child: const Text('Add',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── Live order mini-tracker banner ────────────────────────────
class _LiveOrderBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: OrderService().getOrders(),
      builder: (ctx, snap) {
        if (!snap.hasData || snap.data!.isEmpty) return const SizedBox.shrink();
        final active = snap.data!
            .where(
                (o) => o['status'] != 'Completed' && o['status'] != 'Cancelled')
            .toList();
        if (active.isEmpty) return const SizedBox.shrink();

        final o = active.first;
        final status = (o['status'] ?? 'Accepted') as String;
        final token = o['token'] ?? '';
        final prep = (o['prepTime'] ?? '') as String;

        return GestureDetector(
          onTap: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                  builder: (_) => TrackingPage(orderId: o['id'] ?? 'dummy'))),
          child: Container(
            margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1B263B), Color(0xFF152232)]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.orange.withOpacity(0.4)),
            ),
            child: Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFE8470A), Color(0xFFFF7043)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('TOKEN',
                      style: TextStyle(
                          color: Colors.white60,
                          fontSize: 8,
                          letterSpacing: 1.5)),
                  Text('#$token',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_statusText(status),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  const SizedBox(height: 5),
                  _progressDots(status),
                  if (prep.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text('Est. $prep min',
                          style: TextStyle(
                              color: Colors.orange.shade300, fontSize: 10)),
                    ),
                ],
              )),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.orange, size: 14),
            ]),
          ),
        );
      },
    );
  }

  String _statusText(String s) {
    switch (s) {
      case 'Accepted':
        return '✅ Order Accepted';
      case 'Preparing':
        return '🍳 Being Prepared…';
      case 'Ready':
        return '🎉 Ready! Go pick it up';
      default:
        return s;
    }
  }

  Widget _progressDots(String status) {
    const steps = ['Accepted', 'Preparing', 'Ready', 'Completed'];
    final idx = steps.indexOf(status);
    return Row(
      children: List.generate(
          steps.length,
          (i) => Row(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: i <= idx ? 16 : 8,
                  height: 5,
                  decoration: BoxDecoration(
                    color: i <= idx ? Colors.orange : Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                if (i < steps.length - 1) const SizedBox(width: 3),
              ])),
    );
  }
}
