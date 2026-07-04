import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark
        ? const Color(0xFFF1F5F9)
        : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : Colors.grey[500]!;
    final fieldBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final iconColor = isDark ? const Color(0xFF64748B) : Colors.grey[500]!;
    final hintColor = isDark ? const Color(0xFF64748B) : Colors.grey[400]!;
    final labelColor = isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF0F172A);
    final footerColor = isDark ? const Color(0xFF64748B) : Colors.grey[400]!;
    final shadowColor = const Color.fromRGBO(0, 0, 0, 0.06);

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
                    "Welcome back",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Enter your credentials to manage your tickets.",
                    style: TextStyle(color: textSecondary, fontSize: 14),
                  ),

                  const SizedBox(height: 28),

                  // Email Input
                  Text(
                    "Email",
                    style: TextStyle(
                      color: labelColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    style: TextStyle(color: textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "e.g. alex@gmail.com",
                      hintStyle: TextStyle(color: hintColor, fontSize: 14),
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
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
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
                        style: TextStyle(
                          color: labelColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          "FORGOT PASSWORD?",
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(color: textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock_outline,
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
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _keepLoggedIn,
                        activeColor: const Color(0xFF2563EB),
                        checkColor: Colors.white,
                        side: BorderSide(
                          color: isDark
                              ? const Color(0xFF475569)
                              : Colors.grey[400]!,
                          width: 1.5,
                        ),
                        onChanged: (value) =>
                            setState(() => _keepLoggedIn = value ?? false),
                      ),
                      Text(
                        "Keep me logged in",
                        style: TextStyle(color: labelColor, fontSize: 14),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 🔵 LOGIN BUTTON
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
                          : const Text(
                              "Login",
                              style: TextStyle(
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
                        style: TextStyle(color: textSecondary, fontSize: 14),
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
                        child: const Text(
                          "Register",
                          style: TextStyle(
                            color: Color(0xFF2563EB),
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
                      style: TextStyle(fontSize: 11, color: footerColor),
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
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
