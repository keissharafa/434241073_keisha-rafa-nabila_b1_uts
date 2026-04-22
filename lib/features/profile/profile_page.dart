import 'package:flutter/material.dart';
import '../dashboard/dashboard_page.dart';
import '../auth/login_page.dart';
import '../ticket/ticket_list_page.dart';
import '../notification/notification_page.dart';

class ProfilePage extends StatefulWidget {
  final Function(bool) toggleTheme;

  const ProfilePage({required this.toggleTheme});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isDark = false;

  void _onNavTap(int index) {
    if (index == 3) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardPage(role: "user", toggleTheme: widget.toggleTheme)),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => TicketListPage(toggleTheme: widget.toggleTheme)),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => NotificationPage(toggleTheme: widget.toggleTheme)),
        );
        break;
    }
  }

  void _showResetPasswordSheet(bool isDarkSheet) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isLoading = false;

    final sheetBg    = isDarkSheet ? const Color(0xFF1E293B) : Colors.white;
    final labelColor = isDarkSheet ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final fieldBg    = isDarkSheet ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final hintColor  = isDarkSheet ? const Color(0xFF64748B) : Colors.grey[400]!;
    final iconColor  = isDarkSheet ? const Color(0xFF64748B) : Colors.grey[400]!;
    final subtitleColor = isDarkSheet ? const Color(0xFF94A3B8) : Colors.grey[500]!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
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
                          color: isDarkSheet ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Reset Password",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: labelColor,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Enter your current and new password below.",
                      style: TextStyle(fontSize: 13, color: subtitleColor),
                    ),
                    const SizedBox(height: 24),

                    _sheetLabel("Current Password", labelColor),
                    const SizedBox(height: 8),
                    _sheetTextField(
                      controller: currentPasswordController,
                      hint: "Enter current password",
                      obscure: obscureCurrent,
                      onToggle: () => setSheetState(() => obscureCurrent = !obscureCurrent),
                      fieldBg: fieldBg,
                      hintColor: hintColor,
                      iconColor: iconColor,
                      textColor: labelColor,
                    ),
                    const SizedBox(height: 16),

                    _sheetLabel("New Password", labelColor),
                    const SizedBox(height: 8),
                    _sheetTextField(
                      controller: newPasswordController,
                      hint: "Min. 8 characters",
                      obscure: obscureNew,
                      onToggle: () => setSheetState(() => obscureNew = !obscureNew),
                      fieldBg: fieldBg,
                      hintColor: hintColor,
                      iconColor: iconColor,
                      textColor: labelColor,
                    ),
                    const SizedBox(height: 16),

                    _sheetLabel("Confirm New Password", labelColor),
                    const SizedBox(height: 8),
                    _sheetTextField(
                      controller: confirmPasswordController,
                      hint: "Re-enter new password",
                      obscure: obscureConfirm,
                      onToggle: () => setSheetState(() => obscureConfirm = !obscureConfirm),
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
                                setSheetState(() => isLoading = true);
                                await Future.delayed(const Duration(seconds: 1));
                                Navigator.pop(context);
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
                                "Reset Password",
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
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog(bool isDarkDialog) {
    final dialogBg    = isDarkDialog ? const Color(0xFF1E293B) : Colors.white;
    final titleColor  = isDarkDialog ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final bodyColor   = isDarkDialog ? const Color(0xFF94A3B8) : Colors.grey[500]!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
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
                  "Password Reset Successful",
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
                  "Your password has been updated successfully. Please use your new password the next time you log in.",
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
                      "Got it",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sheetLabel(String text, Color color) => Text(
        text,
        style: TextStyle(
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
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(fontSize: 14, color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor, fontSize: 14),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode    = Theme.of(context).brightness == Brightness.dark;
    final bgColor       = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final cardColor     = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary   = isDarkMode ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textSecondary = isDarkMode ? const Color(0xFF94A3B8) : Colors.grey[500]!;
    final borderColor   = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final dividerColor  = isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final navBg         = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final shadowColor   = const Color.fromRGBO(0, 0, 0, 0.04);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🔝 HEADER
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
                          Icons.confirmation_num,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Concierge",
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
                      color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                      size: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 👤 USER CARD — centered avatar + name + email + badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar with green online dot
                    Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            color: const Color(0xFF2563EB),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: const Icon(Icons.person, color: Colors.white, size: 48),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              shape: BoxShape.circle,
                              border: Border.all(color: cardColor, width: 2.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "Alex Johnson",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "alex@email.com",
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF1D3461) : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.circle, color: Color(0xFF2563EB), size: 8),
                          SizedBox(width: 6),
                          Text(
                            "USER",
                            style: TextStyle(
                              color: Color(0xFF2563EB),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── GENERAL SETTINGS section label ───────────────────────
              const Text(
                "GENERAL SETTINGS",
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),

              // ⚙️ GENERAL SETTINGS CARD
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [

                    // 🌙 Dark Mode
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.dark_mode_outlined,
                            color: Color(0xFF2563EB),
                            size: 18,
                          ),
                        ),
                        title: Text(
                          "Dark Mode",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          "Enable dark theme",
                          style: TextStyle(color: textSecondary, fontSize: 12),
                        ),
                        value: isDarkMode,
                        activeColor: const Color(0xFF2563EB),
                        onChanged: (value) {
                          setState(() => isDark = value);
                          widget.toggleTheme(value);
                        },
                      ),
                    ),

                    Divider(height: 1, thickness: 1, color: dividerColor, indent: 16, endIndent: 16),

                    // 🔑 Reset Password
                    _buildMenuItem(
                      icon: Icons.key_outlined,
                      iconBg: isDarkMode ? const Color(0xFF1D3461) : const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                      title: "Reset Password",
                      subtitle: "Manage your account security",
                      titleColor: textPrimary,
                      subtitleColor: textSecondary,
                      chevronColor: isDarkMode ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                      onTap: () => _showResetPasswordSheet(isDarkMode),
                    ),

                    Divider(height: 1, thickness: 1, color: dividerColor, indent: 16, endIndent: 16),

                    // ℹ️ About App
                    _buildMenuItem(
                      icon: Icons.info_outline,
                      iconBg: isDarkMode ? const Color(0xFF1D3461) : const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                      title: "About App",
                      subtitle: "Version 2.4.1 (Stable)",
                      titleColor: textPrimary,
                      subtitleColor: textSecondary,
                      chevronColor: isDarkMode ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── ACCOUNT ACTIONS section label ────────────────────────
              const Text(
                "ACCOUNT ACTIONS",
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),

              // 🚪 LOGOUT CARD (standalone)
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: _buildMenuItem(
                  icon: Icons.logout_rounded,
                  iconBg: isDarkMode ? const Color(0xFF450A0A).withValues(alpha: 0.5) : const Color(0xFFFEE2E2),
                  iconColor: const Color(0xFFEF4444),
                  title: "Logout",
                  subtitle: "Sign out of your account",
                  titleColor: const Color(0xFFEF4444),
                  subtitleColor: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey[400]!,
                  chevronColor: const Color(0xFFEF4444),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => LoginPage(toggleTheme: widget.toggleTheme)),
                      (route) => false,
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // 💙 NEED HELP CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    // Decorative background icon
                    Positioned(
                      right: -10,
                      bottom: -10,
                      child: Opacity(
                        opacity: 0.15,
                        child: const Icon(
                          Icons.support_agent_rounded,
                          color: Colors.white,
                          size: 110,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Need help?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Our dedicated team is available 24/7 to assist with your ticketing needs.",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2563EB),
                            backgroundColor: Colors.white,
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "Contact Support",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // 🔻 BOTTOM NAV
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
            label: "HOME",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_num_outlined),
            label: "TICKETS",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: "ALERTS",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: "PROFILE",
          ),
        ],
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
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
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
}