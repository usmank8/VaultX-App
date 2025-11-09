// lib/auth/screens/login_page.dart
import 'package:flutter/material.dart';
import 'package:vaultx_solution/loading/loading.dart';
import 'package:vaultx_solution/models/sign_in_model.dart';
import 'package:vaultx_solution/services/api_service.dart';
import 'package:vaultx_solution/auth/screens/profile_registration.dart';
import 'package:vaultx_solution/auth/screens/registerscreen.dart';
import 'package:vaultx_solution/screens/home_page.dart';
import 'package:vaultx_solution/screens/pending_approval_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _api = ApiService();

  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    setState(() => _loading = true);
    try {
      // Login and get token
      final token = await _api.login(SignInModel(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      ));

      // Store token in memory
      if (token != null) {
        _api.setInMemoryToken(token);
        _api.debugToken();
      }

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Login successful!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Check if profile exists
      try {
        debugPrint('Attempting to fetch profile after login...');
        final profile = await _api.getProfile();
        debugPrint('Profile fetch completed: ${profile != null ? "Found" : "Not found"}');

        final prefs = await SharedPreferences.getInstance();
        final isApproved = prefs.getBool('isApprovedBySocietyAdmin') ?? false;

        bool needsResidenceDetails = false;
        if (profile != null) {
          // Check if any residence-related fields are empty
          if (profile.address.isEmpty ||
              profile.block.isEmpty ||
              profile.residence.isEmpty ||
              profile.residenceType.isEmpty) {
            needsResidenceDetails = true;
          }
        }

        if (profile != null && !needsResidenceDetails) {
          // Profile exists and residence details are filled
          if (!isApproved) {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
            );
          } else {
            // Profile exists and is approved
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardPage()),
            );
          }
        } else {
          // No profile or missing residence details, go to profile registration
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfileRegistrationPage()),
          );
        }
      } catch (e) {
        debugPrint('Error checking profile: $e');

        // Check if it's a 500 error from backend
        if (e.toString().contains('500')) {
          debugPrint('Backend returned 500 error - likely database/configuration issue');
          setState(() => _error = 'Server error. Please check backend configuration and database.');
          return;
        }

        // For 404 or other errors, assume no profile exists and go to registration
        if (e.toString().contains('404') || e.toString().contains('not found')) {
          debugPrint('No profile found, redirecting to profile registration');
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfileRegistrationPage()),
          );
        } else {
          // Show the actual error message
          debugPrint('Unexpected error during profile fetch, showing error to user');
          setState(() => _error = e.toString().replaceAll('Exception: ', ''));
          return;
        }
      }
    } catch (e) {
      // Format error message to be more user-friendly
      String errorMsg = e.toString();
      if (errorMsg.contains('Invalid credentials')) {
        errorMsg = 'Invalid email or password';
      } else if (errorMsg.contains('network')) {
        errorMsg = 'Network error. Please check your connection';
      } else {
        errorMsg = errorMsg.replaceAll('Exception: ', '');
        if (errorMsg.length > 100) {
          errorMsg = 'Login failed. Please try again later';
        }
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
          child: Stack(
            children: [
              // Header Image
              SizedBox(
                height: h * 0.35,
                width: double.infinity,
                child: Image.asset(
                  'assets/auth.jpg',
                  fit: BoxFit.cover,
                ),
              ),

              // Login Form Card
              Positioned(
                top: h * 0.30,
                left: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -2)),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Login",
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
                            prefixIcon: const Icon(Icons.mail_outline,
                                color: Colors.red),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
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
                            hintText: "Enter password",
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Colors.red),
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 30),

                        // Error Message
                        if (_error != null)
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style:
                                        TextStyle(color: Colors.red.shade800),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Login Button
                        ElevatedButton(
                          onPressed: _loading ? null : _onLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text("Login",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                        ),

                        const SizedBox(height: 16),

                        // Navigate to Sign Up
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SignUpPage()),
                              );
                            },
                            child: const Text(
                              "Don't have an account? SIGN UP",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 65),
                        //uncomment if you want to add social login options

                        // const Center(child: Text("OR CONTINUE WITH")),
                        // const SizedBox(height: 16),

                        // // Social buttons (optional)
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
