import 'package:flutter/material.dart';
import '../auth/login_page.dart';
import 'admin_profile_page.dart';
import 'admin_ticket_page.dart';
import 'admin_notification_page.dart';

class AdminDashboardPage extends StatelessWidget {
  final Function(bool) toggleTheme;

  const AdminDashboardPage({
    super.key,
    required this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Color tokens ──────────────────────────────────────────────────
    final bgColor       = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final cardColor     = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary   = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : Colors.grey[500]!;
    final borderColor   = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final labelColor    = const Color(0xFF94A3B8);
    final actionCardBg  = isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF);
    final actionTitleColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final navBg         = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [

            // ─── HEADER ─────────────────────────────────────────────
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
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminNotificationPage(
                          toggleTheme: toggleTheme,
                        ),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
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
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ─── TITLE ───────────────────────────────────────────────
            Text(
              "Admin Dashboard",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "System overview and critical operations.",
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),

            const SizedBox(height: 24),

            // ─── STAT CARD — TOTAL TICKETS ───────────────────────────
            _statCard(
              isDark: isDark,
              cardColor: cardColor,
              icon: Icons.confirmation_num_outlined,
              iconColor: const Color(0xFF2563EB),
              iconBg: isDark ? const Color(0xFF1D3461) : const Color(0xFFEFF6FF),
              label: "TOTAL TICKETS",
              value: "1,284",
              valueColor: const Color(0xFF2563EB),
              badge: null,
              badgeColor: null,
              badgeBg: null,
              subtext: "↗ 12% increase this month",
              subtextColor: const Color(0xFF2563EB),
            ),

            const SizedBox(height: 14),

            // ─── STAT CARD — OPEN TICKETS ────────────────────────────
            _statCard(
              isDark: isDark,
              cardColor: cardColor,
              icon: Icons.star_border_outlined,
              iconColor: const Color(0xFFEF4444),
              iconBg: isDark ? const Color(0xFF3B0A0A) : const Color(0xFFFEE2E2),
              label: "OPEN TICKETS",
              value: "42",
              valueColor: const Color(0xFFEF4444),
              badge: "ACTION REQUIRED",
              badgeColor: const Color(0xFFEF4444),
              badgeBg: isDark ? const Color(0xFF3B0A0A) : const Color(0xFFFEE2E2),
              subtext: null,
              subtextColor: null,
            ),

            const SizedBox(height: 14),

            // ─── STAT CARD — PENDING ─────────────────────────────────
            _statCard(
              isDark: isDark,
              cardColor: cardColor,
              icon: Icons.access_time_outlined,
              iconColor: const Color(0xFFF97316),
              iconBg: isDark
                  ? const Color.fromRGBO(67, 20, 7, 0.5)
                  : const Color(0xFFFFF7ED),
              label: "PENDING",
              value: "156",
              valueColor: const Color(0xFFF97316),
              badge: "AWAITING USER",
              badgeColor: const Color(0xFFF97316),
              badgeBg: isDark
                  ? const Color.fromRGBO(67, 20, 7, 0.4)
                  : const Color(0xFFFFF7ED),
              subtext: null,
              subtextColor: null,
            ),

            const SizedBox(height: 20),

            // ─── CURRENT FOCUS CARD (gradient, always dark) ──────────
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "CURRENT FOCUS",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Assigned to\nMe",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "08",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.25),
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2563EB),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "View\nQueue",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                height: 1.3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                                color: Colors.white.withOpacity(0.4)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "New\nTask",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                height: 1.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ─── TOTAL RESOLVED CARD ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TOTAL RESOLVED",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: labelColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "1,086",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF16A34A),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              "94% Resolution Rate",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF16A34A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _bar(24, const Color(0xFFBFDBFE)),
                      const SizedBox(width: 4),
                      _bar(40, const Color(0xFF93C5FD)),
                      const SizedBox(width: 4),
                      _bar(32, const Color(0xFF60A5FA)),
                      const SizedBox(width: 4),
                      _bar(52, const Color(0xFF3B82F6)),
                      const SizedBox(width: 4),
                      _bar(44, const Color(0xFF2563EB)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── QUICK ACTIONS ───────────────────────────────────────
            Text(
              "Quick Actions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: textPrimary,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 14),

            _actionCard(
              isDark: isDark,
              cardBg: actionCardBg,
              titleColor: actionTitleColor,
              icon: Icons.confirmation_num_outlined,
              iconColor: const Color(0xFF2563EB),
              iconBg: isDark ? const Color(0xFF1D3461) : const Color(0xFFEFF6FF),
              title: "All Tickets",
              subtitle: "Review and manage the entire helpdesk queue.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AdminTicketPage(toggleTheme: toggleTheme),
                  ),
                );
              },
            ),
            _actionCard(
              isDark: isDark,
              cardBg: actionCardBg,
              titleColor: actionTitleColor,
              icon: Icons.people_outline,
              iconColor: const Color(0xFF475569),
              iconBg: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              title: "User Management",
              subtitle: "Handle roles, permissions, and account security.",
              onTap: () {},
            ),
            _actionCard(
              isDark: isDark,
              cardBg: actionCardBg,
              titleColor: actionTitleColor,
              icon: Icons.bar_chart_outlined,
              iconColor: const Color(0xFF2563EB),
              iconBg: isDark ? const Color(0xFF1D3461) : const Color(0xFFEFF6FF),
              title: "Reports",
              subtitle: "Generate data exports and performance insights.",
              onTap: () {},
            ),

