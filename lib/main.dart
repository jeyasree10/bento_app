import 'package:bento_app/screens/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bento_app/firebase_options.dart';
import 'screens/auth/login_page.dart';
// Screens
import 'screens/dashboard/dashboard_page.dart';
import 'screens/cart_page.dart';
import 'screens/dashboard/tracking_page.dart';
import 'screens/dashboard/seat_page.dart';
import 'screens/dashboard/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 MUST INITIALIZE FIREBASE
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bento Master',
      theme: ThemeData.dark(),
      home: const LoginPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;

  final List<Widget> pages = const [
    DashboardPage(userName: "User"),
    CartPage(),
    TrackingPage(),
    SeatPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) {
          setState(() {
            _index = value;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Menu"),
          BottomNavigationBarItem(
              icon: Icon(Icons.delivery_dining), label: "Track"),
          BottomNavigationBarItem(icon: Icon(Icons.event_seat), label: "Seat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
