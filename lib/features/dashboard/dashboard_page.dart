import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

    // 🎨 Color tokens (Style Guide Concierge)
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
    final iconBoxBg = isDark
        ? const Color(0xFF2E2A52)
        : const Color(0xFFF0F1F6);
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
                          color: primary,
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
                          builder: (_) =>
                              NotificationPage(toggleTheme: toggleTheme),
                        ),
                      );
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: shadowColor,
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                        border: isDark ? Border.all(color: borderColor) : null,
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: textSecondary,
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
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "How can we help you today?",
                style: GoogleFonts.plusJakartaSans(
                  color: textSecondary,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 24),

              // 📊 STAT CARDS
              _buildStatCard(
                context: context,
                title: "TOTAL TICKETS",
                value: "42",
                isHighlighted: false,
                icon: Icons.article_outlined,
                iconColor: primary,
                iconBg: isDark
                    ? const Color(0xFF2A2456)
                    : const Color(0xFFEDEBFF),
                cardColor: cardColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                shadowColor: shadowColor,
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
                textSecondary: textSecondary,
                shadowColor: shadowColor,
              ),
              const SizedBox(height: 14),
              _buildStatCard(
                context: context,
                title: "RESOLVED",
                value: "30",
                isHighlighted: false,
                icon: Icons.check_circle_outline,
                iconColor: textSecondary,
                iconBg: iconBoxBg,
                cardColor: cardColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                shadowColor: shadowColor,
              ),

              const SizedBox(height: 24),

              // 🔥 CTA CARD — selalu dark navy, tidak berubah antar tema
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF14142B),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Need immediate\nassistance?",
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Our digital concierges are ready to assist with any technical issues or service requests.",
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFA0A0B8),
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
                          backgroundColor: primary,
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
                              builder: (_) =>
                                  TicketListPage(toggleTheme: toggleTheme),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: Text(
                          "Create New Ticket",
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

              const SizedBox(height: 28),

              // 📌 RECENT ACTIVITY
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Activity",
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    "View All",
                    style: GoogleFonts.plusJakartaSans(
                      color: primary,
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
                textSecondary: textSecondary,
                shadowColor: shadowColor,
                title: "Cloud Server Connectivity Issue",
                description: "The primary production server",
                ticketId: "#TK-8842",
                timeAgo: "2H AGO",
                status: "CRITICAL",
                statusColor: const Color(0xFFF45B69),
                statusBg: const Color(0xFFFDE8EA),
                iconBg: const Color(0xFFFDE8EA),
                iconColor: const Color(0xFFF45B69),
                icon: Icons.priority_high,
              ),
              _buildTicketItem(
                cardColor: cardColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                shadowColor: shadowColor,
                title: "Software License Renewal",
                description: "Requesting extension for the...",
                ticketId: "#TK-8839",
                timeAgo: "YESTERDAY",
                status: "PENDING",
                statusColor: const Color(0xFFFF9F43),
                statusBg: const Color(0xFFFFF1E0),
                iconBg: const Color(0xFFFFF1E0),
                iconColor: const Color(0xFFFF9F43),
                icon: Icons.hourglass_empty,
              ),
              _buildTicketItem(
                cardColor: cardColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                shadowColor: shadowColor,
                title: "Email Configuration Setup",
                description: "Setup completed for the new...",
                ticketId: "#TK-8830",
                timeAgo: "3 DAYS AGO",
                status: "RESOLVED",
                statusColor: const Color(0xFF21D07B),
                statusBg: const Color(0xFFE1F9EE),
                iconBg: primary,
                iconColor: Colors.white,
                icon: Icons.check,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),

      // 🔻 BOTTOM NAV
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
            currentIndex: 0,
            type: BottomNavigationBarType.fixed,
            backgroundColor: navBg,
            elevation: 0,
            selectedItemColor: primary,
            unselectedItemColor: textSecondary,
            showSelectedLabels: false,
            showUnselectedLabels: false,
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
                    builder: (_) =>
                        ProfilePage(toggleTheme: toggleTheme ?? (value) {}),
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
        ),
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
    required Color textSecondary,
    required Color shadowColor,
  }) {
    const primary = Color(0xFF6C63FF);
    final bg = isHighlighted ? primary : cardColor;
    final titleColor = isHighlighted
        ? Colors.white.withOpacity(0.8)
        : textSecondary;
    final valueColor = isHighlighted ? Colors.white : textPrimary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isHighlighted ? primary.withOpacity(0.25) : shadowColor,
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
                style: GoogleFonts.plusJakartaSans(
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
            style: GoogleFonts.plusJakartaSans(
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
    required Color textSecondary,
    required Color shadowColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
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
                        style: GoogleFonts.plusJakartaSans(
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
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: GoogleFonts.plusJakartaSans(
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
                  style: GoogleFonts.plusJakartaSans(
                    color: textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      ticketId,
                      style: GoogleFonts.plusJakartaSans(
                        color: textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      " • ",
                      style: GoogleFonts.plusJakartaSans(
                        color: textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: GoogleFonts.plusJakartaSans(
                        color: textSecondary,
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
