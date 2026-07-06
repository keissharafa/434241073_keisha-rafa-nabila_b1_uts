import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/ticket_service.dart';
import 'admin_dashboard_page.dart';
import 'admin_ticket_detail_page.dart';
import 'admin_notification_page.dart';
import 'admin_profile_page.dart';
import 'admin_create_ticket_page.dart'; // Import halaman create tiket admin

class AdminTicketPage extends StatefulWidget {
  final Function(bool) toggleTheme;

  const AdminTicketPage({super.key, required this.toggleTheme});

  @override
  State<AdminTicketPage> createState() => _AdminTicketPageState();
}

class _AdminTicketPageState extends State<AdminTicketPage> {
  int _selectedIndex = 1; // Index untuk All Tickets
  String _selectedStatus = "All Statuses";
  String _selectedPriority = "Any Priority";

  final TextEditingController _searchController = TextEditingController();
  final TicketService _ticketService = TicketService();

  List<Map<String, dynamic>> _tickets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminTickets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminTickets() async {
    try {
      final data = await _ticketService.getAdminTickets();

      if (!mounted) return;

      setState(() {
        _tickets = data.map((ticket) {
          return {
            "dbId": ticket["id"],
            "id": ticket["ticket_code"] ?? "#TK-0000",
            "title": ticket["title"] ?? "Untitled",
            "description": ticket["description"] ?? "No description",
            "category": ticket["category"] ?? "Technical Support",
            "reporter": ticket["reporter"] ?? "Unknown User",
            "source": ticket["source"] ?? "Mobile App",
            "status": ticket["status"] ?? "OPEN",
            "priority": ticket["priority"] ?? "LOW",
            "requestedPriority": ticket["requested_priority"] ?? "-",
            "assignedTo": ticket["assigned_to"] ?? "Unassigned",
            "time": _timeAgo(ticket["created_at"]),
            "strikethrough": ticket["strikethrough"] ?? false,
            "attachment_url": ticket["attachment_url"], // Pastikan di-pass juga
          };
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load admin tickets: $e"),
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
          builder: (_) => AdminDashboardPage(toggleTheme: widget.toggleTheme),
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AdminNotificationPage(toggleTheme: widget.toggleTheme),
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

  // ── STYLE GUIDE SEMANTIC COLORS ──
  static const _primary = Color(0xFF6C63FF);
  static const _danger = Color(0xFFF45B69);
  static const _warning = Color(0xFFFF9F43);
  static const _success = Color(0xFF21D07B);

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
        return const Color(0xFF92929D);
    }
  }

  Color _statusBg(String status) {
    switch (status.toUpperCase()) {
      case "OPEN":
        return const Color(0xFFFDE8EA);
      case "PENDING":
        return const Color(0xFFFFEEDD);
      case "IN PROGRESS":
        return const Color(0xFFEDEBFF);
      case "RESOLVED":
      case "CLOSED":
        return const Color(0xFFDFF7E4);
      default:
        return const Color(0xFFF0F1F6);
    }
  }

  Color _priorityColor(String p) {
    switch (p.toUpperCase()) {
      case "URGENT":
        return const Color(0xFFD6394B);
      case "HIGH":
        return _danger;
      case "MED":
      case "MEDIUM":
        return _warning;
      case "LOW":
        return _success;
      default:
        return const Color(0xFF92929D);
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

    final bgColor = isDark ? const Color(0xFF14142B) : const Color(0xFFEDEFF7);
    final cardColor = isDark ? const Color(0xFF1F1B3A) : Colors.white;
    final textPrimary = isDark
        ? const Color(0xFFF1F1FB)
        : const Color(0xFF14142B);
    final textSecondary = isDark
        ? const Color(0xFFA0A0B8)
        : const Color(0xFF92929D);
    final fieldBg = isDark ? const Color(0xFF241F45) : const Color(0xFFF1E9FF);
    final borderColor = isDark
        ? const Color(0xFF2E2A52)
        : const Color(0xFFF0F1F6);
    final dropdownBg = isDark
        ? const Color(0xFF241F45)
        : const Color(0xFFF1E9FF);
    final navBg = isDark ? const Color(0xFF1F1B3A) : Colors.white;
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.25)
        : _primary.withOpacity(0.06);

    return Scaffold(
      backgroundColor: bgColor,
      extendBody: true, // Untuk floating navbar
      body: SafeArea(
        bottom: false,
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: _primary))
            : RefreshIndicator(
                onRefresh: _loadAdminTickets,
                color: _primary,
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
                                color: const Color(0xFF14142B),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.admin_panel_settings,
                                color: Colors.white,
                                size: 20,
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
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminNotificationPage(
                                  toggleTheme: widget.toggleTheme,
                                ),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
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
                                  size: 20,
                                ),
                              ),
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: _danger,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // HEADER JUDUL & TOMBOL CREATE TICKET
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Global Ticket Queue",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Review and assign tickets to helpdesk agents.",
                                style: GoogleFonts.plusJakartaSans(
                                  color: textSecondary,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            // Navigasi ke halaman create ticket admin
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminCreateTicketPage(
                                  toggleTheme: widget.toggleTheme,
                                ),
                              ),
                            );
                            // Refresh data kalau tiket berhasil dibuat
                            if (result == true) {
                              _loadAdminTickets();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: _primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Create",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _miniStat(
                            "ACTIVE TICKETS",
                            _activeTicketCount.toString(),
                            _primary,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: borderColor,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          _miniStat(
                            "UNASSIGNED",
                            _tickets
                                .where(
                                  (t) =>
                                      t["assignedTo"] == "Unassigned" &&
                                      t["status"] != "RESOLVED",
                                )
                                .length
                                .toString(),
                            _danger,
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
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
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
                              hintText: "ID, Subject, or User...",
                              hintStyle: GoogleFonts.plusJakartaSans(
                                color: textSecondary,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: textSecondary,
                                size: 18,
                              ),
                              filled: true,
                              fillColor: fieldBg,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: _primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Text(
                            "STATUS",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: textSecondary,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _dropdown(
                            value: _selectedStatus,
                            items: const [
                              "All Statuses",
                              "OPEN",
                              "PENDING",
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

                          Text(
                            "PRIORITY",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: textSecondary,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
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

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 46,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: () => setState(() {}),
                                    icon: const Icon(
                                      Icons.filter_list,
                                      size: 16,
                                    ),
                                    label: Text(
                                      "Apply Filters",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: fieldBg,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedStatus = "All Statuses";
                                      _selectedPriority = "Any Priority";
                                      _searchController.clear();
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.refresh_rounded,
                                    color: _primary,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (_filteredTickets.isEmpty)
                      _emptyState(
                        cardColor: cardColor,
                        textPrimary: textPrimary,
                        shadowColor: shadowColor,
                      ),

                    ..._filteredTickets.map(
                      (t) => _ticketCard(
                        t,
                        cardColor,
                        textPrimary,
                        textSecondary,
                        borderColor,
                        shadowColor,
                        isDark,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Showing ${_filteredTickets.length} of ${_tickets.length}",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                        Row(
                          children: [
                            _pageBtn(
                              Icons.chevron_left,
                              false,
                              cardColor,
                              borderColor,
                            ),
                            const SizedBox(width: 6),
                            _pageNumBtn("1", true),
                            const SizedBox(width: 6),
                            _pageBtn(
                              Icons.chevron_right,
                              true,
                              cardColor,
                              borderColor,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
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
            selectedItemColor: _primary,
            unselectedItemColor: textSecondary,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_rounded),
                label: "Dashboard",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.confirmation_num_outlined),
                label: "Ticket",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined),
                label: "Notif",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
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
    required Color shadowColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.confirmation_num_outlined,
            color: Color(0xFF92929D),
            size: 36,
          ),
          const SizedBox(height: 10),
          Text(
            "No tickets found",
            style: GoogleFonts.plusJakartaSans(
              color: textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Try changing the filter or pull to refresh.",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF92929D),
              fontSize: 13,
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
    Color borderColor,
    Color shadowColor,
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
            builder: (_) => AdminTicketDetailPage(
              ticket: t,
              toggleTheme: widget.toggleTheme,
            ),
          ),
        );
        if (result == true) {
          await _loadAdminTickets();
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
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
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
                    color: const Color(0xFFEDEBFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    t["id"] ?? "#TK-0000",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
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
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Text(
                  "Reported by ${t["reporter"] ?? "Unknown"}",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
                Container(
                  width: 3,
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF92929D),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    "Assigned to: ${t["assignedTo"] ?? "Unassigned"}",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: t["assignedTo"] == "Unassigned"
                          ? _danger
                          : _primary,
                    ),
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
                    style: GoogleFonts.plusJakartaSans(
                      color: _statusColor(status),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              "${_priorityPrefix(priority)}$priority",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _priorityColor(priority),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.access_time, size: 12, color: textSecondary),
                const SizedBox(width: 4),
                Text(
                  t["time"] ?? "Just now",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: textSecondary,
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
                style: GoogleFonts.plusJakartaSans(
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF92929D),
          ),
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: textColor),
          dropdownColor: bg,
          borderRadius: BorderRadius.circular(14),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _pageBtn(
    IconData icon,
    bool active,
    Color cardColor,
    Color borderColor,
  ) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Icon(
        icon,
        size: 18,
        color: active ? _primary : const Color(0xFF92929D),
      ),
    );
  }

  Widget _pageNumBtn(String num, bool active) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: active ? _primary : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          num,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: active ? Colors.white : const Color(0xFF92929D),
          ),
        ),
      ),
    );
  }
}
