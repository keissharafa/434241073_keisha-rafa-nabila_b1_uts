import 'package:flutter/material.dart';
import '../dashboard/dashboard_page.dart';
import '../ticket/ticket_list_page.dart';
import '../profile/profile_page.dart';

class NotificationPage extends StatelessWidget {
  final Function(bool)? toggleTheme;

  const NotificationPage({
    super.key,
    this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor     = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final cardColor   = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final navBg       = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                    size: 20,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 🔹 TODAY
            _sectionTitle("TODAY"),
            const SizedBox(height: 10),

            _notifCard(
              cardColor: cardColor,
              iconWidget: _iconBox(
                icon: Icons.people_outline,
                iconColor: const Color(0xFF2563EB),
                bgColor: isDark ? const Color(0xFF1D3461) : const Color(0xFFEFF6FF),
              ),
              titleWidget: _richTitle(
                context: context,
                textPrimary: textPrimary,
                prefix: "Your ticket ",
                ticketId: "#TK-8842",
                suffix: " is now ",
                highlight: "In Progress",
                highlightColor: const Color(0xFFBC4800),
              ),
              time: "2 hours ago",
              status: "IN PROGRESS",
              statusColor: const Color(0xFFBC4800),
              statusBg: const Color(0xFFFFF0E6),
            ),

            _notifCard(
              cardColor: cardColor,
              iconWidget: _iconBox(
                icon: Icons.chat_bubble_outline,
                iconColor: const Color(0xFF94A3B8),
                bgColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              ),
              titleWidget: _richTitle(
                context: context,
                textPrimary: textPrimary,
                prefix: "Admin replied to your ticket ",
                ticketId: "#TK-8791",
                suffix: "",
                highlight: "",
                highlightColor: Colors.transparent,
              ),
              time: "5 hours ago",
              status: "WAITING",
              statusColor: const Color(0xFFEF4444),
              statusBg: const Color(0xFFFEE2E2),
            ),

            const SizedBox(height: 20),

            // 🔹 YESTERDAY
            _sectionTitle("YESTERDAY"),
            const SizedBox(height: 10),

            _notifCard(
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
                prefix: "Your ticket ",
                ticketId: "#TK-8650",
                suffix: " has been ",
                highlight: "resolved",
                highlightColor: const Color(0xFF16A34A),
              ),
              time: "Yesterday at 4:12 PM",
              status: "RESOLVED",
              statusColor: const Color(0xFF16A34A),
              statusBg: const Color(0xFFF0FDF4),
            ),

            _notifCard(
              cardColor: cardColor,
              iconWidget: _iconBox(
                icon: Icons.article_outlined,
                iconColor: const Color(0xFF94A3B8),
                bgColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              ),
              titleWidget: _richTitle(
                context: context,
                textPrimary: textPrimary,
                prefix: "New ticket ",
                ticketId: "#TK-8791",
                suffix: " created: \"Login issues...\"",
                highlight: "",
                highlightColor: Colors.transparent,
              ),
              time: "Yesterday at 11:30 AM",
              status: "WAITING",
              statusColor: const Color(0xFF475569),
              statusBg: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            ),

            const SizedBox(height: 24),

            // 🔥 FEATURED ALERT
            _sectionTitle("FEATURED ALERT"),
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.bolt, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            const Text(
                              "URGENT UPDATE",
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 0.7), // ✅ fixed
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Server Maintenance\nScheduled",
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
                          "Tomorrow, 02:00 AM UTC",
                          style: TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.7), // ✅ fixed
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.12), // ✅ fixed
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.dns_outlined,
                      color: Colors.white70,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 📊 STATS ROW
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    cardColor: cardColor,
                    textPrimary: textPrimary,
                    value: "12",
                    label: "ACTIVE TICKETS",
                    icon: Icons.article_outlined,
                    iconColor: const Color(0xFF2563EB),
                    iconBg: isDark ? const Color(0xFF1D3461) : const Color(0xFFEFF6FF),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _statCard(
                    cardColor: cardColor,
                    textPrimary: textPrimary,
                    value: "1.2h",
                    label: "AVG RESPONSE",
                    icon: Icons.timer_outlined,
                    iconColor: const Color(0xFFBC4800),
                    iconBg: isDark
                        ? const Color.fromRGBO(67, 20, 7, 0.5)
                        : const Color(0xFFFFF0E6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // 🔻 BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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
        onTap: (index) {
          if (index == 2) return;
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => DashboardPage(
                  role: "user",
                  toggleTheme: toggleTheme,
                ),
              ),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => TicketListPage(toggleTheme: toggleTheme),
              ),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ProfilePage(
                  toggleTheme: toggleTheme ?? (value) {},
                ),
              ),
            );
          }
        },
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

  Widget _notifCard({
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
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _richTitle({
    required BuildContext context,
    required Color textPrimary,
    required String prefix,
    required String ticketId,
    required String suffix,
    required String highlight,
    required Color highlightColor,
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
          if (highlight.isNotEmpty)
            TextSpan(
              text: highlight,
              style: TextStyle(
                color: highlightColor,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

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