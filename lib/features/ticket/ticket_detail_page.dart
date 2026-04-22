import 'package:flutter/material.dart';

class TicketDetailPage extends StatelessWidget {
  final Map ticket;
  final Function(bool)? toggleTheme;

  const TicketDetailPage({
    super.key,
    required this.ticket,
    this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 🎨 Dark mode tokens
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

    final comments = [
      {
        "sender": "admin",
        "name": "Sarah Jenkins",
        "initials": "SJ",
        "avatarColor": const Color(0xFFF59E0B),
        "message": "Hi Alex, I\'m checking your VPN issue right now. Are you seeing any specific error message when trying to connect?",
        "time": "10:45 AM"
      },
      {
        "sender": "user",
        "name": "Alex Johnson",
        "initials": "AJ",
        "avatarColor": const Color(0xFF6366F1),
        "message": "Yes, it shows connection timeout. I\'ve tried reconnecting multiple times but still can\'t access the VPN.",
        "time": "10:52 AM"
      },
      {
        "sender": "admin",
        "name": "Sarah Jenkins",
        "initials": "SJ",
        "avatarColor": const Color(0xFFF59E0B),
        "message": "Got it. This might be an issue with the VPN server. I\'ll escalate this to our network team and keep you updated.",
        "time": "11:05 AM"
      },
    ];

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
                  Expanded(
                    child: const Text(
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
                          ticket["id"] ?? "#TK-0000",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Opened 2h ago",
                        style: TextStyle(fontSize: 12, color: textMuted),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // TITLE
                  Text(
                    ticket["title"] ?? "VPN Access Issue",
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
                          ticket["description"] ?? "No description provided.",
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

                  // 🗂️ TRACKING TIMELINE
                  _buildTrackingTimeline(
                    cardColor: timelineBg,
                    textPrimary: textPrimary,
                    dividerColor: dividerColor,
                  ),

                  const SizedBox(height: 16),

                  // STATUS & PRIORITY
                  Row(
                    children: [
                      _badge(
                        "STATUS", "ACTIVE",
                        const Color(0xFF2563EB),
                        isDark ? const Color(0xFF1D3461) : const Color(0xFFEFF6FF),
                      ),
                      const SizedBox(width: 10),
                      _badge(
                        "PRIORITY", "URGENT",
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

                  // 💬 CHAT
                  ...comments.map((c) {
                    final isUser = c["sender"] == "user";
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: isUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isUser) ...[
                            _avatar(
                              c["initials"] as String,
                              c["avatarColor"] as Color,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Column(
                              crossAxisAlignment: isUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${c["name"]} • ${c["time"]}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: textMuted,
                                  ),
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
                                    c["message"] as String,
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
                            _avatar(
                              c["initials"] as String,
                              c["avatarColor"] as Color,
                            ),
                          ],
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            // ✍️ INPUT BAR
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
                      style: TextStyle(fontSize: 14, color: textPrimary),
                      decoration: InputDecoration(
                        hintText: "Add a comment...",
                        hintStyle: TextStyle(
                          color: textMuted,
                          fontSize: 14,
                        ),
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
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () {},
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

  // 🗂️ TRACKING TIMELINE
  Widget _buildTrackingTimeline({
    required Color cardColor,
    required Color textPrimary,
    required Color dividerColor,
  }) {
    final steps = [
      {"label": "Ticket Created",    "state": "completed"},
      {"label": "Assigned to Admin", "state": "completed"},
      {"label": "Waiting",           "state": "completed"},
      {"label": "In Progress",       "state": "active"},
      {"label": "Resolved",          "state": "upcoming"},
    ];

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
              Text(
                "TRACKING TIMELINE",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: dividerColor == const Color(0xFF334155)
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (i) {
            final step  = steps[i];
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
        child: Container(
          decoration: const BoxDecoration(
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
            style: TextStyle(
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