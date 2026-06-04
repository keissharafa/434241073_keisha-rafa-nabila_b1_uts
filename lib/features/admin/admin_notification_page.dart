import 'package:flutter/material.dart';
import '../admin/admin_dashboard_page.dart';
import '../admin/admin_ticket_page.dart';
import 'admin_profile_page.dart';
import '../../services/ticket_service.dart';

class AdminNotificationPage extends StatefulWidget {
  final Function(bool) toggleTheme;

  const AdminNotificationPage({super.key, required this.toggleTheme});

  @override
  State<AdminNotificationPage> createState() => _AdminNotificationPageState();
}

class _AdminNotificationPageState extends State<AdminNotificationPage> {
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

  IconData _notifIcon(String type, String status) {
    if (type == "new_ticket") return Icons.warning_amber_rounded;
    if (type == "ticket_update") return Icons.sync_alt_rounded;
    if (status == "RESOLVED") return Icons.check_circle_outline;
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
    final textPrimary = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final navBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final labelColor = const Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: _loadNotifications,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
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
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Admin activity log & system alerts from Supabase.",
                      style: TextStyle(
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
                              children: const [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.bolt,
                                      color: Color(0xFFF97316),
                                      size: 14,
                                    ),
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
                                SizedBox(height: 10),
                                Text(
                                  "Ticket System\nMaintenance Window",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    height: 1.3,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
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

  Widget _emptyState({
    required Color cardColor,
    required Color textPrimary,
  }) {
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
            style: TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Create or update a ticket to generate notifications.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF94A3B8),
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
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: textPrimary,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
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