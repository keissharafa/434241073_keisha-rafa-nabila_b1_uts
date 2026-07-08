import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dashboard/dashboard_page.dart';
import '../helpdesk/helpdesk_dashboard_page.dart';
import '../auth/register_page.dart';
import '../admin/admin_dashboard_page.dart';

class LoginPage extends StatefulWidget {
  final Function(bool) toggleTheme;
  const LoginPage({super.key, required this.toggleTheme});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _keepLoggedIn = false;
  bool _obscurePassword = true;
  bool _isLoading = false; // Tambahan untuk efek loading di tombol

  // ---- Style guide constants ----
  static const _bgLight = Color(0xFFEDEFF7);
  static const _surfaceLight = Color(0xFFFFFFFF);
  static const _primary = Color(0xFF6C63FF);
  static const _textPrimaryLight = Color(0xFF14142B);
  static const _textSecondaryLight = Color(0xFF92929D);
  static const _fieldBgLight = Color(0xFFF1E9FF); // pastel "Pay" category
  static const _payIcon = Color(0xFF8B5CF6);
  static const _danger = Color(0xFFF45B69);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF14142B) : _bgLight;
    final cardColor = isDark ? const Color(0xFF1F1F3A) : _surfaceLight;
    final textPrimary = isDark ? const Color(0xFFF4F4FB) : _textPrimaryLight;
    final textSecondary = isDark
        ? const Color(0xFFA0A0B8)
        : _textSecondaryLight;
    final fieldBg = isDark ? const Color(0xFF2A2A55) : _fieldBgLight;
    final iconColor = isDark ? const Color(0xFFA0A0B8) : _payIcon;
    final hintColor = isDark ? const Color(0xFFA0A0B8) : _textSecondaryLight;
    final labelColor = isDark ? const Color(0xFFF4F4FB) : _textPrimaryLight;
    final footerColor = isDark
        ? const Color(0xFF6E6E8A)
        : const Color(0xFFB4B4C6);
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.3)
        : const Color(0xFF6C63FF).withOpacity(0.09);

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
                    blurRadius: 30,
                    offset: const Offset(0, 12),
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.confirmation_num_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Concierge",
                        style: GoogleFonts.plusJakartaSans(
                          color: _primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Text(
                    "Welcome back",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Enter your credentials to manage your tickets.",
                    style: GoogleFonts.plusJakartaSans(
                      color: textSecondary,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Email Input
                  Text(
                    "Email",
                    style: GoogleFonts.plusJakartaSans(
                      color: labelColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    style: GoogleFonts.plusJakartaSans(
                      color: textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: "e.g. alex@gmail.com",
                      hintStyle: GoogleFonts.plusJakartaSans(
                        color: hintColor,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: iconColor,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: fieldBg,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: _primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Password",
                        style: GoogleFonts.plusJakartaSans(
                          color: labelColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          "FORGOT PASSWORD?",
                          style: GoogleFonts.plusJakartaSans(
                            color: _primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    style: GoogleFonts.plusJakartaSans(
                      color: textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        color: iconColor,
                        size: 20,
                      ),
                      suffixIcon: GestureDetector(
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
                      filled: true,
                      fillColor: fieldBg,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: _primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Checkbox
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _keepLoggedIn,
                          activeColor: _primary,
                          checkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          side: BorderSide(
                            color: isDark
                                ? const Color(0xFF4A4A70)
                                : const Color(0xFFD8D2F0),
                            width: 1.5,
                          ),
                          onChanged: (value) =>
                              setState(() => _keepLoggedIn = value ?? false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Keep me logged in",
                        style: GoogleFonts.plusJakartaSans(
                          color: labelColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 🔵 LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _isLoading
                          ? null
                          : () async {
                              final email = emailController.text.trim();
                              final password = passwordController.text.trim();

                              if (email.isEmpty || password.isEmpty) {
                                _showError(
                                  "Email dan password tidak boleh kosong",
                                );
                                return;
                              }

                              setState(() => _isLoading = true);

                              try {
                                // Mengecek data user ke Supabase
                                final response = await Supabase.instance.client
                                    .from('users')
                                    .select()
                                    .eq('email', email)
                                    .eq('password', password)
                                    .maybeSingle();

                                if (response == null) {
                                  _showError("Email atau password salah");
                                } else {
                                  // Cek apakah user aktif
                                  if (response['is_active'] == false) {
                                    _showError("Akun ini sedang dinonaktifkan");
                                    return;
                                  }

                                  // Simpan sesi ke SharedPreferences
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString(
                                    'user_id',
                                    response['id'].toString(),
                                  );
                                  await prefs.setString(
                                    'user_email',
                                    response['email'],
                                  );
                                  await prefs.setString(
                                    'user_name',
                                    response['full_name'] ?? 'Unknown',
                                  );
                                  await prefs.setString(
                                    'user_role',
                                    response['role'],
                                  );

                                  // Hanya helpdesk yang punya division
                                  if (response['division'] != null) {
                                    await prefs.setString(
                                      'user_division',
                                      response['division'],
                                    );
                                  } else {
                                    await prefs.remove('user_division');
                                  }

                                  final role = response['role'];

                                  if (!mounted) return;
                                  // Routing berdasarkan role asli dari database
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        if (role == "admin") {
                                          return AdminDashboardPage(
                                            toggleTheme: widget.toggleTheme,
                                          );
                                        } else if (role == "helpdesk") {
                                          return HelpdeskDashboardPage(
                                            toggleTheme: widget.toggleTheme,
                                          );
                                        } else {
                                          return DashboardPage(
                                            role: role,
                                            toggleTheme: widget.toggleTheme,
                                          );
                                        }
                                      },
                                    ),
                                  );
                                }
                              } catch (e) {
                                _showError("Gagal terhubung ke database: $e");
                              } finally {
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                }
                              }
                            },
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
                              "Login",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.plusJakartaSans(
                          color: textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RegisterPage(toggleTheme: widget.toggleTheme),
                            ),
                          );
                        },
                        child: Text(
                          "Register",
                          style: GoogleFonts.plusJakartaSans(
                            color: _primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: Text(
                      "Privacy Policy    Terms of Service    Help Center",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: footerColor,
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

  // Fungsi helper untuk nampilin error biar rapi
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: _danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
