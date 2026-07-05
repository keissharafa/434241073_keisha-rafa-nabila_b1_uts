import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpdesk_dashboard_page.dart';
import 'helpdesk_notification_page.dart';
import 'helpdesk_profile_page.dart';
import 'helpdesk_ticket_detail_page.dart';
import 'helpdesk_create_ticket_page.dart'; // Import halaman create ticket baru

class HelpdeskTicketPage extends StatefulWidget {
  final Function(bool) toggleTheme;

  const HelpdeskTicketPage({super.key, required this.toggleTheme});

  @override
  State<HelpdeskTicketPage> createState() => _HelpdeskTicketPageState();
}

class _HelpdeskTicketPageState extends State<HelpdeskTicketPage> {
  int _selectedIndex = 1;
  String _selectedStatus = "All Statuses";
  String _selectedPriority = "Any Priority";

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _tickets = [];
  bool isLoading = true;
  String _userName = "";

  @override
  void initState() {
    super.initState();
    _loadHelpdeskTickets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHelpdeskTickets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userName = prefs.getString('user_name') ?? "Alex Support";

      final response = await Supabase.instance.client
          .from('tickets')
          .select()
          .eq('assigned_to', _userName)
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        _tickets = (response as List).map((ticket) {
          return {
            "dbId": ticket["id"],
            "id": ticket["ticket_code"] ?? "#TK-0000",
            "title": ticket["title"] ?? "Untitled",
            "description": ticket["description"] ?? "No description",
            "category": ticket["category"] ?? "Technical Support",
            "reporter": ticket["reporter"] ?? "Unknown User",
            "status": ticket["status"] ?? "OPEN",
            "priority": ticket["priority"] ?? "LOW",
            "requestedPriority": ticket["requested_priority"] ?? "-",
            "assignedTo": ticket["assigned_to"] ?? "Unassigned",
            "time": _timeAgo(ticket["created_at"]),
            "strikethrough": ticket["strikethrough"] ?? false,
            "attachment_url": ticket["attachment_url"],
          };
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load tickets: $e"),
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

  List<Map<String, dynamic>> get _filteredTickets {
    return _tickets.where((ticket) {
      final q = _searchController.text.toLowerCase();
      final title = (ticket["title"] ?? "").toString().toLowerCase();
      final id = (ticket["id"] ?? "").toString().toLowerCase();
      final reporter = (ticket["reporter"] ?? "").toString().toLowerCase();

      final matchesSearch =
          title.contains(q) || id.contains(q) || reporter.contains(q);

      final matchesStatus =
          _selectedStatus == "All Statuses" ||
          ticket["status"] == _selectedStatus;

      final matchesPriority =
          _selectedPriority == "Any Priority" ||
          ticket["priority"] == _selectedPriority;

      return matchesSearch && matchesStatus && matchesPriority;
    }).toList();
  }

  int get _activeTicketCount {
    return _tickets
        .where((t) => t["status"] != "RESOLVED" && t["status"] != "CLOSED")
        .length;
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
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              HelpdeskNotificationPage(toggleTheme: widget.toggleTheme),
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
    setState(() => _selectedIndex = index);
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
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

  Color _statusBg(String status) {
    switch (status.toUpperCase()) {
      case "OPEN":
        return const Color(0xFFFEE2E2);
      case "PENDING":
        return const Color(0xFFFFF7ED);
      case "IN PROGRESS":
        return const Color(0xFFEFF6FF);
      case "RESOLVED":
      case "CLOSED":
        return const Color(0xFFDCFCE7);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _priorityColor(String p) {
    switch (p.toUpperCase()) {
      case "URGENT":
        return const Color(0xFFDC2626);
      case "HIGH":
        return const Color(0xFFEF4444);
      case "MED":
      case "MEDIUM":
        return const Color(0xFFF97316);
      case "LOW":
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF475569);
    }
  }

  String _priorityPrefix(String p) {
    switch (p.toUpperCase()) {
      case "URGENT":
        return "!! ";
      case "HIGH":
        return "! ";
      case "MED":
      case "MEDIUM":
        return "— ";
      case "LOW":
        return "∨ ";
      default:
        return "  ";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark
        ? const Color(0xFFF1F5F9)
        : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : Colors.grey[500]!;
    final fieldBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFEEF2FF);
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final dropdownBg = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFEEF2FF);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadHelpdeskTickets,
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
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF475569),
                            size: 20,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Text(
                      "Ticket Command Center",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Your assigned tasks.",
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // MINI STATS
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          _miniStat(
                            "ACTIVE TICKETS",
                            _activeTicketCount.toString(),
                            const Color(0xFF2563EB),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: borderColor,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          _miniStat(
                            "AVG. RESPONSE",
                            "14m",
                            const Color(0xFFF97316),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // FILTER CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "SEARCH TICKETS",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: textSecondary,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            style: TextStyle(fontSize: 14, color: textPrimary),
                            decoration: InputDecoration(
                              hintText: "ID, Subject...",
                              hintStyle: TextStyle(
                                color: textSecondary,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: fieldBg,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          _dropdown(
                            value: _selectedStatus,
                            items: const [
                              "All Statuses",
                              "OPEN",
                              "IN PROGRESS",
                              "RESOLVED",
                              "CLOSED",
                            ],
                            bg: dropdownBg,
                            textColor: textPrimary,
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _selectedStatus = v);
                            },
                          ),

                          const SizedBox(height: 14),

                          _dropdown(
                            value: _selectedPriority,
                            items: const [
                              "Any Priority",
                              "URGENT",
                              "HIGH",
                              "MEDIUM",
                              "LOW",
                            ],
                            bg: dropdownBg,
                            textColor: textPrimary,
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _selectedPriority = v);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (_filteredTickets.isEmpty)
                      _emptyState(
                        cardColor: cardColor,
                        textPrimary: textPrimary,
                      ),

                    ..._filteredTickets.map(
                      (t) => _ticketCard(
                        t,
                        cardColor,
                        textPrimary,
                        textSecondary,
                        borderColor,
                        isDark,
                      ),
                    ),

                    const SizedBox(height: 80), // Biar gak ketutupan FAB
                  ],
                ),
              ),
      ),

      // 👇 INI TOMBOL + (CREATE TICKET) UNTUK HELPDESK 👇
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  HelpdeskCreateTicketPage(toggleTheme: widget.toggleTheme),
            ),
          );
          if (result == true) {
            await _loadHelpdeskTickets(); // Refresh daftar setelah buat tiket
          }
        },
        backgroundColor: const Color(0xFF2563EB),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
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
        unselectedLabelStyle: const TextStyle(fontSize: 10, letterSpacing: 0.5),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
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
          const SizedBox(height: 10),
          Text(
            "No tickets assigned",
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _ticketCard(
    Map<String, dynamic> t,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
    bool isDark,
  ) {
    final isStrike = t["strikethrough"] == true;
    final status = (t["status"] ?? "OPEN").toString();
    final priority = (t["priority"] ?? "LOW").toString();

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => HelpdeskTicketDetailPage(
              ticket: t,
              toggleTheme: widget.toggleTheme,
            ),
          ),
        );
        if (result == true) {
          await _loadHelpdeskTickets();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    t["id"] ?? "#TK-0000",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t["title"] ?? "Untitled",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isStrike ? textSecondary : textPrimary,
                      decoration: isStrike
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _statusBg(status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: _statusColor(status),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  "${_priorityPrefix(priority)}$priority",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _priorityColor(priority),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required Color bg,
    required Color textColor,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF475569),
          ),
          style: TextStyle(fontSize: 14, color: textColor),
          dropdownColor: bg,
          borderRadius: BorderRadius.circular(12),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
