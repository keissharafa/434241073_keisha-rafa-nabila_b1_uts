import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/ticket_service.dart';

class TicketDetailPage extends StatefulWidget {
  final Map ticket;
  final Function(bool)? toggleTheme;

  const TicketDetailPage({super.key, required this.ticket, this.toggleTheme});

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  final TicketService _ticketService = TicketService();
  final TextEditingController _commentController = TextEditingController();

  List<Map<String, dynamic>> _comments = [];
  bool isLoadingComments = true;
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final rawId = widget.ticket["ticketId"];
    if (rawId == null) {
      // tiket belum punya id numerik asli (mis. masih dummy lama)
      setState(() => isLoadingComments = false);
      return;
    }

    try {
      final data = await _ticketService.getComments(ticketId: rawId as int);
      if (!mounted) return;
      setState(() {
        _comments = data;
        isLoadingComments = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingComments = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load comments: $e")));
    }
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    final rawId = widget.ticket["ticketId"];

    if (text.isEmpty || rawId == null || isSending) return;

    setState(() => isSending = true);

    try {
      await _ticketService.addComment(
        ticketId: rawId as int,
        senderRole: "user",
        senderName: "Alex Johnson", // TODO: ganti pas auth asli sudah ada
        message: text,
      );
      _commentController.clear();
      await _loadComments();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to send comment: $e")));
    } finally {
      if (mounted) setState(() => isSending = false);
    }
  }

  // 🕒 Hitung "X ago" sederhana dari created_at
  String _timeAgo(dynamic rawDate) {
    if (rawDate == null) return "recently";
    try {
      final date = DateTime.parse(rawDate.toString());
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
      if (diff.inHours < 24) return "${diff.inHours}h ago";
      return "${diff.inDays}d ago";
    } catch (_) {
      return "recently";
    }
  }

  List<Map<String, String>> _buildTimelineSteps() {
    final status = (widget.ticket["status"] ?? "OPEN").toString().toUpperCase();
    final assignedTo = widget.ticket["assignedTo"];
    final isResolved = status == "RESOLVED" || status == "CLOSED";
    final isInProgress = status == "IN PROGRESS";

    final doneFlags = <bool>[
      true, // Ticket Created selalu selesai
      assignedTo != null && assignedTo.toString().isNotEmpty,
      isInProgress || isResolved,
      isResolved,
    ];

    final labels = ["Ticket Created", "Sent to Admin", "In Progress", "Closed"];

    int activeIndex = doneFlags.indexWhere((d) => !d);
    if (activeIndex == -1) activeIndex = labels.length;

    return List.generate(labels.length, (i) {
      final state = i < activeIndex
          ? "completed"
          : (i == activeIndex ? "active" : "upcoming");
      return {"label": labels[i], "state": state};
    });
  }

  Color _priorityColor(String p) {
    switch (p.toUpperCase()) {
      case "URGENT":
        return const Color(0xFFB91C3D);
      case "HIGH":
        return const Color(0xFFF45B69);
      case "MED":
      case "MEDIUM":
        return const Color(0xFFFF9F43);
      case "LOW":
        return const Color(0xFF21D07B);
      default:
        return const Color(0xFF92929D);
    }
  }

  Color _statusColor(String s, Color primary) {
    switch (s.toUpperCase()) {
      case "OPEN":
        return const Color(0xFFF45B69);
      case "IN PROGRESS":
        return primary;
      case "RESOLVED":
      case "CLOSED":
        return const Color(0xFF21D07B);
      default:
        return const Color(0xFF92929D);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── STYLE GUIDE PALETTE (disamakan dengan AdminTicketDetailPage) ──
    const primary = Color(0xFF6C63FF);

    final bgColor = isDark ? const Color(0xFF14142B) : const Color(0xFFEDEFF7);
    final cardColor = isDark ? const Color(0xFF1F1B3A) : Colors.white;
    final textPrimary = isDark
        ? const Color(0xFFF1F1FB)
        : const Color(0xFF14142B);
    final textSecondary = isDark
        ? const Color(0xFFA0A0B8)
        : const Color(0xFF92929D);
    final textMuted = textSecondary;
    final borderColor = isDark
        ? const Color(0xFF2E2A52)
        : const Color(0xFFF0F1F6);
    final fieldBg = isDark ? const Color(0xFF14142B) : const Color(0xFFF0F1F6);
    final inputBarBg = cardColor;
    final bubbleAdminBg = isDark
        ? const Color(0xFF2E2A52)
        : const Color(0xFFF0F1F6);
    final bubbleAdminText = textPrimary;
    final idBadgeBg = isDark
        ? const Color(0xFF2A2456)
        : const Color(0xFFEDEBFF);
    final timelineBg = cardColor;
    final dividerColor = borderColor;
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.25)
        : const Color(0xFF6C63FF).withOpacity(0.06);

    final status = (widget.ticket["status"] ?? "OPEN").toString();
    final priority =
        (widget.ticket["priority"] ??
                widget.ticket["requestedPriority"] ??
                "MEDIUM")
            .toString()
            .toUpperCase();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // 🔝 HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: textPrimary,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      "Ticket Details",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: textPrimary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // 🔽 CONTENT
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // ID + TIME
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: idBadgeBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.ticket["id"] ?? "#TK-0000",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Opened ${_timeAgo(widget.ticket["createdAt"])}",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // TITLE
                  Text(
                    widget.ticket["title"] ?? "Untitled Ticket",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 📄 DESCRIPTION CARD
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(22),
                      border: isDark ? Border.all(color: borderColor) : null,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 14,
                              color: primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "ORIGINAL REPORT",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.ticket["description"] ??
                              "No description provided.",
                          style: GoogleFonts.plusJakartaSans(
                            height: 1.6,
                            fontSize: 14,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🗂️ TRACKING TIMELINE (data asli)
                  _buildTrackingTimeline(
                    steps: _buildTimelineSteps(),
                    cardColor: timelineBg,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    dividerColor: dividerColor,
                    primary: primary,
                    isDark: isDark,
                    borderColor: borderColor,
                    shadowColor: shadowColor,
                  ),

                  const SizedBox(height: 16),

                  // STATUS & PRIORITY (data asli)
                  Row(
                    children: [
                      _badge(
                        "STATUS",
                        status,
                        _statusColor(status, primary),
                        isDark
                            ? const Color(0xFF2A2456)
                            : const Color(0xFFEDEBFF),
                      ),
                      const SizedBox(width: 10),
                      _badge(
                        "PRIORITY",
                        priority,
                        _priorityColor(priority),
                        isDark
                            ? const Color(0xFF3A2C16)
                            : const Color(0xFFFFF1E0),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "CONVERSATION",
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1,
                      color: textMuted,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 💬 CHAT (data asli dari ticket_comments)
                  if (isLoadingComments)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(color: primary),
                      ),
                    )
                  else if (_comments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "Belum ada komentar. Mulai percakapan di bawah.",
                        style: GoogleFonts.plusJakartaSans(
                          color: textMuted,
                          fontSize: 13,
                        ),
                      ),
                    )
                  else
                    ..._comments.map((c) {
                      final senderRole = (c["sender_role"] ?? "user")
                          .toString();
                      final isUser = senderRole == "user";
                      final senderName = (c["sender_name"] ?? "Unknown")
                          .toString();
                      final initials = senderName.trim().isNotEmpty
                          ? senderName
                                .trim()
                                .split(" ")
                                .map((w) => w[0])
                                .take(2)
                                .join()
                                .toUpperCase()
                          : "U";
                      final avatarColor = isUser
                          ? primary
                          : const Color(0xFFFF9F43);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: isUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (!isUser) ...[
                              _avatar(initials, avatarColor),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Column(
                                crossAxisAlignment: isUser
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$senderName • ${_timeAgo(c["created_at"])}",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isUser ? primary : bubbleAdminBg,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(
                                          isUser ? 16 : 4,
                                        ),
                                        topRight: Radius.circular(
                                          isUser ? 4 : 16,
                                        ),
                                        bottomLeft: const Radius.circular(16),
                                        bottomRight: const Radius.circular(16),
                                      ),
                                      border: (!isUser && !isDark)
                                          ? Border.all(color: borderColor)
                                          : null,
                                    ),
                                    child: Text(
                                      (c["message"] ?? "").toString(),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        height: 1.5,
                                        color: isUser
                                            ? Colors.white
                                            : bubbleAdminText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isUser) ...[
                              const SizedBox(width: 8),
                              _avatar(initials, avatarColor),
                            ],
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            // ✍️ INPUT BAR (kirim komentar asli)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: inputBarBg,
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: "Add a comment...",
                          hintStyle: GoogleFonts.plusJakartaSans(
                            color: textMuted,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: fieldBg,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: Icon(
                            Icons.attach_file,
                            color: textMuted,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                      child: isSending
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : IconButton(
                              icon: const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: _sendComment,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🗂️ TRACKING TIMELINE (tetap nerima steps dari luar, bukan hardcoded)
  Widget _buildTrackingTimeline({
    required List<Map<String, String>> steps,
    required Color cardColor,
    required Color textPrimary,
    required Color textMuted,
    required Color dividerColor,
    required Color primary,
    required bool isDark,
    required Color borderColor,
    required Color shadowColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: isDark ? Border.all(color: borderColor) : null,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.linear_scale_rounded, size: 14, color: primary),
              const SizedBox(width: 6),
              Text(
                "TRACKING TIMELINE",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (i) {
            final step = steps[i];
            final state = step["state"]!;
            final isLast = i == steps.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 36,
                    child: Column(
                      children: [
                        _timelineDot(state, dividerColor, primary),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: state == "upcoming"
                                  ? dividerColor
                                  : primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step["label"]!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: state == "upcoming"
                                  ? textMuted
                                  : textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            state == "completed"
                                ? "COMPLETED"
                                : state == "active"
                                ? "ACTIVE"
                                : "UPCOMING",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: state == "upcoming" ? textMuted : primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _timelineDot(String state, Color dividerColor, Color primary) {
    if (state == "completed") {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
        child: const Icon(Icons.check, color: Colors.white, size: 16),
      );
    } else if (state == "active") {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: primary,
          shape: BoxShape.circle,
          border: Border.all(color: primary.withOpacity(0.25), width: 4),
        ),
        child: const DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      );
    } else {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: dividerColor, width: 2),
        ),
        child: Icon(Icons.lock_outline, color: dividerColor, size: 14),
      );
    }
  }

  Widget _avatar(String initials, Color color) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: color,
      child: Text(
        initials,
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _badge(String title, String value, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            title == "PRIORITY" ? Icons.error_outline : Icons.circle,
            size: title == "PRIORITY" ? 14 : 8,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            "$title: $value",
            style: GoogleFonts.plusJakartaSans(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
