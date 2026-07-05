import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // ── STYLE GUIDE SEMANTIC COLORS ──
  static const _primary = Color(0xFF6C63FF);
  static const _danger = Color(0xFFF45B69);
  static const _success = Color(0xFF21D07B);

  void _showResetPasswordSheet(bool isDarkSheet) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isLoading = false;

    final sheetBg = isDarkSheet ? const Color(0xFF1F1B3A) : Colors.white;
    final labelColor = isDarkSheet
        ? const Color(0xFFF1F1FB)
        : const Color(0xFF14142B);
    final fieldBg = isDarkSheet
        ? const Color(0xFF241F45)
        : const Color(0xFFF1E9FF);
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
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
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
                      "Reset Password",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: labelColor,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Enter your current and new password below.",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _sheetLabel("Current Password", labelColor),
                    const SizedBox(height: 8),
                    _sheetTextField(
                      controller: currentPasswordController,
                      hint: "Enter current password",
                      obscure: obscureCurrent,
                      onToggle: () =>
                          setSheetState(() => obscureCurrent = !obscureCurrent),
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
                      onToggle: () =>
                          setSheetState(() => obscureNew = !obscureNew),
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
                      onToggle: () =>
                          setSheetState(() => obscureConfirm = !obscureConfirm),
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
                          backgroundColor: _primary,
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
                                await Future.delayed(
                                  const Duration(seconds: 1),
                                );
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
                            : Text(
                                "Reset Password",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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
      builder: (context) {
        return Dialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFF7E4),
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
                  "Password Reset Successful",
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
                  "Your password has been updated successfully. Please use your new password the next time you log in.",
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
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Got it",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.white,
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
  }

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
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode
        ? const Color(0xFF14142B)
        : const Color(0xFFEDEFF7);
    final cardColor = isDarkMode ? const Color(0xFF1F1B3A) : Colors.white;
    final textPrimary = isDarkMode
        ? const Color(0xFFF1F1FB)
        : const Color(0xFF14142B);
    final textSecondary = isDarkMode
        ? const Color(0xFFA0A0B8)
        : const Color(0xFF92929D);
    final dividerColor = isDarkMode
        ? const Color(0xFF2E2A52)
        : const Color(0xFFF0F1F6);
    final navBg = isDarkMode ? const Color(0xFF1F1B3A) : Colors.white;
    final shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.25)
        : _primary.withOpacity(0.06);

    return Scaffold(
      backgroundColor: bgColor,
      extendBody: true, // PENTING untuk floating navbar
      body: SafeArea(
        bottom: false,
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
                          color: const Color(0xFF14142B),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.confirmation_num,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Concierge",
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
                    width: 40,
                    height: 40,
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
                      size: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 👤 USER CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: _primary,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: _success,
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
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "user@gmail.com",
                      style: GoogleFonts.plusJakartaSans(
                        color: textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF2A2456)
                            : const Color(0xFFEDEBFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.circle, color: _primary, size: 8),
                          const SizedBox(width: 6),
                          Text(
                            "USER",
                            style: GoogleFonts.plusJakartaSans(
                              color: _primary,
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

              // ─── GENERAL SETTINGS ───────────────────────
              Text(
                "GENERAL SETTINGS",
                style: GoogleFonts.plusJakartaSans(
                  color: _primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
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
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF2E2A52)
                                : const Color(0xFFEDEBFF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.dark_mode_outlined,
                            color: _primary,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          "Dark Mode",
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          "Enable dark theme",
                          style: GoogleFonts.plusJakartaSans(
                            color: textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        value: isDarkMode,
                        activeColor: _primary,
                        onChanged: (value) {
                          setState(() => isDark = value);
                          widget.toggleTheme(value);
                        },
                      ),
                    ),

                    Divider(
                      height: 1,
                      thickness: 1,
                      color: dividerColor,
                      indent: 16,
                      endIndent: 16,
                    ),

                    _buildMenuItem(
                      icon: Icons.key_outlined,
                      iconBg: isDarkMode
                          ? const Color(0xFF2A2456)
                          : const Color(0xFFEDEBFF),
                      iconColor: _primary,
                      title: "Reset Password",
                      subtitle: "Manage your account security",
                      titleColor: textPrimary,
                      subtitleColor: textSecondary,
                      chevronColor: isDarkMode
                          ? const Color(0xFF3E3866)
                          : const Color(0xFFD8D9E8),
                      onTap: () => _showResetPasswordSheet(isDarkMode),
                    ),

                    Divider(
                      height: 1,
                      thickness: 1,
                      color: dividerColor,
                      indent: 16,
                      endIndent: 16,
                    ),

                    _buildMenuItem(
                      icon: Icons.info_outline,
                      iconBg: isDarkMode
                          ? const Color(0xFF2A2456)
                          : const Color(0xFFEDEBFF),
                      iconColor: _primary,
                      title: "About App",
                      subtitle: "Version 2.4.1 (Stable)",
                      titleColor: textPrimary,
                      subtitleColor: textSecondary,
                      chevronColor: isDarkMode
                          ? const Color(0xFF3E3866)
                          : const Color(0xFFD8D9E8),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── ACCOUNT ACTIONS ────────────────────────
              Text(
                "ACCOUNT ACTIONS",
                style: GoogleFonts.plusJakartaSans(
                  color: _danger,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildMenuItem(
                  icon: Icons.logout_rounded,
                  iconBg: isDarkMode
                      ? const Color(0xFF3A1E24)
                      : const Color(0xFFFDE8EA),
                  iconColor: _danger,
                  title: "Logout",
                  subtitle: "Sign out of your account",
                  titleColor: _danger,
                  subtitleColor: isDarkMode
                      ? const Color(0xFFA0A0B8)
                      : const Color(0xFFB8B9CC),
                  chevronColor: _danger,
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            LoginPage(toggleTheme: widget.toggleTheme),
                      ),
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
                    colors: [Color(0xFF6E8CFB), Color(0xFF4C3FD2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
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
                        Text(
                          "Need help?",
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Our dedicated team is available 24/7 to assist with your ticketing needs.",
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _primary,
                            backgroundColor: Colors.white,
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            "Contact Support",
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100), // Spasi agar aman dari navbar
            ],
          ),
        ),
      ),

      // NAVBAR FLOATING
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20), // Jarak melayang
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
            onTap: (index) {
              if (index == 3) return; // Udah di profile
              if (index == 0)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DashboardPage(
                      role: "user",
                      toggleTheme: widget.toggleTheme,
                    ),
                  ),
                );
              if (index == 1)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TicketListPage(toggleTheme: widget.toggleTheme),
                  ),
                );
              if (index == 2)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        NotificationPage(toggleTheme: widget.toggleTheme),
                  ),
                );
            },
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
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
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
}
