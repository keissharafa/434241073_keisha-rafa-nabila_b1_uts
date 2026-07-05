import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../profile/profile_page.dart';
import '../ticket/ticket_list_page.dart';
import '../notification/notification_page.dart';
import '../../services/ticket_service.dart';

class DashboardPage extends StatefulWidget {
  final String role;
  final Function(bool)? toggleTheme;

  const DashboardPage({super.key, required this.role, this.toggleTheme});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TicketService _ticketService = TicketService();

  bool _isLoading = true;
  int _totalTickets = 0;
  int _activeTickets = 0;
  int _resolvedTickets = 0;
  List<Map<String, dynamic>> _recentTickets = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final tickets = await _ticketService.getUserTickets();

      int active = 0;
      int resolved = 0;

      for (var t in tickets) {
        final status = (t['status'] ?? 'OPEN').toString().toUpperCase();
        if (status == 'RESOLVED' || status == 'CLOSED') {
          resolved++;
        } else {
          active++;
        }
      }

      if (!mounted) return;
      setState(() {
        _totalTickets = tickets.length;
        _activeTickets = active;
        _resolvedTickets = resolved;
        _recentTickets = tickets.take(3).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching dashboard data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _timeAgo(dynamic rawDate) {
    if (rawDate == null) return "JUST NOW";
    try {
      final date = DateTime.parse(rawDate.toString()).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return "${diff.inMinutes}M AGO";
      if (diff.inHours < 24) return "${diff.inHours}H AGO";
      if (diff.inDays == 1) return "YESTERDAY";
      return "${diff.inDays} DAYS AGO";
    } catch (_) {
      return "JUST NOW";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const primary = Color(0xFF6C63FF);
    const success = Color(0xFF21D07B);

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

    final double activeRatio = _totalTickets == 0
        ? 0.0
        : _activeTickets / _totalTickets;
    final double resolvedRatio = _totalTickets == 0
        ? 0.0
        : _resolvedTickets / _totalTickets;

    return Scaffold(
      backgroundColor: bgColor,
      extendBody:
          true, // PENTING: Supaya konten bisa di-scroll di belakang navbar ngambang
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _fetchDashboardData,
          color: primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── TOP BAR ──
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
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              NotificationPage(toggleTheme: widget.toggleTheme),
                        ),
                      ),
                      child: Container(
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
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── GREETING ──
                Text(
                  "Good morning, Alex",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
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

                // ── HERO CARD ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6E8CFB), Color(0xFF4C3FD2)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "MY TICKETS",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: Colors.white.withOpacity(0.75),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.confirmation_num_outlined,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _isLoading
                              ? const SizedBox(
                                  height: 48,
                                  width: 48,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _totalTickets.toString(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -1,
                                  ),
                                ),
                          const SizedBox(height: 20),
                          Container(
                            height: 1,
                            color: Colors.white.withOpacity(0.15),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _heroMiniStat(
                                  "ACTIVE",
                                  _isLoading ? "-" : _activeTickets.toString(),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 32,
                                color: Colors.white.withOpacity(0.15),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _heroMiniStat(
                                  "RESOLVED",
                                  _isLoading
                                      ? "-"
                                      : _resolvedTickets.toString(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── BREAKDOWN ──
                Text(
                  "Breakdown",
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _ringStat(
                        cardColor: cardColor,
                        shadowColor: shadowColor,
                        ringColor: primary,
                        trackColor: primary.withOpacity(0.12),
                        value: activeRatio,
                        label: "Active",
                        textColor: textPrimary,
                        subColor: textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ringStat(
                        cardColor: cardColor,
                        shadowColor: shadowColor,
                        ringColor: success,
                        trackColor: success.withOpacity(0.12),
                        value: resolvedRatio,
                        label: "Resolved",
                        textColor: textPrimary,
                        subColor: textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── QUICK ACTIONS ──
                Text(
                  "Quick Actions",
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _shortcutTile(
                      cardColor: cardColor,
                      shadowColor: shadowColor,
                      borderColor: borderColor,
                      isDark: isDark,
                      icon: Icons.add_circle_outline,
                      iconColor: primary,
                      iconBg: isDark
                          ? const Color(0xFF2A2456)
                          : const Color(0xFFEDEBFF),
                      label: "Create Ticket",
                      textColor: textPrimary,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TicketListPage(toggleTheme: widget.toggleTheme),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ── RECENT ACTIVITY ──
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
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TicketListPage(toggleTheme: widget.toggleTheme),
                        ),
                      ),
                      child: Text(
                        "View All",
                        style: GoogleFonts.plusJakartaSans(
                          color: primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_recentTickets.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "No recent activity.",
                        style: GoogleFonts.plusJakartaSans(
                          color: textSecondary,
                        ),
                      ),
                    ),
                  )
                else
                  ..._recentTickets.map(
                    (t) => _buildDynamicTicketItem(
                      t,
                      cardColor,
                      textPrimary,
                      textSecondary,
                      shadowColor,
                      primary,
                    ),
                  ),

                const SizedBox(
                  height: 100,
                ), // Spasi ekstra biar gak nabrak navbar
              ],
            ),
          ),
        ),
      ),

      // NAVBAR FLOATING
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20,
        ), // Memberikan GAP kiri, kanan, dan bawah
        decoration: BoxDecoration(
          color: navBg,
          borderRadius: BorderRadius.circular(24), // Melengkung di SEMUA sisi
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24), // Samain dengan Container
          child: BottomNavigationBar(
            currentIndex: 0,
            type: BottomNavigationBarType.fixed,
            backgroundColor: navBg,
            elevation: 0,
            selectedItemColor: primary,
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
            onTap: (index) {
              if (index == 0) return;
              if (index == 1)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TicketListPage(toggleTheme: widget.toggleTheme),
                  ),
                );
              if (index == 2)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        NotificationPage(toggleTheme: widget.toggleTheme),
                  ),
                );
              if (index == 3)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(
                      toggleTheme: widget.toggleTheme ?? (value) {},
                    ),
                  ),
                );
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

  Widget _buildDynamicTicketItem(
    Map<String, dynamic> t,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    Color shadowColor,
    Color primary,
  ) {
    final status = (t['status'] ?? 'OPEN').toString().toUpperCase();
    final title = (t['title'] ?? 'Untitled Ticket').toString();

    String desc = (t['description'] ?? 'No description').toString();
    if (desc.length > 35) desc = '${desc.substring(0, 35)}...';

    final ticketId = (t['ticket_code'] ?? '#TK-0000').toString();
    final timeAgo = _timeAgo(t['created_at']);

    Color statusColor;
    Color statusBg;
    IconData icon;
    Color iconBg;
    Color iconColor;

    if (status == 'RESOLVED' || status == 'CLOSED') {
      statusColor = const Color(0xFF21D07B);
      statusBg = const Color(0xFFE1F9EE);
      iconBg = primary;
      iconColor = Colors.white;
      icon = Icons.check;
    } else if (status == 'IN PROGRESS' || status == 'PENDING') {
      statusColor = const Color(0xFFFF9F43);
      statusBg = const Color(0xFFFFF1E0);
      iconBg = const Color(0xFFFFF1E0);
      iconColor = const Color(0xFFFF9F43);
      icon = Icons.hourglass_empty;
    } else {
      // OPEN
      statusColor = const Color(0xFFF45B69);
      statusBg = const Color(0xFFFDE8EA);
      iconBg = const Color(0xFFFDE8EA);
      iconColor = const Color(0xFFF45B69);
      icon = Icons.priority_high;
    }

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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                  desc,
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

  Widget _heroMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _ringStat({
    required Color cardColor,
    required Color shadowColor,
    required Color ringColor,
    required Color trackColor,
    required double value,
    required String label,
    required Color textColor,
    required Color subColor,
  }) {
    final percentLabel = "${(value * 100).round()}%";
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation(trackColor),
                  ),
                ),
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    value: value.clamp(0, 1),
                    strokeWidth: 6,
                    strokeCap: StrokeCap.round,
                    valueColor: AlwaysStoppedAnimation(ringColor),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                Text(
                  percentLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: subColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _shortcutTile({
    required Color cardColor,
    required Color shadowColor,
    required Color borderColor,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(18),
              border: isDark ? Border.all(color: borderColor) : null,
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 72,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
