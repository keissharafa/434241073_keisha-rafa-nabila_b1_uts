import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/ticket_service.dart';
import 'helpdesk_ticket_page.dart';
import 'helpdesk_notification_page.dart';
import 'helpdesk_profile_page.dart';

class HelpdeskDashboardPage extends StatefulWidget {
  final Function(bool) toggleTheme;

  const HelpdeskDashboardPage({super.key, required this.toggleTheme});

  @override
  State<HelpdeskDashboardPage> createState() => _HelpdeskDashboardPageState();
}

class _HelpdeskDashboardPageState extends State<HelpdeskDashboardPage> {
  final TicketService _ticketService = TicketService();
  int _activeTickets = 0;
  bool _isLoading = true;
  String _userName = "Helpdesk";

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? "Helpdesk";

    // Hitung tiket IN PROGRESS yang di-assign ke agen ini
    final count = await _ticketService.getTicketCount(
      status: 'IN PROGRESS',
      assignedTo: name,
    );

    if (!mounted) return;
    setState(() {
      _userName = name;
      _activeTickets = count;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark
        ? const Color(0xFFF1F5F9)
        : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : Colors.grey[500]!;
    final actionCardBg = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFEEF2FF);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF1F5F9),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
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
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HelpdeskNotificationPage(
                        toggleTheme: widget.toggleTheme,
                      ),
                    ),
                  ),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.transparent),
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
            const SizedBox(height: 24),
            Text(
              "Hi, $_userName",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Here are your assigned tickets.",
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "MY ASSIGNED TICKETS",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "$_activeTickets",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Quick Actions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            _actionCard(
              isDark,
              actionCardBg,
              textPrimary,
              Icons.confirmation_num_outlined,
              const Color(0xFF2563EB),
              isDark ? const Color(0xFF1D3461) : const Color(0xFFEFF6FF),
              "View My Tickets",
              "See and resolve your current assignments.",
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      HelpdeskTicketPage(toggleTheme: widget.toggleTheme),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        onTap: (index) {
          if (index == 0) return;
          if (index == 1)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    HelpdeskTicketPage(toggleTheme: widget.toggleTheme),
              ),
            );
          if (index == 2)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    HelpdeskNotificationPage(toggleTheme: widget.toggleTheme),
              ),
            );
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
            icon: Icon(Icons.notifications_outlined),
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

  Widget _actionCard(
    bool isDark,
    Color cardBg,
    Color titleColor,
    IconData icon,
    Color iconColor,
    Color iconBg,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
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
                fontSize: 12,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
