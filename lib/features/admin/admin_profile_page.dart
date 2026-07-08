import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_notification_page.dart';
import 'admin_user_management_page.dart';

class AdminProfilePage extends StatefulWidget {
  final Function(bool) toggleTheme;

  const AdminProfilePage({super.key, required this.toggleTheme});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  int _selectedIndex = 3; // Index untuk Profile
  String _userName = "Loading...";
  String _userEmail = "admin@system.com";

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? "Admin";
      _userEmail = prefs.getString('user_email') ?? "admin@gmail.com";
    });
  }

  // LOGIKA LOGOUT TOTAL
  Future<void> _handleLogout() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F1B3A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Confirm Logout",
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFF1F1FB) : const Color(0xFF14142B),
          ),
        ),
        content: Text(
          "Are you sure you want to log out of your account?",
          style: GoogleFonts.plusJakartaSans(
            color: isDark ? const Color(0xFFA0A0B8) : const Color(0xFF92929D),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: GoogleFonts.plusJakartaSans(
                color: isDark
                    ? const Color(0xFFA0A0B8)
                    : const Color(0xFF92929D),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF45B69),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text("Logout", style: GoogleFonts.plusJakartaSans()),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(toggleTheme: widget.toggleTheme),
      ),
      (route) => false,
    );
  }

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminDashboardPage(toggleTheme: widget.toggleTheme),
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminDashboardPage(toggleTheme: widget.toggleTheme),
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AdminNotificationPage(toggleTheme: widget.toggleTheme),
        ),
      );
    }
    setState(() => _selectedIndex = index);
  }

  void _showResetPasswordSheet(bool isDarkSheet) {
    final currentPasswordCtrl = TextEditingController();
    final newPasswordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isLoading = false;

    final sheetBg = isDarkSheet ? const Color(0xFF1F1B3A) : Colors.white;
    final labelColor = isDarkSheet
        ? const Color(0xFFF1F1FB)
        : const Color(0xFF14142B);
    final fieldBg = isDarkSheet
        ? const Color(0xFF14142B)
        : const Color(0xFFF0F1F6);
    final hintColor = isDarkSheet
        ? const Color(0xFFA0A0B8)
        : const Color(0xFF92929D);
    final iconColor = isDarkSheet
        ? const Color(0xFFA0A0B8)
        : const Color(0xFF92929D);
    final subtitleColor = isDarkSheet
        ? const Color(0xFFA0A0B8)
        : const Color(0xFF92929D);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDarkSheet
                          ? const Color(0xFF2E2A52)
                          : const Color(0xFFF0F1F6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Reset Password',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: labelColor,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter your current and new password below.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: subtitleColor,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Current Password',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: labelColor,
                  ),
                ),
                const SizedBox(height: 8),
                _sheetTextField(
                  controller: currentPasswordCtrl,
                  hint: 'Enter current password',
                  obscure: obscureCurrent,
                  onToggle: () =>
                      setSheet(() => obscureCurrent = !obscureCurrent),
                  fieldBg: fieldBg,
                  hintColor: hintColor,
                  iconColor: iconColor,
                  textColor: labelColor,
                ),
                const SizedBox(height: 16),

                Text(
                  'New Password',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: labelColor,
                  ),
                ),
                const SizedBox(height: 8),
                _sheetTextField(
                  controller: newPasswordCtrl,
                  hint: 'Min. 8 characters',
                  obscure: obscureNew,
                  onToggle: () => setSheet(() => obscureNew = !obscureNew),
                  fieldBg: fieldBg,
                  hintColor: hintColor,
                  iconColor: iconColor,
                  textColor: labelColor,
                ),
                const SizedBox(height: 16),

                Text(
                  'Confirm New Password',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: labelColor,
                  ),
                ),
                const SizedBox(height: 8),
                _sheetTextField(
                  controller: confirmPasswordCtrl,
                  hint: 'Re-enter new password',
                  obscure: obscureConfirm,
                  onToggle: () =>
                      setSheet(() => obscureConfirm = !obscureConfirm),
                  fieldBg: fieldBg,
                  hintColor: hintColor,
                  iconColor: iconColor,
                  textColor: labelColor,
                ),

                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            setSheet(() => isLoading = true);
                            await Future.delayed(
                              const Duration(seconds: 1),
                            ); // Simulasi API
                            Navigator.pop(ctx);
                            _showSuccessDialog(isDarkSheet);
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Reset Password',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(bool isDarkDialog) {
    final dialogBg = isDarkDialog ? const Color(0xFF1F1B3A) : Colors.white;
    final titleColor = isDarkDialog
        ? const Color(0xFFF1F1FB)
        : const Color(0xFF14142B);
    final bodyColor = isDarkDialog
        ? const Color(0xFFA0A0B8)
        : const Color(0xFF92929D);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F9EE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF21D07B),
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Password Reset Successful',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your password has been updated successfully. Please use your new password the next time you log in.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: bodyColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Got it',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
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

  Widget _sheetTextField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required Color fieldBg,
    required Color hintColor,
    required Color iconColor,
    required Color textColor,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.plusJakartaSans(fontSize: 14, color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(color: hintColor, fontSize: 14),
        prefixIcon: Icon(Icons.lock_outline, color: iconColor, size: 20),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: iconColor,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: fieldBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color titleColor,
    required Color subtitleColor,
    required Color chevronColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: chevronColor, size: 20),
          ],
        ),
      ),
    );
  }

  // ── MESH GRADIENT BACKGROUND (visual only, no logic) ──
  Widget _buildMeshBlob(Color color, double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), color.withOpacity(0)],
        ),
      ),
    );
  }

  Widget _buildMeshGradientBackground(bool isDark) {
    final baseColor = isDark
        ? const Color(0xFF14142B)
        : const Color(0xFFEDEFF7);
    final blobPrimary = const Color(0xFF6C63FF); // primary
    final blobLavenderLight = isDark
        ? const Color(0xFF8B7FFF)
        : const Color(0xFFB8AEFF); // lavender muda
    final blobLavenderDeep = isDark
        ? const Color(0xFF4C3FE0)
        : const Color(0xFF9D8DFF); // lavender lebih pekat

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: Container(
        color: baseColor,
        child: Stack(
          children: [
            Positioned(
              top: -70,
              left: -50,
              child: _buildMeshBlob(blobPrimary, 260, isDark ? 0.38 : 0.30),
            ),
            Positioned(
              top: -30,
              right: -70,
              child: _buildMeshBlob(
                blobLavenderLight,
                220,
                isDark ? 0.30 : 0.26,
              ),
            ),
            Positioned(
              bottom: -90,
              left: 30,
              child: _buildMeshBlob(
                blobLavenderDeep,
                240,
                isDark ? 0.26 : 0.22,
              ),
            ),
            // Blur biar blob-nya nyatu jadi "mesh"
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(color: Colors.transparent),
            ),
          ],
        ),
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
    final borderColor = isDark
        ? const Color(0xFF2E2A52)
        : const Color(0xFFF0F1F6);
    final navBg = isDark ? const Color(0xFF1F1B3A) : Colors.white;
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.25)
        : const Color(0xFF6C63FF).withOpacity(0.06);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER + USER CARD DENGAN MESH GRADIENT DI BELAKANGNYA ──
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -16,
                    left: -20,
                    right: -20,
                    height: 250,
                    child: _buildMeshGradientBackground(isDark),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER DENGAN LOGO SPLASH SCREEN
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // --- LOGO CONCIERGE ---
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF2563EB,
                                  ), // Biru Splash Screen
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.confirmation_num, // Ikon Tiket
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Concierge',
                                style: GoogleFonts.plusJakartaSans(
                                  color: primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Profile",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // USER CARD
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(22),
                          border: isDark
                              ? Border.all(color: borderColor)
                              : null,
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: shadowColor,
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Row(
                          children: [
                            // --- AVATAR INISIAL NAMA ---
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: primary,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Center(
                                child: Text(
                                  _userName.isNotEmpty
                                      ? _userName.substring(0, 1).toUpperCase()
                                      : 'A',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _userName,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          color: textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE1F9EE),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          'ADMIN',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: const Color(0xFF21D07B),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _userEmail,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Text(
                'ADMIN TOOLS',
                style: GoogleFonts.plusJakartaSans(
                  color: textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),

              // TOOLS CARD
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: isDark ? Border.all(color: borderColor) : null,
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.manage_accounts_outlined,
                      iconBg: isDark
                          ? const Color(0xFF2A2456)
                          : const Color(0xFFEDEBFF),
                      iconColor: primary,
                      title: 'User Management',
                      subtitle: 'Manage users and roles',
                      titleColor: textPrimary,
                      subtitleColor: textSecondary,
                      chevronColor: textSecondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AdminUserManagementPage(),
                          ),
                        );
                      },
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: borderColor,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _buildMenuItem(
                      icon: Icons.bar_chart_rounded,
                      iconBg: isDark
                          ? const Color(0xFF2A2456)
                          : const Color(0xFFEDEBFF),
                      iconColor: primary,
                      title: 'System Reports',
                      subtitle: 'View ticket statistics',
                      titleColor: textPrimary,
                      subtitleColor: textSecondary,
                      chevronColor: textSecondary,
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'SETTINGS',
                style: GoogleFonts.plusJakartaSans(
                  color: textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),

              // SETTINGS CARD
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: isDark ? Border.all(color: borderColor) : null,
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2A2456)
                                : const Color(0xFFEDEBFF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.dark_mode_outlined,
                            color: primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          'Dark Mode',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          'Enable dark theme',
                          style: GoogleFonts.plusJakartaSans(
                            color: textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        value: isDark,
                        activeColor: primary,
                        onChanged: (val) => widget.toggleTheme(val),
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: borderColor,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _buildMenuItem(
                      icon: Icons.lock_reset_outlined,
                      iconBg: isDark
                          ? const Color(0xFF2A2456)
                          : const Color(0xFFEDEBFF),
                      iconColor: primary,
                      title: 'Reset Password',
                      subtitle: 'Manage your account security',
                      titleColor: textPrimary,
                      subtitleColor: textSecondary,
                      chevronColor: textSecondary,
                      onTap: () => _showResetPasswordSheet(isDark),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // LOGOUT BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFDE8EA),
                    foregroundColor: const Color(0xFFF45B69),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(
                    "Log Out",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        decoration: BoxDecoration(
          color: navBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onNavTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: navBg,
            elevation: 0,
            selectedItemColor: primary,
            unselectedItemColor: textSecondary,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4, top: 4),
                  child: Icon(Icons.grid_view_rounded, size: 24),
                ),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4, top: 4),
                  child: Icon(Icons.confirmation_num_outlined, size: 24),
                ),
                label: "Ticket",
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4, top: 4),
                  child: Icon(Icons.notifications_none, size: 24),
                ),
                label: "Notif",
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4, top: 4),
                  child: Icon(Icons.person_outline, size: 24),
                ),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
