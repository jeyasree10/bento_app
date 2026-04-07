import 'package:flutter/material.dart';
import 'login_page.dart';
import '../dashboard/dashboard_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _rollCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A), // Dark Blue
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// 🔥 TITLE
                const Text(
                  "Create Account",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                /// 👤 NAME
                _buildTextField(
                  controller: _nameCtrl,
                  label: "Full Name",
                  icon: Icons.person,
                ),

                /// 📧 EMAIL
                _buildTextField(
                  controller: _emailCtrl,
                  label: "Email",
                  icon: Icons.email,
                ),

                /// 📱 PHONE
                _buildTextField(
                  controller: _phoneCtrl,
                  label: "Phone",
                  icon: Icons.phone,
                ),

                /// 🆔 ROLL NO
                _buildTextField(
                  controller: _rollCtrl,
                  label: "Roll No",
                  icon: Icons.badge,
                ),

                /// 🔒 PASSWORD
                _buildTextField(
                  controller: _passCtrl,
                  label: "Password",
                  icon: Icons.lock,
                  isPassword: true,
                  obscure: _obscurePass,
                  toggle: () {
                    setState(() {
                      _obscurePass = !_obscurePass;
                    });
                  },
                ),

                /// 🔒 CONFIRM PASSWORD
                _buildTextField(
                  controller: _confirmCtrl,
                  label: "Confirm Password",
                  icon: Icons.lock,
                  isPassword: true,
                  obscure: _obscureConfirm,
                  toggle: () {
                    setState(() {
                      _obscureConfirm = !_obscureConfirm;
                    });
                  },
                ),

                const SizedBox(height: 25),

                /// 🚀 REGISTER BUTTON
                ElevatedButton(
                  onPressed: () {
                    if (_nameCtrl.text.isEmpty ||
                        _emailCtrl.text.isEmpty ||
                        _passCtrl.text.isEmpty ||
                        _confirmCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill all fields"),
                        ),
                      );
                      return;
                    }

                    if (_passCtrl.text != _confirmCtrl.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Passwords do not match"),
                        ),
                      );
                      return;
                    }

                    /// Navigate to Dashboard
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DashboardPage(
                          userName: _nameCtrl.text,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Create Account",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔁 LOGIN LINK
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.white70),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔧 COMMON TEXTFIELD WIDGET
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? toggle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.orange),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility : Icons.visibility_off,
                    color: Colors.orange,
                  ),
                  onPressed: toggle,
                )
              : null,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white30),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
          ),
        ),
      ),
    );
  }
}
