import 'package:flutter/material.dart';
import '../admin/admin_dashboard_page.dart';
import '../admin/admin_ticket_page.dart';
import 'admin_profile_page.dart';

class AdminNotificationPage extends StatefulWidget {
  final Function(bool) toggleTheme;

  const AdminNotificationPage({super.key, required this.toggleTheme});

  @override
  State<AdminNotificationPage> createState() => _AdminNotificationPageState();
}

class _AdminNotificationPageState extends State<AdminNotificationPage> {
  int _selectedIndex = 2; // index 2 = NOTIFICATIONS di bottom nav admin

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
          builder: (_) => AdminTicketPage(toggleTheme: widget.toggleTheme),
        ),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminProfilePage( 
            toggleTheme: widget.toggleTheme,
          ),
        ),
      );
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor     = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final cardColor   = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final navBg       = isDark ? const Color(0xFF1E293B) : Colors.white;
    final labelColor  = isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [

            // ─── HEADER ───────────────────────────────────────────────
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
                Stack(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: const Icon(
                        Icons.notifications,
                        color: Color(0xFF2563EB),
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
              ],
            ),

            const SizedBox(height: 20),

            // ─── PAGE TITLE ───────────────────────────────────────────
            Text(
              "Notification Center",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Admin activity log & system alerts.",
              style: TextStyle(
                fontSize: 13,
                color: labelColor,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            // ─── TODAY ────────────────────────────────────────────────
            _sectionTitle("TODAY"),
            const SizedBox(height: 10),

            _notifCard(
              isDark: isDark,
              cardColor: cardColor,
              iconWidget: _iconBox(
                icon: Icons.warning_amber_rounded,
                iconColor: const Color(0xFFEF4444),
                bgColor: isDark ? const Color(0xFF3B0A0A) : const Color(0xFFFEE2E2),
              ),
              titleWidget: _richTitle(
                context: context,
                textPrimary: textPrimary,
                prefix: "New URGENT ticket ",
                ticketId: "#TK-8821",
                suffix: " submitted by ",
                extra: "Sarah Jenkins",
                extraColor: textPrimary,
              ),
              time: "12 mins ago",
              status: "URGENT",
              statusColor: const Color(0xFFEF4444),
              statusBg: isDark ? const Color(0xFF3B0A0A) : const Color(0xFFFEE2E2),
            ),

            _notifCard(
              isDark: isDark,
              cardColor: cardColor,
              iconWidget: _iconBox(
                icon: Icons.group_outlined,
                iconColor: const Color(0xFF2563EB),
                bgColor: isDark ? const Color(0xFF1D3461) : const Color(0xFFEFF6FF),
              ),
              titleWidget: _richTitle(
                context: context,
                textPrimary: textPrimary,
                prefix: "Ticket ",
                ticketId: "#TK-8819",
                suffix: " assigned to ",
                extra: "Network Team",
                extraColor: const Color(0xFF2563EB),
              ),
              time: "45 mins ago",
              status: "ASSIGNED",
              statusColor: const Color(0xFF2563EB),
              statusBg: isDark ? const Color(0xFF1D3461) : const Color(0xFFEFF6FF),
            ),

            _notifCard(
              isDark: isDark,
              cardColor: cardColor,
              iconWidget: _iconBox(
                icon: Icons.check_circle_outline,
                iconColor: const Color(0xFF16A34A),
                bgColor: isDark
                    ? const Color.fromRGBO(20, 83, 45, 0.4)
                    : const Color(0xFFF0FDF4),
              ),
              titleWidget: _richTitle(
                context: context,
                textPrimary: textPrimary,
                prefix: "Admin ",
                ticketId: "Kevin R.",
                suffix: " resolved ticket ",
                extra: "#TK-8815",
                extraColor: const Color(0xFF2563EB),
              ),
              time: "2 hours ago",
              status: "RESOLVED",
              statusColor: const Color(0xFF16A34A),
              statusBg: isDark
                  ? const Color.fromRGBO(20, 83, 45, 0.3)
                  : const Color(0xFFF0FDF4),
            ),

            const SizedBox(height: 20),

            // ─── YESTERDAY ────────────────────────────────────────────
            _sectionTitle("YESTERDAY"),
            const SizedBox(height: 10),

            _notifCard(
              isDark: isDark,
              cardColor: cardColor,
              iconWidget: _iconBox(
                icon: Icons.timer_off_outlined,
                iconColor: const Color(0xFFF97316),
                bgColor: isDark
                    ? const Color.fromRGBO(67, 20, 7, 0.5)
                    : const Color(0xFFFFF7ED),
              ),
              titleWidget: _richTitle(
                context: context,
                textPrimary: textPrimary,
                prefix: "SLA breach warning on ticket ",
                ticketId: "#TK-8810",
                suffix: " — response overdue",
                extra: "",
                extraColor: Colors.transparent,
              ),
              time: "Yesterday at 5:30 PM",
              status: "SLA BREACH",
              statusColor: const Color(0xFFF97316),
              statusBg: isDark
                  ? const Color.fromRGBO(67, 20, 7, 0.4)
                  : const Color(0xFFFFF7ED),
            ),

            _notifCard(
              isDark: isDark,
              cardColor: cardColor,
              iconWidget: _iconBox(
                icon: Icons.inbox_outlined,
                iconColor: const Color(0xFF94A3B8),
                bgColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              ),
              titleWidget: _richTitle(
                context: context,
                textPrimary: textPrimary,
                prefix: "3 new tickets submitted via ",
                ticketId: "Customer Portal",
                suffix: " in the last hour",
                extra: "",
                extraColor: Colors.transparent,
              ),
              time: "Yesterday at 2:14 PM",
              status: "NEW BATCH",
              statusColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
              statusBg: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            ),

            _notifCard(
              isDark: isDark,
              cardColor: cardColor,
              iconWidget: _iconBox(
                icon: Icons.trending_up_rounded,
                iconColor: const Color(0xFFEF4444),
                bgColor: isDark ? const Color(0xFF3B0A0A) : const Color(0xFFFEE2E2),
              ),
              titleWidget: _richTitle(
                context: context,
                textPrimary: textPrimary,
                prefix: "Ticket ",
                ticketId: "#TK-8791",
                suffix: " escalated to ",
                extra: "DevOps Team",
                extraColor: const Color(0xFFEF4444),
              ),
              time: "Yesterday at 11:00 AM",
              status: "ESCALATED",
              statusColor: const Color(0xFFEF4444),
              statusBg: isDark ? const Color(0xFF3B0A0A) : const Color(0xFFFEE2E2),
            ),

            const SizedBox(height: 24),

            // ─── SYSTEM ALERT ─────────────────────────────────────────
            _sectionTitle("SYSTEM ALERT"),
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF334155), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.bolt, color: Color(0xFFF97316), size: 14),
                            SizedBox(width: 4),
                            Text(
                              "MAINTENANCE NOTICE",
                              style: TextStyle(
                                color: Color(0xFFF97316),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Ticket System\nMaintenance Window",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Tomorrow, 02:00–04:00 AM UTC\nTicket intake will be paused.",
                          style: TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.6),
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(249, 115, 22, 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.dns_outlined,
                      color: Color(0xFFF97316),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── ADMIN STATS ROW ──────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    cardColor: cardColor,
                    textPrimary: textPrimary,
                    value: "5",
                    label: "UNREAD ALERTS",
                    icon: Icons.notifications_active_outlined,
                    iconColor: const Color(0xFFEF4444),
                    iconBg: isDark ? const Color(0xFF3B0A0A) : const Color(0xFFFEE2E2),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _statCard(
                    cardColor: cardColor,
                    textPrimary: textPrimary,
                    value: "3",
                    label: "SLA BREACHES",
                    icon: Icons.timer_off_outlined,
                    iconColor: const Color(0xFFF97316),
                    iconBg: isDark
                        ? const Color.fromRGBO(67, 20, 7, 0.5)
                        : const Color(0xFFFFF7ED),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // ─── BOTTOM NAV ───────────────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: "HOME",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_num_outlined),
            label: "TICKETS",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "NOTIFICATIONS",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "PROFILE",
          ),
        ],
      ),
    );
  }

  // ─── SECTION TITLE ────────────────────────────────────────────────────
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: Color(0xFF94A3B8),
        fontSize: 11,
        letterSpacing: 1.2,
      ),
    );
  }

  // ─── NOTIF CARD ───────────────────────────────────────────────────────
  Widget _notifCard({
    required bool isDark,
    required Widget iconWidget,
    required Widget titleWidget,
    required String time,
    required String status,
    required Color statusColor,
    required Color statusBg,
    required Color cardColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          iconWidget,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleWidget,
                const SizedBox(height: 5),
                Text(
                  time,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── ICON BOX ─────────────────────────────────────────────────────────
  Widget _iconBox({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }

  // ─── RICH TITLE ───────────────────────────────────────────────────────
  Widget _richTitle({
    required BuildContext context,
    required Color textPrimary,
    required String prefix,
    required String ticketId,
    required String suffix,
    required String extra,
    required Color extraColor,
  }) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 13,
          color: textPrimary,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        children: [
          TextSpan(text: prefix),
          TextSpan(
            text: ticketId,
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: suffix),
          if (extra.isNotEmpty)
            TextSpan(
              text: extra,
              style: TextStyle(color: extraColor, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  // ─── STAT CARD ────────────────────────────────────────────────────────
  Widget _statCard({
    required String value,
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required Color cardColor,
    required Color textPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}