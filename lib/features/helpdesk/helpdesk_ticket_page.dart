import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // ---- Style guide constants ----
  static const _bgLight = Color(0xFFEDEFF7);
  static const _surfaceLight = Color(0xFFFFFFFF);
  static const _primary = Color(0xFF6C63FF);
  static const _textPrimaryLight = Color(0xFF14142B);
  static const _textSecondaryLight = Color(0xFF92929D);
  static const _fieldBgLight = Color(
    0xFFF1E9FF,
  ); // pay-category pastel, dipakai utk search/dropdown
  static const _success = Color(0xFF21D07B);
  static const _warning = Color(0xFFFF9F43);
  static const _danger = Color(0xFFF45B69);

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

  // ---- Status: warna text solid dari palette semantic ----
  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case "OPEN":
        return _danger;
      case "PENDING":
        return _warning;
      case "IN PROGRESS":
        return _primary;
      case "RESOLVED":
      case "CLOSED":
        return _success;
      default:
        return _textSecondaryLight;
    }
  }

  // ---- Status: background pastel (versi soft dari warna di atas) ----
  Color _statusBg(String status) {
    switch (status.toUpperCase()) {
      case "OPEN":
        return const Color(0xFFFCE9EB);
      case "PENDING":
        return const Color(0xFFFFF3E6);
      case "IN PROGRESS":
        return const Color(0xFFEEECFF);
      case "RESOLVED":
      case "CLOSED":
        return const Color(0xFFE3FAEC);
      default:
        return const Color(0xFFF0F1F6);
    }
  }

  Color _priorityColor(String p) {
    switch (p.toUpperCase()) {
      case "URGENT":
        return const Color(0xFFE0374B);
      case "HIGH":
        return _danger;
      case "MED":
      case "MEDIUM":
        return _warning;
      case "LOW":
        return _success;
      default:
        return _textSecondaryLight;
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

    final bgColor = isDark ? const Color(0xFF14142B) : _bgLight;
    final cardColor = isDark ? const Color(0xFF1F1F3A) : _surfaceLight;
    final navBg = isDark ? const Color(0xFF1F1F3A) : _surfaceLight;
    final textPrimary = isDark ? const Color(0xFFF4F4FB) : _textPrimaryLight;
    final textSecondary = isDark
        ? const Color(0xFFA0A0B8)
        : _textSecondaryLight;
    final fieldBg = isDark ? const Color(0xFF2A2A55) : _fieldBgLight;
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.3)
        : const Color(0xFF6C63FF).withOpacity(0.07);

    return Scaffold(
      backgroundColor: bgColor,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: _primary))
            : RefreshIndicator(
                onRefresh: _loadHelpdeskTickets,
                color: _primary,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                  children: [
                    // ---- Top App Bar (minimal, no elevation) ----
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: _primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.confirmation_num_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Concierge",
                              style: GoogleFonts.plusJakartaSans(
                                color: _primary,
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
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: shadowColor,
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: textSecondary,
                            size: 18,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Text(
                      "Ticket Command Center",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Your assigned tasks.",
                      style: GoogleFonts.plusJakartaSans(
                        color: textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---- MINI STATS CARD ----
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _miniStat(
                            "ACTIVE TICKETS",
                            _activeTicketCount.toString(),
                            _primary,
                            textSecondary,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: isDark
                                ? Colors.white.withOpacity(0.08)
                                : const Color(0xFFF0F1F6),
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          _miniStat(
                            "AVG. RESPONSE",
                            "14m",
                            _warning,
                            textSecondary,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ---- FILTER CARD ----
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "SEARCH TICKETS",
                            style: GoogleFonts.plusJakartaSans(
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
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: "ID, Subject...",
                              hintStyle: GoogleFonts.plusJakartaSans(
                                color: textSecondary,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: textSecondary,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: fieldBg,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
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
                            bg: fieldBg,
                            textColor: textPrimary,
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _selectedStatus = v);
                            },
                          ),

                          const SizedBox(height: 12),

                          _dropdown(
                            value: _selectedPriority,
                            items: const [
                              "Any Priority",
                              "URGENT",
                              "HIGH",
                              "MEDIUM",
                              "LOW",
                            ],
                            bg: fieldBg,
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
                        textSecondary: textSecondary,
                        shadowColor: shadowColor,
                      ),

                    ..._filteredTickets.map(
                      (t) => _ticketCard(
                        t,
                        cardColor,
                        textPrimary,
                        textSecondary,
                        shadowColor,
                      ),
                    ),
                  ],
                ),
              ),
      ),

      // ---- FAB (Create Ticket) ----
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _primary.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
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
          backgroundColor: _primary,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),

      // ---- Floating Bottom Nav (konsisten sama dashboard) ----
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
            onTap: _onNavTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: navBg,
            elevation: 0,
            selectedItemColor: _primary,
            unselectedItemColor: textSecondary,
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

  Widget _emptyState({
    required Color cardColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color shadowColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _fieldBgLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.inbox_rounded,
              color: Color(0xFF8B5CF6),
              size: 24,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "No tickets assigned",
            style: GoogleFonts.plusJakartaSans(
              color: textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Try adjusting your filters.",
            style: GoogleFonts.plusJakartaSans(
              color: textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ticketCard(
    Map<String, dynamic> t,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    Color shadowColor,
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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leading icon container (rounded-square pastel, konsisten sama style guide)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _fieldBgLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.confirmation_number_outlined,
                    color: Color(0xFF8B5CF6),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            t["id"] ?? "#TK-0000",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _primary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            t["time"] ?? "",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t["title"] ?? "Untitled",
                        style: GoogleFonts.plusJakartaSans(
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
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                    style: GoogleFonts.plusJakartaSans(
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
                  style: GoogleFonts.plusJakartaSans(
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

  Widget _miniStat(
    String label,
    String value,
    Color color,
    Color textSecondary,
  ) {
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
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
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
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF8B5CF6),
          ),
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: textColor),
          dropdownColor: bg,
          borderRadius: BorderRadius.circular(14),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
