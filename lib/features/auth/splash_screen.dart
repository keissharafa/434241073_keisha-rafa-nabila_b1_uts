import 'package:flutter/material.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  final Function(bool) toggleTheme;
  const SplashScreen({super.key, required this.toggleTheme});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(toggleTheme: widget.toggleTheme),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor    = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textColor  = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final subColor   = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.confirmation_num,
                color: Colors.white,
                size: 44,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Concierge",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2563EB),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "E-Ticketing Helpdesk",
              style: TextStyle(
                fontSize: 14,
                color: subColor,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
      ),
    );
  }
}