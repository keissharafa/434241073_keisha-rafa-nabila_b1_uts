import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'helpdesk_dashboard_page.dart';
import 'helpdesk_ticket_page.dart';
import 'helpdesk_profile_page.dart';
import 'helpdesk_ticket_detail_page.dart'; // Import halaman detail
import '../../services/ticket_service.dart';

class HelpdeskNotificationPage extends StatefulWidget {
  final Function(bool) toggleTheme;

  const HelpdeskNotificationPage({super.key, required this.toggleTheme});

  @override
  State<HelpdeskNotificationPage> createState() =>
      _HelpdeskNotificationPageState();
}

class _HelpdeskNotificationPageState extends State<HelpdeskNotificationPage> {
  int _selectedIndex = 2;

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
        roleTarget: "admin_helpdesk",
      );

      if (!mounted) return;

      setState(() {
        _notifications = data.map((notif) {
          return {
            "id": notif["id"],
            "ticket_id": notif["ticket_id"], // Ambil ID Tiket dari DB
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

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              HelpdeskDashboardPage(toggleTheme: widget.toggleTheme),
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HelpdeskTicketPage(toggleTheme: widget.toggleTheme),
        ),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HelpdeskProfilePage(toggleTheme: widget.toggleTheme),
        ),
      );
    }
  }

  IconData _notifIcon(String type, String status) {
    if (type == "new_ticket") return Icons.warning_amber_rounded;
    if (type == "ticket_update") return Icons.sync_alt_rounded;
    if (status == "RESOLVED" || status == "CLOSED")
      return Icons.check_circle_outline;
    if (status == "PENDING") return Icons.hourglass_bottom_rounded;
    if (status == "IN PROGRESS") return Icons.group_outlined;
    return Icons.notifications_active_outlined;
  }

  Color _statusColor(String status) {
    switch (status) {
      case "OPEN":
        return const Color(0xFFEF4444);
      case "PENDING":
        return const Color(0xFFF97316);
      case "IN PROGRESS":
        return const Color(0xFF2563EB);
      case "RESOLVED":
      case "CLOSED":
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
        return isDark ? const Color(0xFF1D3461) : const Color(0xFFEFF6FF);
      case "RESOLVED":
      case "CLOSED":
        return isDark
            ? const Color.fromRGBO(20, 83, 45, 0.4)
            : const Color(0xFFF0FDF4);
      default:
        return isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    }
  }

  String _statusLabel(String status) {
    if (status.trim().isEmpty) return "INFO";
    return status;
  }

  int get _unreadCount {
    return _notifications.where((n) => n["isRead"] == false).length;
  }

  int get _openAlertCount {
    return _notifications.where((n) => n["status"] == "OPEN").length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark
        ? const Color(0xFFF1F5F9)
        : const Color(0xFF0F172A);
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final navBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final labelColor = const Color(0xFF94A3B8);
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.25)
        : const Color(0xFF2563EB).withOpacity(0.06);

    return Scaffold(
      backgroundColor: bgColor,
      extendBody: true, // Supaya bisa di-scroll tembus di bawah navbar melayang
      body: SafeArea(
        bottom: false,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF2563EB)),
              )
            : RefreshIndicator(
                onRefresh: _loadNotifications,
                color: const Color(0xFF2563EB),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    100,
                  ), // Spasi bawah ditambah
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
                            Text(
                              "Concierge",
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF2563EB),
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

                    const SizedBox(height: 20),

                    Text(
                      "Notification Center",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Admin activity log & system alerts from Supabase.",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: labelColor,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _sectionTitle("SUPABASE NOTIFICATIONS"),
                    const SizedBox(height: 10),

                    if (_notifications.isEmpty)
                      _emptyState(
                        cardColor: cardColor,
                        textPrimary: textPrimary,
                      ),

                    ..._notifications.map((notif) {
                      final status = _statusLabel(notif["status"] ?? "INFO");
                      final type = notif["type"] ?? "info";

                      return _notifCard(
                        isDark: isDark,
                        cardColor: cardColor,
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
                        textPrimary: textPrimary,
                        // 🔥 FUNGSI ON TAP BARU BUAT BUKA DETAIL TIKET 🔥
                        onTap: () async {
                          final ticketId = notif["ticket_id"];
                          if (ticketId == null) return;

                          // Tandai sebagai dibaca di database
                          Supabase.instance.client
                              .from('notifications')
                              .update({'is_read': true})
                              .eq('id', notif['id'])
                              .then((_) {}); // Fire & forget

                          setState(() => notif["isRead"] = true);

                          // Tampilkan Loading
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          );

                          try {
                            // Tarik data tiket full dari Supabase
                            final response = await Supabase.instance.client
                                .from('tickets')
                                .select()
                                .eq('id', ticketId)
                                .single();

                            if (!mounted) return;
                            Navigator.pop(context); // Tutup loading

                            // Map data tiket sebelum dilempar ke halaman detail
                            final mappedTicket = {
                              "dbId": response["id"],
                              "id": response["ticket_code"] ?? "#TK-0000",
                              "title": response["title"] ?? "Untitled",
                              "description":
                                  response["description"] ?? "No description",
                              "category":
                                  response["category"] ?? "Technical Support",
                              "reporter":
                                  response["reporter"] ?? "Unknown User",
                              "status": response["status"] ?? "OPEN",
                              "priority": response["priority"] ?? "LOW",
                              "requestedPriority":
                                  response["requested_priority"] ?? "-",
                              "assignedTo":
                                  response["assigned_to"] ?? "Unassigned",
                              "time": response["created_at"],
                              "strikethrough":
                                  response["strikethrough"] ?? false,
                              "attachment_url": response["attachment_url"],
                            };

                            // Navigasi ke halaman detail
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HelpdeskTicketDetailPage(
                                  ticket: mappedTicket,
                                  toggleTheme: widget.toggleTheme,
                                ),
                              ),
                            );

                            // Refresh notifikasi setelah kembali
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
                        border: Border.all(
                          color: const Color(0xFF334155),
                          width: 1,
                        ),
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
                                      color: Color(0xFFF97316),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "MAINTENANCE NOTICE",
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFFF97316),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Ticket System\nMaintenance Window",
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
                                  "Tomorrow, 02:00–04:00 AM UTC\nTicket intake will be paused.",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color.fromRGBO(
                                      255,
                                      255,
                                      255,
                                      0.6,
                                    ),
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

                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            cardColor: cardColor,
                            textPrimary: textPrimary,
                            value: _unreadCount.toString(),
                            label: "UNREAD ALERTS",
                            icon: Icons.notifications_active_outlined,
                            iconColor: const Color(0xFFEF4444),
                            iconBg: isDark
                                ? const Color(0xFF3B0A0A)
                                : const Color(0xFFFEE2E2),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _statCard(
                            cardColor: cardColor,
                            textPrimary: textPrimary,
                            value: _openAlertCount.toString(),
                            label: "OPEN ALERTS",
                            icon: Icons.warning_amber_rounded,
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
      ),

      // 👇 NAVBAR FLOATING FIX 👇
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
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: navBg,
            elevation: 0,
            selectedItemColor: const Color(0xFF2563EB),
            unselectedItemColor: labelColor,
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
            onTap: _onNavTap,
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

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w700,
        color: const Color(0xFF94A3B8),
        fontSize: 11,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _emptyState({required Color cardColor, required Color textPrimary}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.notifications_none,
            color: Color(0xFF94A3B8),
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
            "Create or update a ticket to generate notifications.",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF94A3B8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _notifCard({
    required bool isDark,
    required Widget iconWidget,
    required String title,
    required String time,
    required String status,
    required Color statusColor,
    required Color statusBg,
    required Color cardColor,
    required Color textPrimary,
    required VoidCallback onTap,
  }) {
    // Dibungkus pakai GestureDetector buat nangkep klikan
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                      color: const Color(0xFF94A3B8),
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
                  fontSize: 10,
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
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: iconColor, size: 20),
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
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
