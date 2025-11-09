import 'package:flutter/material.dart';
import 'package:vaultx_solution/auth/screens/loginscreen.dart';
import 'package:vaultx_solution/loading/loading.dart';
import 'package:vaultx_solution/models/sign_up_model.dart';
import 'package:vaultx_solution/services/api_service.dart';
import 'package:vaultx_solution/screens/otp_screen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _api = ApiService();
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    // Basic validation
    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _error = "Email is required");
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailCtrl.text.trim())) {
      setState(() => _error = "Please enter a valid email address");
      return;
    }

    if (_passCtrl.text.length < 6) {
      setState(() => _error = "Password must be at least 6 characters");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final signupSuccess = await _api.signUp(SignUpModel(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      ));

      // On success, show snackbar and navigate to Login
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Registration successful! Please login.'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate to OTP screen for verification
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(email: _emailCtrl.text),
          ),
        );
        return;
      }
    } catch (e) {
      String errorMsg = e.toString().replaceFirst('Exception: ', '');

      // Make error message more user-friendly
      if (errorMsg.contains('already exists')) {
        errorMsg = 'An account with this email already exists';
      } else if (errorMsg.contains('network')) {
        errorMsg = 'Network error. Please check your connection';
      }

      setState(() => _error = errorMsg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: h,
          child: Stack(children: [
            // Header Image
            SizedBox(
              height: h * 0.35,
              width: double.infinity,
              child: Image.asset('assets/auth.jpg', fit: BoxFit.cover),
            ),

            // Sign Up Form Card
            Positioned(
              top: h * 0.30,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Sign Up",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),

                    // Email
                    const Text("Email",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFFFF1ED),
                        hintText: "Enter email",
                        prefixIcon:
                            const Icon(Icons.mail_outline, color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Password
                    const Text("Password",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFFFF1ED),
                        hintText: "Enter password (min 6 characters)",
                        prefixIcon:
                            const Icon(Icons.lock_outline, color: Colors.red),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Error Message
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    // Sign Up Button
                    ElevatedButton(
                      onPressed: _loading ? null : _onSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text("Sign Up",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                    ),

                    const SizedBox(height: 16),

                    // Navigate to Login
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        ),
                        child: const Text(
                          "Already have an account? LOGIN",
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ),

                    const SizedBox(height: 65),
                    // Uncomment if you want to add social login options
                    // const Center(child: Text("OR CONTINUE WITH")),
                    // const SizedBox(height: 16),

                    // // Social buttons
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     IconButton(
                    //       onPressed: () {},
                    //       icon: Image.network(
                    //         'https://img.icons8.com/color/48/google-logo.png',
                    //         width: 30,
                    //       ),
                    //     ),
                    //     const SizedBox(width: 20),
                    //     IconButton(
                    //       onPressed: () {},
                    //       icon: Image.network(
                    //         'https://img.icons8.com/color/48/facebook-new.png',
                    //         width: 30,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
