import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'helpdesk_dashboard_page.dart';
import 'helpdesk_ticket_page.dart';
import 'helpdesk_notification_page.dart';

class _HelpdeskDashboardStub extends StatelessWidget {
  final Function(bool) toggleTheme;
  const _HelpdeskDashboardStub({required this.toggleTheme});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Admin Dashboard')),
    body: const Center(child: Text('Admin Dashboard')),
  );
}

class _HelpdeskTicketStub extends StatelessWidget {
  final Function(bool) toggleTheme;
  const _HelpdeskTicketStub({required this.toggleTheme});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tickets')),
    body: const Center(child: Text('Tickets Page')),
  );
}

class _HelpdeskNotificationStub extends StatelessWidget {
  final Function(bool) toggleTheme;
  const _HelpdeskNotificationStub({required this.toggleTheme});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Alerts')),
    body: const Center(child: Text('Alerts Page')),
  );
}

// ─── Main page ────────────────────────────────────────────────────────────────

class HelpdeskProfilePage extends StatefulWidget {
  final Function(bool) toggleTheme;

  const HelpdeskProfilePage({Key? key, required this.toggleTheme})
    : super(key: key);

  @override
  State<HelpdeskProfilePage> createState() => _HelpdeskProfilePageState();
}

class _HelpdeskProfilePageState extends State<HelpdeskProfilePage> {
  // ---- Style guide constants ----
  static const _bgLight = Color(0xFFEDEFF7);
  static const _surfaceLight = Color(0xFFFFFFFF);
  static const _primary = Color(0xFF6C63FF);
  static const _textPrimaryLight = Color(0xFF14142B);
  static const _textSecondaryLight = Color(0xFF92929D);
  static const _fieldBgLight = Color(0xFFF1E9FF); // pastel "Pay" category
  static const _payIcon = Color(0xFF8B5CF6);
  static const _success = Color(0xFF21D07B);
  static const _successBg = Color(0xFFE3FAEC);
  static const _danger = Color(0xFFF45B69);
  static const _dangerBg = Color(0xFFFCE9EB);

