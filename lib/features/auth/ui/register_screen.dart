import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/auth_provider.dart';
import '../../../shared/widgets/custom_input.dart';
import '../../../shared/widgets/global_toast.dart';
import '../../../shared/layouts/main_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent, // Let the gradient show
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F5FF), Color(0xFFF7F8FA)],
          ),
        ),
        child: Stack(
          children: [
            // 1. Refined illustration with modern container
            Positioned(
              top: screenHeight * 0.08,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  height: 160,
                  width: 160,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE6F0FF), Color(0xFFD9E8FF)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 90,
                    color: Colors.blue.shade400,
                  ),
                ),
              ),
            ),

            // 2. Main Content Card – modern, floating, slightly translucent
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: screenHeight * 0.70,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 30,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 40,
                    ),
                    child: Column(
                      children: [
                        // --- MODERN HEADER ---
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: Color(0xFF1E2A3A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Use proper information to continue',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7A8699),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // --- INPUTS (unchanged) ---
                        CustomInput(
                          hintText: 'Full name',
                          prefixIcon: Icons.badge_outlined,
                          controller: _nameController,
                        ),
                        const SizedBox(height: 16),
                        CustomInput(
                          hintText: 'Email address',
                          prefixIcon: Icons.email_outlined,
                          controller: _emailController,
                        ),
                        const SizedBox(height: 16),
                        CustomInput(
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline,
                          controller: _passwordController,
                          isPassword: true,
                        ),
                        const SizedBox(height: 24),

                        // --- POLICY TEXT (refined, but still static) ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text.rich(
                            TextSpan(
                              text: 'By signing up, you are agree to our ',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF7A8699),
                                height: 1.5,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.blue.shade200,
                                  ),
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.blue.shade200,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // --- CREATE BUTTON (modern styling) ---
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            return SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: auth.isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF0066FF),
                                      ),
                                    )
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF0066FF,
                                        ),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      onPressed: () async {
                                        try {
                                          await auth.register(
                                            _nameController.text,
                                            _emailController.text,
                                            _passwordController.text,
                                            context: context,
                                          );
                                          if (auth.user != null && mounted) {
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const MainLayout(),
                                              ),
                                              (route) => false,
                                            );
                                          }
                                        } catch (e) {
                                          if (!mounted) return;
                                          context.showErrorToast(
                                            "REGISTER FAILED: $e",
                                          );
                                        }
                                      },
                                      child: const Text('Create Account'),
                                    ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. Back Button (unchanged)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black87,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
