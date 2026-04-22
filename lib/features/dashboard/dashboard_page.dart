import 'package:flutter/material.dart';
import '../profile/profile_page.dart';
import '../ticket/ticket_list_page.dart';
import '../notification/notification_page.dart';

class DashboardPage extends StatelessWidget {
  final String role;
  final Function(bool)? toggleTheme;

  const DashboardPage({super.key, required this.role, this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 🎨 Color tokens
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final navBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final iconBoxBg = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

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

                  // 🔔 NOTIF BUTTON
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotificationPage(toggleTheme: toggleTheme),
                        ),
                      );
                    },
                    child: Container(
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
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 👋 GREETING
              Text(
                "Good morning, Alex",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "How can we help you today?",
                style: TextStyle(color: textSecondary, fontSize: 14),
              ),

              const SizedBox(height: 24),

              // 📊 STAT CARDS
              _buildStatCard(
                context: context,
                title: "TOTAL TICKETS",
                value: "42",
                isHighlighted: false,
                icon: Icons.article_outlined,
                iconColor: const Color(0xFF2563EB),
                iconBg: isDark ? const Color(0xFF1D3461) : const Color(0xFFEFF6FF),
                cardColor: cardColor,
                textPrimary: textPrimary,
              ),
              const SizedBox(height: 14),
              _buildStatCard(
                context: context,
                title: "ACTIVE TICKETS",
                value: "12",
                isHighlighted: true,
                icon: Icons.more_horiz,
                iconColor: Colors.white,
                iconBg: Colors.white.withOpacity(0.2),
                cardColor: cardColor,
                textPrimary: textPrimary,
              ),
              const SizedBox(height: 14),
              _buildStatCard(
                context: context,
                title: "RESOLVED",
                value: "30",
                isHighlighted: false,
                icon: Icons.check_circle_outline,
                iconColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                iconBg: iconBoxBg,
                cardColor: cardColor,
                textPrimary: textPrimary,
              ),

              const SizedBox(height: 24),

              // 🔥 CTA CARD — selalu dark, tidak perlu berubah
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Need immediate\nassistance?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Our digital concierges are ready to assist with any technical issues or service requests.",
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TicketListPage(toggleTheme: toggleTheme),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: const Text(
                          "Create New Ticket",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 📌 RECENT ACTIVITY
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Activity",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Text(
                    "View All",
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _buildTicketItem(
                cardColor: cardColor,
                textPrimary: textPrimary,
                title: "Cloud Server Connectivity Issue",
                description: "The primary production server",
                ticketId: "#TK-8842",
                timeAgo: "2H AGO",
                status: "CRITICAL",
                statusColor: const Color(0xFFEF4444),
                statusBg: const Color(0xFFFEE2E2),
                iconBg: const Color(0xFFFEE2E2),
                iconColor: const Color(0xFFEF4444),
                icon: Icons.priority_high,
              ),
              _buildTicketItem(
                cardColor: cardColor,
                textPrimary: textPrimary,
                title: "Software License Renewal",
                description: "Requesting extension for the...",
                ticketId: "#TK-8839",
                timeAgo: "YESTERDAY",
                status: "PENDING",
                statusColor: const Color(0xFFF97316),
                statusBg: const Color(0xFFFFF7ED),
                iconBg: const Color(0xFFBC4800).withOpacity(0.15),
                iconColor: const Color(0xFFBC4800),
                icon: Icons.hourglass_empty,
              ),
              _buildTicketItem(
                cardColor: cardColor,
                textPrimary: textPrimary,
                title: "Email Configuration Setup",
                description: "Setup completed for the new...",
                ticketId: "#TK-8830",
                timeAgo: "3 DAYS AGO",
                status: "RESOLVED",
                statusColor: const Color(0xFF2563EB),
                statusBg: const Color(0xFFEFF6FF),
                iconBg: const Color(0xFF2563EB),
                iconColor: Colors.white,
                icon: Icons.check,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),

      // 🔻 BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
          if (index == 0) return;
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => TicketListPage(toggleTheme: toggleTheme),
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => NotificationPage(toggleTheme: toggleTheme),
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
            icon: Icon(Icons.notifications_none),
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

  // 📊 STAT CARD
  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required bool isHighlighted,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required Color cardColor,
    required Color textPrimary,
  }) {
    final bg = isHighlighted ? const Color(0xFF2563EB) : cardColor;
    final titleColor = isHighlighted
        ? Colors.white.withOpacity(0.8)
        : const Color(0xFF94A3B8);
    final valueColor = isHighlighted ? Colors.white : textPrimary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isHighlighted
                ? const Color(0xFF2563EB).withOpacity(0.25)
                : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 17),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: valueColor,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  // 🎫 TICKET ITEM
  Widget _buildTicketItem({
    required String title,
    required String description,
    required String ticketId,
    required String timeAgo,
    required String status,
    required Color statusColor,
    required Color statusBg,
    required Color iconBg,
    required Color iconColor,
    required IconData icon,
    required Color cardColor,
    required Color textPrimary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
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
                  description,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      ticketId,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      " • ",
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                    ),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}