import 'package:flutter/material.dart';
import 'admin_dashboard_page.dart';
import 'admin_ticket_page.dart';
import 'admin_notification_page.dart';

class _AdminDashboardStub extends StatelessWidget {
  final Function(bool) toggleTheme;
  const _AdminDashboardStub({required this.toggleTheme});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Admin Dashboard')),
        body: const Center(child: Text('Admin Dashboard')),
      );
}

class _AdminTicketStub extends StatelessWidget {
  final Function(bool) toggleTheme;
  const _AdminTicketStub({required this.toggleTheme});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Tickets')),
        body: const Center(child: Text('Tickets Page')),
      );
}

class _AdminNotificationStub extends StatelessWidget {
  final Function(bool) toggleTheme;
  const _AdminNotificationStub({required this.toggleTheme});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Alerts')),
        body: const Center(child: Text('Alerts Page')),
      );
}

// ─── Main page ────────────────────────────────────────────────────────────────

class AdminProfilePage extends StatefulWidget {
  final Function(bool) toggleTheme;

  const AdminProfilePage({Key? key, required this.toggleTheme})
      : super(key: key);

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  // ── Bottom-nav ──────────────────────────────────────────────────────────────
  void _onNavTap(int index) {
  if (index == 3) return;
  switch (index) {
    case 0:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminDashboardPage(toggleTheme: widget.toggleTheme),  
        ),
      );
      break;
    case 1:
      Navigator.pushReplacement(  
        context,
        MaterialPageRoute(
          builder: (_) => AdminTicketPage(toggleTheme: widget.toggleTheme),
        ),
      );
      break;
    case 2:
      Navigator.pushReplacement(  
        context,
        MaterialPageRoute(
          builder: (_) => AdminNotificationPage(toggleTheme: widget.toggleTheme),
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

    final sheetBg = isDarkSheet ? const Color(0xFF1E293B) : Colors.white;
    final labelColor =
        isDarkSheet ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final fieldBg =
        isDarkSheet ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final hintColor =
        isDarkSheet ? const Color(0xFF64748B) : Colors.grey[400]!;
    final iconColor =
        isDarkSheet ? const Color(0xFF64748B) : Colors.grey[400]!;
    final subtitleColor =
        isDarkSheet ? const Color(0xFF94A3B8) : Colors.grey[500]!;

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
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
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
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: labelColor,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter your current and new password below.',
                  style: TextStyle(fontSize: 13, color: subtitleColor),
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
                    onPressed: isLoading
                        ? null
                        : () async {
                            setSheet(() => isLoading = true);
                            await Future.delayed(
                                const Duration(seconds: 1));
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
                        : const Text(
                            'Reset Password',
                            style: TextStyle(
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
    final dialogBg =
        isDarkDialog ? const Color(0xFF1E293B) : Colors.white;
    final titleColor =
        isDarkDialog ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final bodyColor =
        isDarkDialog ? const Color(0xFF94A3B8) : Colors.grey[500]!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF16A34A),
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Password Reset Successful',
                textAlign: TextAlign.center,
                style: TextStyle(
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
                style: TextStyle(
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
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
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
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500, color: color),
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
  }) =>
      TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(fontSize: 14, color: textColor),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: hintColor, fontSize: 14),
          prefixIcon:
              Icon(Icons.lock_outline, color: iconColor, size: 20),
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: iconColor,
              size: 20,
            ),
          ),
          filled: true,
          fillColor: fieldBg,
          contentPadding: const EdgeInsets.symmetric(
              vertical: 16, horizontal: 16),
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
                color: Color(0xFF2563EB), width: 1.5),
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
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style:
                          TextStyle(fontSize: 12, color: subtitleColor),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: chevronColor, size: 20),
            ],
          ),
        ),
      );

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary =
        isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : Colors.grey[500]!;
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final dividerColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final navBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    const shadowColor = Color.fromRGBO(0, 0, 0, 0.04);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.headset_mic_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'HelpDesk',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
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
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF475569),
                      size: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── User card ────────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                        color: shadowColor,
                        blurRadius: 8,
                        offset: Offset(0, 2)),
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
                            borderRadius: BorderRadius.circular(18),
                            color: const Color(0xFF2563EB),
                          ),
                          clipBehavior: Clip.antiAlias,
                          // Use an actual avatar image or keep the icon fallback
                          child: const Icon(Icons.person,
                              color: Colors.white, size: 40),
                        ),
                        Positioned(
                          bottom: 3,
                          right: 3,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: cardColor, width: 2.5),
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
                                'Admin User',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1D3461)
                                      : const Color(0xFFEFF6FF),
                                  borderRadius:
                                      BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'ADMIN',
                                  style: TextStyle(
                                    color: Color(0xFF2563EB),
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
                            'admin@company.com',
                            style: TextStyle(
                                color: textSecondary, fontSize: 13),
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
                'ADMIN TOOLS',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
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
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                        color: shadowColor,
                        blurRadius: 8,
                        offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.manage_accounts_outlined,
                      iconBg: isDark
                          ? const Color(0xFF1D3461)
                          : const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                      title: 'User Management',
                      subtitle: 'Manage users and roles',
                      titleColor: textPrimary,
                      subtitleColor: textSecondary,
                      chevronColor: isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1),
                      onTap: () {},
                    ),
                    Divider(
                        height: 1,
                        thickness: 1,
                        color: dividerColor,
                        indent: 16,
                        endIndent: 16),
                    _buildMenuItem(
                      icon: Icons.bar_chart_rounded,
                      iconBg: isDark
                          ? const Color(0xFF1D3461)
                          : const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                      title: 'Reports',
                      subtitle: 'View ticket statistics',
                      titleColor: textPrimary,
                      subtitleColor: textSecondary,
                      chevronColor: isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1),
                      onTap: () {},
                    ),
                    Divider(
                        height: 1,
                        thickness: 1,
                        color: dividerColor,
                        indent: 16,
                        endIndent: 16),
                    _buildMenuItem(
                      icon: Icons.confirmation_num_outlined,
                      iconBg: isDark
                          ? const Color(0xFF1D3461)
                          : const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                      title: 'Assigned Tickets',
                      subtitle: 'View your assigned tickets',
                      titleColor: textPrimary,
                      subtitleColor: textSecondary,
                      chevronColor: isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── SETTINGS label ───────────────────────────────────────────────
              Text(
                'SETTINGS',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
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
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                        color: shadowColor,
                        blurRadius: 8,
                        offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    // Dark Mode toggle
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.dark_mode_outlined,
                            color: Color(0xFF2563EB),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          'Enable dark theme',
                          style: TextStyle(
                              color: textSecondary, fontSize: 12),
                        ),
                        value: isDark,
                        activeColor: const Color(0xFF2563EB),
                        onChanged: (val) => widget.toggleTheme(val),
                      ),
                    ),
                    Divider(
                        height: 1,
                        thickness: 1,
                        color: dividerColor,
                        indent: 16,
                        endIndent: 16),
                    // Reset Password
                    _buildMenuItem(
                      icon: Icons.lock_reset_outlined,
                      iconBg: isDark
                          ? const Color(0xFF1D3461)
                          : const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                      title: 'Reset Password',
                      subtitle: 'Manage your account security',
                      titleColor: textPrimary,
                      subtitleColor: textSecondary,
                      chevronColor: isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1),
                      onTap: () => _showResetPasswordSheet(isDark),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── GENERAL label ────────────────────────────────────────────────
              Text(
                'GENERAL',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
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
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                        color: shadowColor,
                        blurRadius: 8,
                        offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.info_outline_rounded,
                      iconBg: isDark
                          ? const Color(0xFF1D3461)
                          : const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                      title: 'About App',
                      subtitle: 'Version 2.4.1 (Stable)',
                      titleColor: textPrimary,
                      subtitleColor: textSecondary,
                      chevronColor: isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1),
                      onTap: () {},
                    ),
                    Divider(
                        height: 1,
                        thickness: 1,
                        color: dividerColor,
                        indent: 16,
                        endIndent: 16),
                    _buildMenuItem(
                      icon: Icons.logout_rounded,
                      iconBg: isDark
                          ? const Color(0xFF450A0A).withOpacity(0.5)
                          : const Color(0xFFFEE2E2),
                      iconColor: const Color(0xFFEF4444),
                      title: 'Logout',
                      subtitle: 'Sign out of your account',
                      titleColor: const Color(0xFFEF4444),
                      subtitleColor: isDark
                          ? const Color(0xFF94A3B8)
                          : Colors.grey[400]!,
                      chevronColor: const Color(0xFFEF4444),
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

      // ── Bottom nav ──────────────────────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        onTap: _onNavTap,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          letterSpacing: 0.5,
        ),
        backgroundColor: navBg,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_num_outlined),
            activeIcon: Icon(Icons.confirmation_num_rounded),
            label: 'TICKETS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_rounded),
            activeIcon: Icon(Icons.notifications_rounded),
            label: 'NOTIFICATIONS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'PROFILE',
          ),
        ],
      ),
    );
  }
}