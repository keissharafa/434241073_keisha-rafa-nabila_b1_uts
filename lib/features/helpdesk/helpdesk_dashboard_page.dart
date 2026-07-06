import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  // Variabel untuk menampung rincian tiket tanpa OPEN
  int _totalTickets = 0;
  int _inProgressTickets = 0;
  int _closedTickets = 0;

  bool _isLoading = true;
  String _userName = "Helpdesk";

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name') ?? "Helpdesk";

      // Ambil SEMUA tiket yang di-assign ke agen ini
      final response = await Supabase.instance.client
          .from('tickets')
          .select('status')
          .eq('assigned_to', name);

      final tickets = response as List;

      int inProgress = 0;
      int closed = 0;

      // Kelompokkan berdasarkan statusnya
      for (var t in tickets) {
        final status = (t['status'] ?? 'OPEN').toString().toUpperCase();
        if (status == 'IN PROGRESS' || status == 'PENDING') {
          inProgress++;
        } else if (status == 'RESOLVED' || status == 'CLOSED') {
          closed++;
        }
      }

      if (!mounted) return;
      setState(() {
        _userName = name;
        _totalTickets = tickets.length;
        _inProgressTickets = inProgress;
        _closedTickets = closed;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching helpdesk stats: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
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

    final navBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.25)
        : const Color(0xFF2563EB).withOpacity(0.06);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF1F5F9),
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadStats,
          color: const Color(0xFF2563EB),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
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
                      Text(
                        "Concierge",
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF2563EB),
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
              Text(
                "Hi, $_userName",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Here is your assignment breakdown.",
                style: GoogleFonts.plusJakartaSans(
                  color: textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // ── HERO CARD BARU (Tanpa OPEN) ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.35),
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
                              "TOTAL ASSIGNED",
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.assignment_ind_outlined,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _isLoading
                            ? const SizedBox(
                                height: 48,
                                width: 48,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "$_totalTickets",
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 44,
                                  fontWeight: FontWeight.bold,
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
                                "IN PROGRESS",
                                _isLoading
                                    ? "-"
                                    : _inProgressTickets.toString(),
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
                                "CLOSED",
                                _isLoading ? "-" : _closedTickets.toString(),
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

              Text(
                "Quick Actions",
                style: GoogleFonts.plusJakartaSans(
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
      ),

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
            selectedItemColor: const Color(0xFF2563EB),
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
                        HelpdeskTicketPage(toggleTheme: widget.toggleTheme),
                  ),
                );
              }
              if (index == 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HelpdeskNotificationPage(
                      toggleTheme: widget.toggleTheme,
                    ),
                  ),
                );
              }
              if (index == 3) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        HelpdeskProfilePage(toggleTheme: widget.toggleTheme),
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
            fontSize:
                10, // Dikembalikan ke ukuran normal karena space-nya udah lega
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20, // Angkanya kembali dibesarkan
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
