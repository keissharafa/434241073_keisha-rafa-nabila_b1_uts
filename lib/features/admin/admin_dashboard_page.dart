import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/ticket_service.dart';
import 'admin_ticket_page.dart';
import 'admin_notification_page.dart';
import 'admin_profile_page.dart';

class AdminDashboardPage extends StatefulWidget {
  final Function(bool) toggleTheme;

  const AdminDashboardPage({super.key, required this.toggleTheme});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final TicketService _ticketService = TicketService();

  bool isLoading = true;
  int totalTickets = 0;
  int openTickets = 0;
  int pendingTickets = 0;
  int resolvedTickets = 0;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => isLoading = true);
    try {
      final total = await _ticketService.getTicketCount();
      final open = await _ticketService.getTicketCount(status: 'OPEN');
      final pending = await _ticketService.getTicketCount(
        status: 'IN PROGRESS',
      );
      final res = await _ticketService.getTicketCount(status: 'RESOLVED');
      final cls = await _ticketService.getTicketCount(status: 'CLOSED');

      if (!mounted) return;
      setState(() {
        totalTickets = total;
        openTickets = open;
        pendingTickets = pending;
        resolvedTickets = res + cls;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching admin stats: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  double _ratio(int part) => totalTickets == 0 ? 0 : part / totalTickets;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const primary = Color(0xFF6C63FF);
    const danger = Color(0xFFF45B69);
    const warning = Color(0xFFFF9F43);
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

    return Scaffold(
      backgroundColor: bgColor,
      extendBody: true, // PENTING buat navbar floating
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _fetchStats,
          color: primary,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              16,
              20,
              100,
            ), // Spasi bawah biar gak ketutup navbar
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
                          Icons.admin_panel_settings,
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminNotificationPage(
                            toggleTheme: widget.toggleTheme,
                          ),
                        ),
                      );
                    },
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
                "System Admin",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "System overview and user management.",
                style: GoogleFonts.plusJakartaSans(
                  color: textSecondary,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 24),

              // ── HERO CARD: TOTAL TICKETS ──
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
                              "TOTAL TICKETS",
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
                        isLoading
                            ? const SizedBox(
                                height: 48,
                                width: 48,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                totalTickets.toString(),
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
                                "OPEN",
                                isLoading ? "-" : openTickets.toString(),
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
                                "IN PROGRESS",
                                isLoading ? "-" : pendingTickets.toString(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── RESOLVED STATISTICS CARD ──
              Container(
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "TOTAL RESOLVED",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: textSecondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          isLoading
                              ? const CircularProgressIndicator()
                              : Text(
                                  resolvedTickets.toString(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                    letterSpacing: -1,
                                  ),
                                ),
                          const SizedBox(height: 4),
                          Text(
                            "All-time closed tickets",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _bar(24, primary.withOpacity(0.2)),
                        const SizedBox(width: 4),
                        _bar(40, primary.withOpacity(0.4)),
                        const SizedBox(width: 4),
                        _bar(32, primary.withOpacity(0.55)),
                        const SizedBox(width: 4),
                        _bar(52, primary.withOpacity(0.8)),
                        const SizedBox(width: 4),
                        _bar(44, primary),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── BREAKDOWN: RING CARDS ──
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
                      ringColor: danger,
                      trackColor: danger.withOpacity(0.12),
                      value: _ratio(openTickets),
                      label: "Open",
                      textColor: textPrimary,
                      subColor: textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ringStat(
                      cardColor: cardColor,
                      shadowColor: shadowColor,
                      ringColor: warning,
                      trackColor: warning.withOpacity(0.12),
                      value: _ratio(pendingTickets),
                      label: "In Progress",
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
                      value: _ratio(resolvedTickets),
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
                    icon: Icons.confirmation_num_outlined,
                    iconColor: primary,
                    iconBg: isDark
                        ? const Color(0xFF2A2456)
                        : const Color(0xFFEDEBFF),
                    label: "All Tickets",
                    textColor: textPrimary,
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AdminTicketPage(toggleTheme: widget.toggleTheme),
                      ),
                    ),
                  ),
                ],
              ),
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
              if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AdminTicketPage(toggleTheme: widget.toggleTheme),
                  ),
                );
              }
              if (index == 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AdminNotificationPage(toggleTheme: widget.toggleTheme),
                  ),
                );
              }
              if (index == 3) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AdminProfilePage(toggleTheme: widget.toggleTheme),
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

  Widget _bar(double height, Color color) => Container(
    width: 10,
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(4),
    ),
  );
}