  // ── Bottom-nav ──────────────────────────────────────────────────────────────
  void _onNavTap(int index) {
    if (index == 3) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                HelpdeskDashboardPage(toggleTheme: widget.toggleTheme),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HelpdeskTicketPage(toggleTheme: widget.toggleTheme),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                HelpdeskNotificationPage(toggleTheme: widget.toggleTheme),
          ),
        );
        break;
    }
  }

  // ── Reset-password bottom sheet ─────────────────────────────────────────────
  void _showResetPasswordSheet(bool isDarkSheet) {
    final currentPasswordCtrl = TextEditingController();
    final newPasswordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isLoading = false;

    final sheetBg = isDarkSheet ? const Color(0xFF1F1F3A) : _surfaceLight;
    final labelColor = isDarkSheet
        ? const Color(0xFFF4F4FB)
        : _textPrimaryLight;
    final fieldBg = isDarkSheet ? const Color(0xFF2A2A55) : _fieldBgLight;
    final hintColor = isDarkSheet
        ? const Color(0xFFA0A0B8)
        : _textSecondaryLight;
    final iconColor = isDarkSheet ? const Color(0xFFA0A0B8) : _payIcon;
    final subtitleColor = isDarkSheet
        ? const Color(0xFFA0A0B8)
        : _textSecondaryLight;

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
                // drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDarkSheet
                          ? Colors.white.withOpacity(0.12)
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
                    letterSpacing: -0.3,
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
                _sheetLabel('Current Password', labelColor),
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
                _sheetLabel('New Password', labelColor),
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
                _sheetLabel('Confirm New Password', labelColor),
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
                    onPressed: isLoading
                        ? null
                        : () async {
                            setSheet(() => isLoading = true);
                            await Future.delayed(const Duration(seconds: 1));
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

  // ── Success dialog ──────────────────────────────────────────────────────────
  void _showSuccessDialog(bool isDarkDialog) {
    final dialogBg = isDarkDialog ? const Color(0xFF1F1F3A) : _surfaceLight;
    final titleColor = isDarkDialog
        ? const Color(0xFFF4F4FB)
        : _textPrimaryLight;
    final bodyColor = isDarkDialog
        ? const Color(0xFFA0A0B8)
        : _textSecondaryLight;

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
                  color: _successBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: _success,
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
                'Your password has been updated successfully. '
                'Please use your new password the next time you log in.',
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
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Widget _sheetLabel(String text, Color color) => Text(
    text,
    style: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: color,
    ),
  );

  Widget _sheetTextField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required Color fieldBg,
    required Color hintColor,
    required Color iconColor,
    required Color textColor,
  }) => TextField(
    controller: controller,
    obscureText: obscure,
    style: GoogleFonts.plusJakartaSans(fontSize: 14, color: textColor),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(color: hintColor, fontSize: 14),
      prefixIcon: Icon(Icons.lock_outline_rounded, color: iconColor, size: 20),
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
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
    ),
  );

  // ── Menu item ────────────────────────────────────────────────────────────────
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
  }) => InkWell(
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
          Icon(Icons.chevron_right_rounded, color: chevronColor, size: 20),
        ],
      ),
    ),
  );

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF14142B) : _bgLight;
    final cardColor = isDark ? const Color(0xFF1F1F3A) : _surfaceLight;
    final navBg = isDark ? const Color(0xFF1F1F3A) : _surfaceLight;
    final textPrimary = isDark ? const Color(0xFFF4F4FB) : _textPrimaryLight;
    final textSecondary = isDark
        ? const Color(0xFFA0A0B8)
        : _textSecondaryLight;
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.06)
        : const Color(0xFFF0F1F6);
    final iconBoxBg = isDark ? const Color(0xFF2A2A55) : _fieldBgLight;
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.3)
        : const Color(0xFF6C63FF).withOpacity(0.07);

    return Scaffold(
      backgroundColor: bgColor,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header (minimal, no elevation) ────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: _primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.headset_mic_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'HelpDesk',
                        style: GoogleFonts.plusJakartaSans(
                          color: _primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: textSecondary,
                      size: 18,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── User card ────────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6E8CFB), Color(0xFF4C63D2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        Positioned(
                          bottom: 3,
                          right: 3,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _success,
                              shape: BoxShape.circle,
                              border: Border.all(color: cardColor, width: 2.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Helpdesk',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: iconBoxBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'ADMIN',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: _payIcon,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'helpdesk@gmail.com',
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

              const SizedBox(height: 24),

              // ── ADMIN TOOLS label ────────────────────────────────────────────
              Text(
                'HELPDESK TOOLS',
                style: GoogleFonts.plusJakartaSans(
                  color: textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),

              // ── Admin tools card ─────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.bar_chart_rounded,
                      iconBg: iconBoxBg,
                      iconColor: _payIcon,
                      title: 'Reports',
                      subtitle: 'View ticket statistics',
                      titleColor: textPrimary,
                      subtitleColor: textSecondary,
                      chevronColor: textSecondary,
                      onTap: () {},
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: dividerColor,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _buildMenuItem(
                      icon: Icons.confirmation_num_outlined,
                      iconBg: iconBoxBg,
                      iconColor: _payIcon,
                      title: 'Assigned Tickets',
                      subtitle: 'View your assigned tickets',
                      titleColor: textPrimary,
                      subtitleColor: textSecondary,
                      chevronColor: textSecondary,
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── SETTINGS label ───────────────────────────────────────────────
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

              // ── Settings card ────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Dark Mode toggle
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
                            color: iconBoxBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.dark_mode_outlined,
                            color: _payIcon,
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
                        activeColor: _primary,
                        onChanged: (val) => widget.toggleTheme(val),
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: dividerColor,
                      indent: 16,
                      endIndent: 16,
                    ),
                    // Reset Password
                    _buildMenuItem(
                      icon: Icons.lock_reset_outlined,
                      iconBg: iconBoxBg,
                      iconColor: _payIcon,
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

              // ── GENERAL label ────────────────────────────────────────────────
              Text(
                'GENERAL',
                style: GoogleFonts.plusJakartaSans(
                  color: textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),

              // ── General card (About + Logout) ────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.info_outline_rounded,
                      iconBg: iconBoxBg,
                      iconColor: _payIcon,
                      title: 'About App',
                      subtitle: 'Version 2.4.1 (Stable)',
                      titleColor: textPrimary,
                      subtitleColor: textSecondary,
                      chevronColor: textSecondary,
                      onTap: () {},
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: dividerColor,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _buildMenuItem(
                      icon: Icons.logout_rounded,
                      iconBg: _dangerBg,
                      iconColor: _danger,
                      title: 'Logout',
                      subtitle: 'Sign out of your account',
                      titleColor: _danger,
                      subtitleColor: textSecondary,
                      chevronColor: _danger,
                      onTap: () {
                        // Navigate to login and clear stack
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // ── Floating Bottom Nav (konsisten sama halaman lain) ──────────────────
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
            currentIndex: 3,
            onTap: _onNavTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: navBg,
            elevation: 0,
            selectedItemColor: _primary,
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
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4, top: 4),
                  child: Icon(Icons.confirmation_num_outlined, size: 24),
                ),
                label: 'Ticket',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4, top: 4),
                  child: Icon(Icons.notifications_none, size: 24),
                ),
                label: 'Notif',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4, top: 4),
                  child: Icon(Icons.person_outline, size: 24),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
