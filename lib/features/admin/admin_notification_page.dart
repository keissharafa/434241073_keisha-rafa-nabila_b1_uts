import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/ticket_service.dart';
import 'admin_dashboard_page.dart';
import 'admin_ticket_page.dart';
import 'admin_profile_page.dart';

class AdminNotificationPage extends StatefulWidget {
  final Function(bool) toggleTheme;

  const AdminNotificationPage({super.key, required this.toggleTheme});

  @override
  State<AdminNotificationPage> createState() => _AdminNotificationPageState();
}

class _AdminNotificationPageState extends State<AdminNotificationPage> {
  int _selectedIndex = 2; // Index untuk Alerts/Notifications

  final TicketService _ticketService = TicketService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      // Mengambil notifikasi dengan target admin_helpdesk
      final data = await _ticketService.getNotifications(
        roleTarget: 'admin_helpdesk',
      );

      if (!mounted) return;
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
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
      if (diff.inDays == 1) return "Yesterday";
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
          builder: (_) => AdminProfilePage(toggleTheme: widget.toggleTheme),
        ),
      );
    }
    setState(() => _selectedIndex = index);
  }

  // Menentukan Ikon berdasarkan tipe notifikasi
  IconData _getIconData(String? type) {
    switch (type) {
      case 'new_ticket':
        return Icons.confirmation_num;
      case 'ticket_assigned':
        return Icons.assignment_ind;
      case 'ticket_update':
      case 'status_update':
        return Icons.update;
      default:
        return Icons.notifications;
    }
  }

  // Menentukan Warna Ikon berdasarkan tipe notifikasi (mengikuti palette style guide)
  Color _getIconColor(String? type) {
    switch (type) {
      case 'new_ticket':
        return const Color(0xFF6C63FF); // Primary Indigo
      case 'ticket_assigned':
        return const Color(0xFFFF9F43); // Semantic Warning
      case 'ticket_update':
      case 'status_update':
        return const Color(0xFF21D07B); // Semantic Success
      default:
        return const Color(0xFF92929D); // Text Secondary
    }
  }

  // Menentukan Warna Background Ikon berdasarkan tipe notifikasi
  Color _getIconBgColor(String? type, bool isDark) {
    if (isDark) {
      switch (type) {
        case 'new_ticket':
          return const Color(0xFF2A2456);
        case 'ticket_assigned':
          return const Color(0xFF3A2C16);
        case 'ticket_update':
        case 'status_update':
          return const Color(0xFF17352A);
        default:
          return const Color(0xFF2E2A52);
      }
    }
    switch (type) {
      case 'new_ticket':
        return const Color(0xFFEDEBFF);
      case 'ticket_assigned':
        return const Color(0xFFFFF1E0);
      case 'ticket_update':
      case 'status_update':
        return const Color(0xFFE1F9EE);
      default:
        return const Color(0xFFF0F1F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── STYLE GUIDE PALETTE (sama dengan Dashboard) ──
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER CUSTOM
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
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
                          Icons.admin_panel_settings,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Admin Hub",
                        style: GoogleFonts.plusJakartaSans(
                          color: primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // Fitur Mark All as Read (Visual Only untuk saat ini)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("All alerts marked as read."),
                        ),
                      );
                    },
                    child: Text(
                      "Mark all read",
                      style: GoogleFonts.plusJakartaSans(
                        color: primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "System Alerts",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: primary))
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      color: primary,
                      child: _notifications.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
                                ),
                                Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.notifications_off_outlined,
                                        size: 64,
                                        color: textSecondary.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "No alerts at the moment",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "You're all caught up!",
                                        style: GoogleFonts.plusJakartaSans(
                                          color: textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                10,
                                20,
                                20,
                              ),
                              itemCount: _notifications.length,
                              itemBuilder: (context, index) {
                                final notif = _notifications[index];
                                final isRead = notif['is_read'] == true;
                                final notifType =
                                    notif['notification_type'] as String?;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: isDark
                                        ? Border.all(color: borderColor)
                                        : null,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: _getIconBgColor(
                                            notifType,
                                            isDark,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Icon(
                                          _getIconData(notifType),
                                          color: _getIconColor(notifType),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    notif['title'] ??
                                                        "Notification",
                                                    style:
                                                        GoogleFonts.plusJakartaSans(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15,
                                                          color: textPrimary,
                                                        ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  _timeAgo(notif['created_at']),
                                                  style:
                                                      GoogleFonts.plusJakartaSans(
                                                        fontSize: 11,
                                                        color: textSecondary,
                                                      ),
                                                ),
                                                if (!isRead) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: primary,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              notif['message'] ?? "",
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontSize: 13,
                                                    color: textSecondary,
                                                    height: 1.4,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
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
            currentIndex: _selectedIndex,
            onTap: _onNavTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: navBg,
            elevation: 0,
            selectedItemColor: primary,
            unselectedItemColor: textSecondary,
            showSelectedLabels: false,
            showUnselectedLabels: false,
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
                icon: Icon(Icons.notifications_outlined),
                label: "ALERTS",
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
}