            const SizedBox(height: 20),

            // ─── HIGH PRIORITY ESCALATION CARD ───────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF3B0A0A)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "HIGH PRIORITY ESCALATION",
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "System Latency Issues in Region-East",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                      height: 1.3,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Three major enterprise clients reported significant response delays. Requires immediate investigation from the infrastructure team.",
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        width: 72,
                        height: 32,
                        child: Stack(
                          children: [
                            _miniAvatar(0, const Color(0xFFF59E0B), "SJ"),
                            _miniAvatar(22, const Color(0xFF6366F1), "MR"),
                            _miniAvatar(44, const Color(0xFF10B981), "+"),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "Take Ownership",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),

      // ─── BOTTOM NAV ─────────────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedLabelStyle: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        unselectedLabelStyle:
            const TextStyle(fontSize: 10, letterSpacing: 0.5),
        backgroundColor: navBg,
        elevation: 8,
        onTap: (index) {
          if (index == 0) return;
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AdminTicketPage(toggleTheme: toggleTheme),
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AdminNotificationPage(toggleTheme: toggleTheme),
              ),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AdminProfilePage(toggleTheme: toggleTheme),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded), label: "HOME"),
          BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_num_outlined), label: "TICKETS"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              label: "NOTIFICATIONS"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "PROFILE"),
        ],
      ),
    );
  }

  // ─── STAT CARD ────────────────────────────────────────────────────────
  Widget _statCard({
    required bool isDark,
    required Color cardColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    required Color valueColor,
    required String? badge,
    required Color? badgeColor,
    required Color? badgeBg,
    required String? subtext,
    required Color? subtextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: valueColor,
              letterSpacing: -1,
            ),
          ),
          if (subtext != null) ...[
            const SizedBox(height: 6),
            Text(subtext,
                style: TextStyle(
                    fontSize: 12,
                    color: subtextColor,
                    fontWeight: FontWeight.w500)),
          ],
          if (badge != null) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── ACTION CARD ──────────────────────────────────────────────────────
  Widget _actionCard({
    required bool isDark,
    required Color cardBg,
    required Color titleColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: isDark
              ? Border.all(color: const Color(0xFF334155))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF64748B), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  // ─── BAR (chart) ──────────────────────────────────────────────────────
  Widget _bar(double height, Color color) {
    return Container(
      width: 10,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // ─── MINI AVATAR ──────────────────────────────────────────────────────
  Widget _miniAvatar(double left, Color color, String text) {
    return Positioned(
      left: left,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF1E293B), width: 2),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}