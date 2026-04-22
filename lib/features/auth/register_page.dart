import 'package:flutter/material.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  final Function(bool) toggleTheme;

  const RegisterPage({super.key, required this.toggleTheme});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController fullNameController        = TextEditingController();
  final TextEditingController emailController           = TextEditingController();
  final TextEditingController usernameController        = TextEditingController();
  final TextEditingController passwordController        = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _agreeToTerms           = false;
  bool _obscurePassword        = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor     = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final cardColor   = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary   = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : Colors.grey[500]!;
    final fieldBg     = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final iconColor   = isDark ? const Color(0xFF64748B) : Colors.grey[500]!;
    final hintColor   = isDark ? const Color(0xFF64748B) : Colors.grey[400]!;
    final labelColor  = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF0F172A);
    final shadowColor = const Color.fromRGBO(0, 0, 0, 0.06);

    InputDecoration _fieldDecoration({
      required String hint,
      required IconData prefixIcon,
      Widget? suffix,
    }) {
      return InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor, fontSize: 14),
        prefixIcon: Icon(prefixIcon, color: iconColor, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: fieldBg,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
      );
    }

    Widget _label(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            text,
            style: TextStyle(color: labelColor, fontWeight: FontWeight.w500, fontSize: 14),
          ),
        );

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 🔷 Logo
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.confirmation_num,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Concierge",
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Text(
                    "Create account",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Fill in the details below to get started.",
                    style: TextStyle(color: textSecondary, fontSize: 14),
                  ),

                  const SizedBox(height: 28),

                  // Full Name
                  _label("Full Name"),
                  TextField(
                    controller: fullNameController,
                    style: TextStyle(color: textPrimary, fontSize: 14),
                    decoration: _fieldDecoration(
                      hint: "e.g. Alex Johnson",
                      prefixIcon: Icons.person_outline,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Email
                  _label("Email"),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: textPrimary, fontSize: 14),
                    decoration: _fieldDecoration(
                      hint: "e.g. alex@email.com",
                      prefixIcon: Icons.email_outlined,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Username
                  _label("Username"),
                  TextField(
                    controller: usernameController,
                    style: TextStyle(color: textPrimary, fontSize: 14),
                    decoration: _fieldDecoration(
                      hint: "e.g. alex_support",
                      prefixIcon: Icons.alternate_email,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Password
                  _label("Password"),
                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(color: textPrimary, fontSize: 14),
                    decoration: _fieldDecoration(
                      hint: "Min. 8 characters",
                      prefixIcon: Icons.lock_outline,
                      suffix: GestureDetector(
                        onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                        child: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: iconColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Confirm Password
                  _label("Confirm Password"),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: TextStyle(color: textPrimary, fontSize: 14),
                    decoration: _fieldDecoration(
                      hint: "Re-enter password",
                      prefixIcon: Icons.lock_outline,
                      suffix: GestureDetector(
                        onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        child: Icon(
                          _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: iconColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Agree to terms
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        activeColor: const Color(0xFF2563EB),
                        checkColor: Colors.white,
                        side: BorderSide(
                          color: isDark ? const Color(0xFF475569) : Colors.grey[400]!,
                          width: 1.5,
                        ),
                        onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                      ),
                      Text(
                        "I agree to the ",
                        style: TextStyle(color: labelColor, fontSize: 14),
                      ),
                      const Text(
                        "Terms of Service",
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Create Account Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Akun berhasil dibuat")),
                        );
                        Future.delayed(const Duration(seconds: 1), () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LoginPage(toggleTheme: widget.toggleTheme),
                            ),
                          );
                        });
                      },
                      child: const Text(
                        "Create Account",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Login link
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginPage(toggleTheme: widget.toggleTheme),
                        ),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 14, color: textSecondary),
                          children: const [
                            TextSpan(text: "Already have an account? "),
                            TextSpan(
                              text: "Login",
                              style: TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}