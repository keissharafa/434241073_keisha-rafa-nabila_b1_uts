import 'package:flutter/material.dart';
import '../../services/ticket_service.dart';

class TicketDetailPage extends StatefulWidget {
  final Map ticket;
  final Function(bool)? toggleTheme;

  const TicketDetailPage({
    super.key,
    required this.ticket,
    this.toggleTheme,
  });

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load comments: $e")),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send comment: $e")),
      );
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

  // 🗂️ Bangun timeline dari data tiket asli, bukan hardcoded
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

    final labels = [
      "Ticket Created",
      "Assigned to Helpdesk",
      "In Progress",
      "Resolved",
    ];

    int activeIndex = doneFlags.indexWhere((d) => !d);
    if (activeIndex == -1) activeIndex = labels.length;

    return List.generate(labels.length, (i) {
      final state = i < activeIndex
          ? "completed"
          : (i == activeIndex ? "active" : "upcoming");
      return {"label": labels[i], "state": state};
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor       = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final cardColor     = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary   = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF334155);
    final textMuted     = isDark ? const Color(0xFF64748B) : const Color(0xFF64748B);
    final inputBg       = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final inputBarBg    = isDark ? const Color(0xFF0F172A) : Colors.white;
    final bubbleAdminBg = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final bubbleAdminText = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final backIconColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final idBadgeBg     = isDark ? const Color(0xFF1D3461) : const Color(0xFFE0E7FF);
    final timelineBg    = cardColor;
    final dividerColor  = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    final status = (widget.ticket["status"] ?? "OPEN").toString();
    final priority = (widget.ticket["priority"] ??
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
                    icon: Icon(Icons.arrow_back, color: backIconColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      "Ticket Details",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: backIconColor),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: idBadgeBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.ticket["id"] ?? "#TK-0000",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Opened ${_timeAgo(widget.ticket["createdAt"])}",
                        style: TextStyle(fontSize: 12, color: textMuted),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // TITLE
                  Text(
                    widget.ticket["title"] ?? "Untitled Ticket",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 📄 DESCRIPTION CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.description_outlined,
                                size: 14, color: Color(0xFF2563EB)),
                            const SizedBox(width: 6),
                            Text(
                              "ORIGINAL REPORT",
                              style: TextStyle(
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
                          widget.ticket["description"] ?? "No description provided.",
                          style: TextStyle(
                            height: 1.6,
                            fontSize: 13,
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
                    dividerColor: dividerColor,
                  ),

                  const SizedBox(height: 16),

                  // STATUS & PRIORITY (data asli)
                  Row(
                    children: [
                      _badge(
                        "STATUS", status,
                        const Color(0xFF2563EB),
                        isDark ? const Color(0xFF1D3461) : const Color(0xFFEFF6FF),
                      ),
                      const SizedBox(width: 10),
                      _badge(
                        "PRIORITY", priority,
                        const Color(0xFFEF4444),
                        isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "CONVERSATION",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1,
                      color: textMuted,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 💬 CHAT (data asli dari ticket_comments)
                  if (isLoadingComments)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_comments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "Belum ada komentar. Mulai percakapan di bawah.",
                        style: TextStyle(color: textMuted, fontSize: 13),
                      ),
                    )
                  else
                    ..._comments.map((c) {
                      final senderRole = (c["sender_role"] ?? "user").toString();
                      final isUser = senderRole == "user";
                      final senderName = (c["sender_name"] ?? "Unknown").toString();
                      final initials = senderName.trim().isNotEmpty
                          ? senderName.trim().split(" ").map((w) => w[0]).take(2).join().toUpperCase()
                          : "U";
                      final avatarColor = isUser
                          ? const Color(0xFF6366F1)
                          : const Color(0xFFF59E0B);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment:
                              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                                    style: TextStyle(fontSize: 11, color: textMuted),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isUser
                                          ? const Color(0xFF2563EB)
                                          : bubbleAdminBg,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(isUser ? 16 : 4),
                                        topRight: Radius.circular(isUser ? 4 : 16),
                                        bottomLeft: const Radius.circular(16),
                                        bottomRight: const Radius.circular(16),
                                      ),
                                    ),
                                    child: Text(
                                      (c["message"] ?? "").toString(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.5,
                                        color: isUser ? Colors.white : bubbleAdminText,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: inputBarBg,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? const Color.fromRGBO(0, 0, 0, 0.3)
                        : const Color(0x0F000000),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: TextStyle(fontSize: 14, color: textPrimary),
                      decoration: InputDecoration(
                        hintText: "Add a comment...",
                        hintStyle: TextStyle(color: textMuted, fontSize: 14),
                        filled: true,
                        fillColor: inputBg,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
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
                  const SizedBox(width: 10),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
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
                            icon: const Icon(Icons.send_rounded,
                                color: Colors.white, size: 20),
                            onPressed: _sendComment,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🗂️ TRACKING TIMELINE (sekarang nerima steps dari luar, bukan hardcoded)
  Widget _buildTrackingTimeline({
    required List<Map<String, String>> steps,
    required Color cardColor,
    required Color textPrimary,
    required Color dividerColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.linear_scale_rounded,
                  size: 14, color: Color(0xFF2563EB)),
              const SizedBox(width: 6),
              const Text(
                "TRACKING TIMELINE",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: Color(0xFF94A3B8),
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
                        _timelineDot(state, dividerColor),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: state == "upcoming"
                                  ? dividerColor
                                  : const Color(0xFF2563EB),
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
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: state == "upcoming"
                                  ? const Color(0xFF94A3B8)
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
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: state == "upcoming"
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF2563EB),
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

  Widget _timelineDot(String state, Color dividerColor) {
    if (state == "completed") {
      return Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: Color(0xFF2563EB),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 16),
      );
    } else if (state == "active") {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFBFDBFE), width: 4),
        ),
        child: const DecoratedBox(
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
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
        child: const Icon(Icons.lock_outline, color: Color(0xFF94A3B8), size: 14),
      );
    }
  }

  Widget _avatar(String initials, Color color) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: color,
      child: Text(
        initials,
        style: const TextStyle(
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
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}