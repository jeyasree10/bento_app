import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  static const _bg = Color(0xFF0D1B2A);
  static const _card = Color(0xFF1B263B);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.orange),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (_) => false);
              }
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(
              child:
                  Text('Not logged in', style: TextStyle(color: Colors.white)))
          : FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
              builder: (ctx, snap) {
                final data = snap.data?.data() as Map<String, dynamic>?;
                final name =
                    data?['name'] ?? user.email?.split('@')[0] ?? 'User';
                final email = data?['email'] ?? user.email ?? '–';
                final phone = data?['phone'] ?? '–';
                final roll = data?['roll'] ?? '–';
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.orange,
                      child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                              fontSize: 36,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 14),
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(email,
                        style: const TextStyle(
                            color: Colors.orange, fontSize: 13)),
                    const SizedBox(height: 28),
                    _row('📱', 'Phone', phone),
                    const SizedBox(height: 10),
                    _row('🎓', 'Roll No', roll),
                    const SizedBox(height: 10),
                    _row('✉️', 'Email', email),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text('Sign Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginPage()),
                                (_) => false);
                          }
                        },
                      ),
                    ),
                  ]),
                );
              }),
    );
  }

  Widget _row(String emoji, String label, String value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
            color: _card, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
            Text(value,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ]),
        ]),
      );
}
