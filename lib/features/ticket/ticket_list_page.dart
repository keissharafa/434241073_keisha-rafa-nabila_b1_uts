import 'package:flutter/material.dart';
import '../dashboard/dashboard_page.dart';
import '../profile/profile_page.dart';
import 'create_ticket_page.dart';
import 'ticket_detail_page.dart';
import '../notification/notification_page.dart';

class TicketListPage extends StatefulWidget {
  final Function(bool)? toggleTheme;

  const TicketListPage({super.key, this.toggleTheme});

  @override
  State<TicketListPage> createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage> {
  int _selectedIndex = 1;

  final List<Map<String, String>> _tickets = [
    {
      "id": "#TK-8842",
      "title": "VPN Access Issue",
      "date": "Oct 24, 2026",
      "status": "IN PROGRESS",
      "description": "Unable to connect to VPN since morning. Shows timeout error.",
    },
    {
      "id": "#TK-8791",
      "title": "Database Sync Failure",
      "date": "Oct 22, 2026",
      "status": "OPEN",
    },
    {
      "id": "#TK-8650",
      "title": "Slack Integration Auth",
      "date": "Oct 19, 2026",
      "status": "RESOLVED",
    },
  ];

  String getUserStatus(String status) {
    if (status == "OPEN") return "Waiting";
    if (status == "IN PROGRESS") return "In Progress";
    return "Resolved";
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
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
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => NotificationPage(
            toggleTheme: widget.toggleTheme,
          ),
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
    setState(() => _selectedIndex = index);
  }

  Future<void> _openCreateTicket() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => CreateTicketPage()),
    );

    if (result != null) {
      setState(() {
        _tickets.insert(0, {
          "id": result["id"] ?? "#TK-0000",
          "title": result["title"] ?? "Untitled",
          "date": result["date"] ?? "Just now",
          "status": result["status"] ?? "OPEN",
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Ticket \"${result["title"]}\" submitted successfully!",
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 Dark mode tokens
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor     = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final cardColor   = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final navBg       = isDark ? const Color(0xFF1E293B) : Colors.white;

    final activeTickets = _tickets
        .where((t) => t["status"] != "RESOLVED")
        .toList();
    final resolvedTickets = _tickets
        .where((t) => t["status"] == "RESOLVED")
        .toList();

    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: _openCreateTicket,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
        type: BottomNavigationBarType.fixed,
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

            // 🏷️ TITLE
            Text(
              "Your Tickets",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Manage and track your active support requests.",
              style: TextStyle(
                color: const Color(0xFF94A3B8),
                fontSize: 14,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            // 🔍 SEARCH ROW
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: const Color(0xFF94A3B8), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            style: TextStyle(fontSize: 14, color: textPrimary),
                            decoration: InputDecoration(
                              hintText: "Search by ID or Subject...",
                              hintStyle: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Icon(
                    Icons.tune,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                    size: 20,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 🎫 ACTIVE TICKETS
            ...activeTickets.map((t) => _ticketCard(
                  id: t["id"]!,
                  title: t["title"]!,
                  date: t["date"]!,
                  status: t["status"]!,
                  description: t["description"] ?? "No description",
                  cardColor: cardColor,
                  textPrimary: textPrimary,
                )),

            // 🔵 HELP CTA CARD — selalu biru, tidak perlu berubah
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    right: -20,
                    bottom: -30,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    bottom: -50,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "🔔 View Updates",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "See latest updates on your tickets.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2563EB),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NotificationPage(
                                  toggleTheme: widget.toggleTheme,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            "View Updates",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🎫 RESOLVED TICKETS
            ...resolvedTickets.map((t) => _ticketCard(
                  id: t["id"]!,
                  title: t["title"]!,
                  date: t["date"]!,
                  status: t["status"]!,
                  description: t["description"] ?? "No description provided.",
                  cardColor: cardColor,
                  textPrimary: textPrimary,
                )),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _ticketCard({
    required String id,
    required String title,
    required String date,
    required String status,
    required Color cardColor,
    required Color textPrimary,
    String description = "No description provided.",
  }) {
    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    switch (status) {
      case "IN PROGRESS":
        statusColor = const Color(0xFFBC4800);
        statusBg = const Color(0xFFFFF0E6);
        statusIcon = Icons.access_time;
        break;
      case "OPEN":
        statusColor = const Color(0xFFEF4444);
        statusBg = const Color(0xFFFEE2E2);
        statusIcon = Icons.error_outline;
        break;
      default:
        statusColor = const Color(0xFF475569);
        statusBg = const Color(0xFFF1F5F9);
        statusIcon = Icons.check_circle_outline;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TicketDetailPage(
              ticket: {
                "id": id,
                "title": title,
                "status": status,
                "description": description,
              },
            ),
          ),
        );
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    id,
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        getUserStatus(status),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}