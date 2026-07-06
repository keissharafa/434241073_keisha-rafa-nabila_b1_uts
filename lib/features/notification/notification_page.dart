import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../dashboard/dashboard_page.dart';
import '../ticket/ticket_list_page.dart';
import '../ticket/ticket_detail_page.dart'; // Import halaman detail user
import '../profile/profile_page.dart';
import '../../services/ticket_service.dart';

class NotificationPage extends StatefulWidget {
  final Function(bool)? toggleTheme;
  final String roleTarget;

  const NotificationPage({
    super.key,
    this.toggleTheme,
    this.roleTarget = "user",
  });

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final TicketService _ticketService = TicketService();

  List<Map<String, dynamic>> _notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final data = await _ticketService.getNotifications(
        roleTarget: widget.roleTarget,
      );

      if (!mounted) return;

      setState(() {
        _notifications = data.map((notif) {
          return {
            "id": notif["id"],
            "ticket_id": notif["ticket_id"], // Tarik ID tiket
            "title": notif["title"] ?? "Notification",
            "message": notif["message"] ?? "-",
            "status": notif["status"] ?? "INFO",
            "type": notif["notification_type"] ?? "info",
            "time": _timeAgo(notif["created_at"]),
            "isRead": notif["is_read"] ?? false,
          };
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load notifications: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _timeAgo(dynamic rawDate) {
    if (rawDate == null) return "Just now";

    try {
      final createdAt = DateTime.parse(rawDate.toString()).toLocal();
      final now = DateTime.now();
      final diff = now.difference(createdAt);

      if (diff.inMinutes < 1) return "Just now";
      if (diff.inMinutes < 60) return "${diff.inMinutes} mins ago";
      if (diff.inHours < 24) return "${diff.inHours} hours ago";
      return "${diff.inDays} days ago";
    } catch (_) {
      return "Just now";
    }
  }

  IconData _notifIcon(String type, String status) {
    if (type == "ticket_update") return Icons.people_outline;
    if (status == "RESOLVED") return Icons.check_circle_outline;
    if (status == "PENDING") return Icons.hourglass_bottom_rounded;
    if (status == "IN PROGRESS") return Icons.access_time;
    if (status == "OPEN") return Icons.article_outlined;
    return Icons.notifications_none;
  }

  Color _statusColor(String status) {
    switch (status) {
      case "OPEN":
        return const Color(0xFFEF4444);
      case "PENDING":
        return const Color(0xFFF97316);
      case "IN PROGRESS":
        return const Color(0xFFBC4800);
      case "RESOLVED":
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF475569);
    }
  }

  Color _statusBg(String status, bool isDark) {
    switch (status) {
      case "OPEN":
        return isDark ? const Color(0xFF3B0A0A) : const Color(0xFFFEE2E2);
      case "PENDING":
        return isDark
            ? const Color.fromRGBO(67, 20, 7, 0.5)
            : const Color(0xFFFFF7ED);
      case "IN PROGRESS":
        return isDark
            ? const Color.fromRGBO(67, 20, 7, 0.5)
            : const Color(0xFFFFF0E6);
      case "RESOLVED":
        return isDark
            ? const Color.fromRGBO(20, 83, 45, 0.4)
            : const Color(0xFFF0FDF4);
      default:
        return isDark ? const Color(0xFF2E2A52) : const Color(0xFFF0F1F6);
    }
  }

  int get _activeNotifCount {
    return _notifications.where((n) => n["status"] != "RESOLVED").length;
  }

  int get _unreadCount {
    return _notifications.where((n) => n["isRead"] == false).length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      extendBody: true, // Wajib untuk floating navbar
      body: SafeArea(
        bottom: false,
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: primary))
            : RefreshIndicator(
                onRefresh: _loadNotifications,
                color: primary,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    100,
                  ), // Spasi bawah
                  children: [
                    // HEADER
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
                            const SizedBox(width: 12),
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
                        Stack(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: isDark
                                    ? Border.all(color: borderColor)
                                    : null,
                                boxShadow: isDark
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: shadowColor,
                                          blurRadius: 12,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                              ),
                              child: Icon(
                                Icons.notifications_outlined,
                                color: textSecondary,
                                size: 20,
                              ),
                            ),
                            if (_unreadCount > 0)
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

                    const SizedBox(height: 24),

                    Text(
                      "Notifications",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Track latest updates from the helpdesk team.",
                      style: GoogleFonts.plusJakartaSans(
                        color: textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _sectionTitle("SUPABASE UPDATES", textSecondary),
                    const SizedBox(height: 10),

                    if (_notifications.isEmpty)
                      _emptyState(
                        cardColor: cardColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        borderColor: borderColor,
                        shadowColor: shadowColor,
                        isDark: isDark,
                      ),

                    ..._notifications.map((notif) {
                      final status = (notif["status"] ?? "INFO").toString();
                      final type = (notif["type"] ?? "info").toString();

                      return _notifCard(
                        iconWidget: _iconBox(
                          icon: _notifIcon(type, status),
                          iconColor: _statusColor(status),
                          bgColor: _statusBg(status, isDark),
                        ),
                        title: notif["message"] ?? "-",
                        time: notif["time"] ?? "Just now",
                        status: status,
                        statusColor: _statusColor(status),
                        statusBg: _statusBg(status, isDark),
                        cardColor: cardColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        borderColor: borderColor,
                        shadowColor: shadowColor,
                        isDark: isDark,
                        // 🔥 ON TAP UNTUK BUKA DETAIL TIKET USER 🔥
                        onTap: () async {
                          final ticketId = notif["ticket_id"];
                          if (ticketId == null) return;

                          // Tandai dibaca
                          Supabase.instance.client
                              .from('notifications')
                              .update({'is_read': true})
                              .eq('id', notif['id'])
                              .then((_) {});

                          setState(() => notif["isRead"] = true);

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(color: primary),
                            ),
                          );

                          try {
                            final response = await Supabase.instance.client
                                .from('tickets')
                                .select()
                                .eq('id', ticketId)
                                .single();

                            if (!mounted) return;
                            Navigator.pop(context);

                            // Sesuai dengan format yang diharapkan di TicketDetailPage
                            final mappedTicket = {
                              "ticketId": response["id"],
                              "id": response["ticket_code"] ?? "#TK-0000",
                              "title": response["title"] ?? "Untitled",
                              "description":
                                  response["description"] ?? "No description",
                              "category":
                                  response["category"] ?? "Technical Support",
                              "status": response["status"] ?? "OPEN",
                              "priority": response["priority"] ?? "LOW",
                              "requestedPriority":
                                  response["requested_priority"] ?? "-",
                              "assignedTo":
                                  response["assigned_to"] ?? "Unassigned",
                              "createdAt": response["created_at"],
                              "attachment_url": response["attachment_url"],
                            };

                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TicketDetailPage(
                                  ticket: mappedTicket,
                                  toggleTheme: widget.toggleTheme,
                                ),
                              ),
                            );

                            _loadNotifications();
                          } catch (e) {
                            if (!mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Ticket not found: $e")),
                            );
                          }
                        },
                      );
                    }),

                    const SizedBox(height: 24),

                    _sectionTitle("FEATURED ALERT", textSecondary),
                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF4B3FE0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
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
                                    const Icon(
                                      Icons.bolt,
                                      color: Colors.white70,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "URGENT UPDATE",
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color.fromRGBO(
                                          255,
                                          255,
                                          255,
                                          0.7,
                                        ),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Server Maintenance\nScheduled",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    height: 1.3,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Tomorrow, 02:00 AM UTC",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color.fromRGBO(
                                      255,
                                      255,
                                      255,
                                      0.7,
                                    ),
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
                              color: const Color.fromRGBO(255, 255, 255, 0.12),
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

                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            cardColor: cardColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            borderColor: borderColor,
                            shadowColor: shadowColor,
                            isDark: isDark,
                            value: _activeNotifCount.toString(),
                            label: "ACTIVE UPDATES",
                            icon: Icons.article_outlined,
                            iconColor: primary,
                            iconBg: isDark
                                ? const Color(0xFF2A2456)
                                : const Color(0xFFEDEBFF),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _statCard(
                            cardColor: cardColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            borderColor: borderColor,
                            shadowColor: shadowColor,
                            isDark: isDark,
                            value: _unreadCount.toString(),
                            label: "UNREAD",
                            icon: Icons.notifications_active_outlined,
                            iconColor: const Color(0xFFFF9F43),
                            iconBg: isDark
                                ? const Color(0xFF3A2C16)
                                : const Color(0xFFFFF1E0),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),

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
            currentIndex: 2,
            type: BottomNavigationBarType.fixed,
            backgroundColor: navBg,
            elevation: 0,
            selectedItemColor: primary,
            unselectedItemColor: textSecondary,
            showSelectedLabels: true, // Ubah agar teks muncul
            showUnselectedLabels: true, // Ubah agar teks muncul
            selectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            onTap: (index) {
              if (index == 2) return;

              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DashboardPage(
                      role: "user",
                      toggleTheme: widget.toggleTheme,
                    ),
                  ),
                );
              } else if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TicketListPage(toggleTheme: widget.toggleTheme),
                  ),
                );
              } else if (index == 3) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(
                      toggleTheme: widget.toggleTheme ?? (value) {},
                    ),
                  ),
                );
              }
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

  Widget _sectionTitle(String text, Color textSecondary) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w700,
        color: textSecondary,
        fontSize: 11,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _emptyState({
    required Color cardColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color borderColor,
    required Color shadowColor,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
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
          Icon(
            Icons.notifications_none,
            color: textSecondary.withOpacity(0.6),
            size: 36,
          ),
          const SizedBox(height: 10),
          Text(
            "No notifications found",
            style: GoogleFonts.plusJakartaSans(
              color: textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Updates from helpdesk will appear here.",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _notifCard({
    required Widget iconWidget,
    required String title,
    required String time,
    required String status,
    required Color statusColor,
    required Color statusBg,
    required Color cardColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color borderColor,
    required Color shadowColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            iconWidget,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: textPrimary,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    time,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: textSecondary,
                    ),
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
                style: GoogleFonts.plusJakartaSans(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBox({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: iconColor, size: 22),
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
    required Color textSecondary,
    required Color borderColor,
    required Color shadowColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
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
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
