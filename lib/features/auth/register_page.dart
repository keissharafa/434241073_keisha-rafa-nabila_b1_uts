import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  final Function(bool) toggleTheme;

  const RegisterPage({super.key, required this.toggleTheme});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Handle user registration process via Supabase Authentication
  Future<void> _handleRegister() async {
    // 1. Validate required fields and password match
    if (fullNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        usernameController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      _showError("All fields are required.");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showError("Passwords do not match.");
      return;
    }

    if (!_agreeToTerms) {
      _showError("You must agree to the Terms of Service.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Register user to Supabase Authentication
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final User? user = res.user;
      if (user == null) {
        throw Exception("Failed to register account. Please try again.");
      }

      // 3. Insert user profile data into the 'users' table
      await Supabase.instance.client.from('users').insert({
        'id': user.id, // Link profile ID with Auth ID
        'full_name': fullNameController.text.trim(),
        'email': emailController.text.trim(),
        'username': usernameController.text.trim(),
        'password': passwordController.text,
        'role': 'USER', // Assign default role
        'is_active': true,
      });

      if (!mounted) return;

      // 4. Show success message and navigate to Login Page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Account created successfully! Please login.",
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: const Color(0xFF21D07B), // Success indicator
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginPage(toggleTheme: widget.toggleTheme),
        ),
      );
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError("An error occurred: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.plusJakartaSans()),
        backgroundColor: const Color(0xFFF45B69), // Error indicator
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── STYLE GUIDE PALETTE ──
    const primary = Color(0xFF6C63FF);

    final bgColor = isDark ? const Color(0xFF14142B) : const Color(0xFFEDEFF7);
    final cardColor = isDark ? const Color(0xFF1F1B3A) : Colors.white;
    final textPrimary = isDark
        ? const Color(0xFFF1F1FB)
        : const Color(0xFF14142B);
    final textSecondary = isDark
        ? const Color(0xFFA0A0B8)
        : const Color(0xFF92929D);
    final fieldBg = isDark ? const Color(0xFF14142B) : const Color(0xFFF0F1F6);
    final iconColor = isDark
        ? const Color(0xFFA0A0B8)
        : const Color(0xFF92929D);
    final hintColor = isDark
        ? const Color(0xFFA0A0B8)
        : const Color(0xFF92929D);
    final labelColor = textPrimary;
    final borderColor = isDark
        ? const Color(0xFF2E2A52)
        : const Color(0xFFF0F1F6);
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.25)
        : primary.withOpacity(0.06);

    InputDecoration fieldDecoration({
      required String hint,
      required IconData prefixIcon,
      Widget? suffix,
    }) {
      return InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(color: hintColor, fontSize: 14),
        prefixIcon: Icon(prefixIcon, color: iconColor, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: fieldBg,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
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
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      );
    }

    Widget buildLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: labelColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
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
                border: isDark ? Border.all(color: borderColor) : null,
                boxShadow: isDark
                    ? []
                    : [
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
                  // Logo Section
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.confirmation_num,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Concierge",
                        style: GoogleFonts.plusJakartaSans(
                          color: primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Text(
                    "Create account",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Fill in the details below to get started.",
                    style: GoogleFonts.plusJakartaSans(
                      color: textSecondary,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Full Name Field
                  buildLabel("Full Name"),
                  TextField(
                    controller: fullNameController,
                    style: GoogleFonts.plusJakartaSans(
                      color: textPrimary,
                      fontSize: 14,
                    ),
                    decoration: fieldDecoration(
                      hint: "e.g. Alex Johnson",
                      prefixIcon: Icons.person_outline,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Email Field
                  buildLabel("Email"),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.plusJakartaSans(
                      color: textPrimary,
                      fontSize: 14,
                    ),
                    decoration: fieldDecoration(
                      hint: "e.g. alex@email.com",
                      prefixIcon: Icons.email_outlined,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Username Field
                  buildLabel("Username"),
                  TextField(
                    controller: usernameController,
                    style: GoogleFonts.plusJakartaSans(
                      color: textPrimary,
                      fontSize: 14,
                    ),
                    decoration: fieldDecoration(
                      hint: "e.g. alex_support",
                      prefixIcon: Icons.alternate_email,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Password Field
                  buildLabel("Password"),
                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    style: GoogleFonts.plusJakartaSans(
                      color: textPrimary,
                      fontSize: 14,
                    ),
                    decoration: fieldDecoration(
                      hint: "Min. 8 characters",
                      prefixIcon: Icons.lock_outline,
                      suffix: GestureDetector(
                        onTap: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: iconColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Confirm Password Field
                  buildLabel("Confirm Password"),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: GoogleFonts.plusJakartaSans(
                      color: textPrimary,
                      fontSize: 14,
                    ),
                    decoration: fieldDecoration(
                      hint: "Re-enter password",
                      prefixIcon: Icons.lock_outline,
                      suffix: GestureDetector(
                        onTap: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                        child: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: iconColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Terms and Conditions
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        activeColor: primary,
                        checkColor: Colors.white,
                        side: BorderSide(
                          color: isDark
                              ? const Color(0xFF475569)
                              : Colors.grey[400]!,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (value) =>
                            setState(() => _agreeToTerms = value ?? false),
                      ),
                      Text(
                        "I agree to the ",
                        style: GoogleFonts.plusJakartaSans(
                          color: textPrimary,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "Terms of Service",
                        style: GoogleFonts.plusJakartaSans(
                          color: primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
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
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Create Account",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Login Navigation
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              LoginPage(toggleTheme: widget.toggleTheme),
                        ),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: textSecondary,
                          ),
                          children: const [
                            TextSpan(text: "Already have an account? "),
                            TextSpan(
                              text: "Login",
                              style: TextStyle(
                                color: primary,
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
