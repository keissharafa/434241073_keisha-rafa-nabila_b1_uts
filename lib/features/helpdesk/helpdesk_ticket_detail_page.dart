import 'package:flutter/material.dart';
import '../../services/ticket_service.dart';

class HelpdeskTicketDetailPage extends StatefulWidget {
  final Map<String, dynamic> ticket;
  final Function(bool) toggleTheme;

  const HelpdeskTicketDetailPage({
    super.key,
    required this.ticket,
    required this.toggleTheme,
  });

  @override
  State<HelpdeskTicketDetailPage> createState() =>
      _HelpdeskTicketDetailPageState();
}

class _HelpdeskTicketDetailPageState extends State<HelpdeskTicketDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final TicketService _ticketService = TicketService();

  String _selectedStatus = "IN PROGRESS";
  String _selectedFinalPriority = "HIGH";
  String _selectedAssignedTo = "IT Support";

  bool isUpdating = false;

  final List<String> _statusOptions = [
    "OPEN",
    "IN PROGRESS",
    "PENDING",
    "RESOLVED",
  ];

  final List<String> _priorityOptions = ["LOW", "MED", "HIGH", "URGENT"];

  final List<String> _assignedToOptions = [
    "IT Support",
    "Network Team",
    "DevOps Team",
  ];

  String _suggestTeamFromCategory(String? category) {
    if (category == null) return "IT Support";

    final lower = category.toLowerCase();

    if (lower.contains("network")) return "Network Team";
    if (lower.contains("software")) return "DevOps Team";
    if (lower.contains("hardware")) return "IT Support";
    if (lower.contains("technical")) return "IT Support";

    return "IT Support";
  }

  final List<Map<String, dynamic>> _comments = [
    {
      "sender": "user",
      "name": "Sarah Chen",
      "time": "10:42 AM",
      "message":
          "Could you check if the Redis cache is being purged correctly? We noticed some stale data logs.",
      "isAdmin": false,
    },
    {
      "sender": "admin",
      "name": "You (Admin)",
      "time": "10:45 AM",
      "message":
          "Checking the Redis cluster status now. It seems memory usage spiked exactly at the deployment time.",
      "isAdmin": true,
    },
    {
      "sender": "user",
      "name": "Sarah Chen",
      "time": "10:48 AM",
      "message":
          "Understood. I've paused the auto-scaling group to prevent further degradation while you investigate.",
      "isAdmin": false,
    },
  ];

  @override
  void initState() {
    super.initState();

    _selectedStatus = widget.ticket["status"] ?? "IN PROGRESS";
    _selectedFinalPriority = widget.ticket["priority"] ?? "HIGH";

    final suggested = _suggestTeamFromCategory(widget.ticket["category"]);
    _selectedAssignedTo = widget.ticket["assignedTo"] ?? suggested;

    if (!_statusOptions.contains(_selectedStatus)) {
      _selectedStatus = "IN PROGRESS";
    }

    if (!_priorityOptions.contains(_selectedFinalPriority)) {
      _selectedFinalPriority = "HIGH";
    }

    if (!_assignedToOptions.contains(_selectedAssignedTo)) {
      _selectedAssignedTo = "IT Support";
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _updateTicketToSupabase() async {
    if (isUpdating) return;

    final dbId = widget.ticket["dbId"];

    if (dbId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update ticket: missing database ID"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isUpdating = true);

    try {
      final updatedTicket = await _ticketService.updateTicket(
        id: dbId is int ? dbId : int.parse(dbId.toString()),
        status: _selectedStatus,
        priority: _selectedFinalPriority,
        assignedTo: _selectedAssignedTo,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text("Ticket updated successfully"),
            ],
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(milliseconds: 1200),
        ),
      );

      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        Navigator.pop(context, updatedTicket);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update ticket: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isUpdating = false);
      }
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
    final textSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final labelColor = const Color(0xFF94A3B8);
    final dropdownBg = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFEEF2FF);

    final suggestedTeam = _suggestTeamFromCategory(widget.ticket["category"]);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF2563EB),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      "Ticket Details",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF1E293B),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                children: [
                  // ID + TITLE
                  Text(
                    widget.ticket["id"] ?? "#TK-8821",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.ticket["title"] ??
                        "I can’t log in on the mobile app",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                      height: 1.3,
                      letterSpacing: -0.4,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ORIGINAL REPORT
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
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 14,
                              color: labelColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "ORIGINAL REPORT",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: labelColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.ticket["description"] ??
                              "I’m experiencing delays when making payments in the app. "
                                  "Sometimes the payment takes too long to process or fails completely. "
                                  "This started happening recently after the latest update.",
                          style: TextStyle(
                            height: 1.6,
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // STATUS DROPDOWN
                  Text(
                    "Status",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    value: _selectedStatus,
                    items: _statusOptions,
                    bg: dropdownBg,
                    textColor: _statusTextColor(_selectedStatus),
                    fontWeight: FontWeight.bold,
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _selectedStatus = v);
                    },
                  ),

                  const SizedBox(height: 16),

                  // PRIORITY ROW
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Requested Priority",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.ticket["requestedPriority"] ?? "-",
                                style: const TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Final Priority",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildDropdown(
                              value: _selectedFinalPriority,
                              items: _priorityOptions,
                              bg: dropdownBg,
                              textColor: textPrimary,
                              fontWeight: FontWeight.w600,
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() => _selectedFinalPriority = v);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // CATEGORY + SUGGESTED ROLE
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "CATEGORY",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: labelColor,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.ticket["category"] ??
                                    "Technical Support",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 36, color: borderColor),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "SUGGESTED ROLE",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: labelColor,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  suggestedTeam,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ASSIGNED TO
                  Row(
                    children: [
                      Text(
                        "Assigned To",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_selectedAssignedTo == suggestedTeam)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Auto-suggested",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildDropdownWithIcon(
                    value: _selectedAssignedTo,
                    items: _assignedToOptions,
                    bg: dropdownBg,
                    textColor: textPrimary,
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _selectedAssignedTo = v);
                    },
                  ),

                  const SizedBox(height: 20),

                  // UPDATE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isUpdating ? null : _updateTicketToSupabase,
                      child: isUpdating
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Update Ticket",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Center(
                    child: Text(
                      "CONVERSATION THREAD",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: labelColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ..._comments.map(
                    (c) =>
                        _buildChatBubble(c, isDark, cardColor, textSecondary),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            // COMMENT INPUT
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Icon(Icons.add, color: labelColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: TextStyle(fontSize: 14, color: textPrimary),
                      decoration: InputDecoration(
                        hintText: "Add a comment...",
                        hintStyle: TextStyle(color: labelColor, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (_commentController.text.trim().isEmpty) return;

                        setState(() {
                          _comments.add({
                            "sender": "admin",
                            "name": "You (Admin)",
                            "time": TimeOfDay.now().format(context),
                            "message": _commentController.text.trim(),
                            "isAdmin": true,
                          });
                          _commentController.clear();
                        });
                      },
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
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

  Widget _buildChatBubble(
    Map<String, dynamic> c,
    bool isDark,
    Color cardColor,
    Color textSecondary,
  ) {
    final isAdmin = c["isAdmin"] as bool;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isAdmin
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isAdmin) ...[_avatar(false), const SizedBox(width: 10)],
          Flexible(
            child: Column(
              crossAxisAlignment: isAdmin
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isAdmin
                        ? const Color(0xFF2563EB)
                        : (isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFEEF2FF)),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isAdmin ? 16 : 4),
                      topRight: Radius.circular(isAdmin ? 4 : 16),
                      bottomLeft: const Radius.circular(16),
                      bottomRight: const Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    c["message"],
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isAdmin
                          ? Colors.white
                          : (isDark
                                ? const Color(0xFFF1F5F9)
                                : const Color(0xFF1E293B)),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${c["name"]} • ${c["time"]}",
                  style: TextStyle(fontSize: 11, color: textSecondary),
                ),
              ],
            ),
          ),
          if (isAdmin) ...[const SizedBox(width: 10), _avatar(true)],
        ],
      ),
    );
  }

  Widget _avatar(bool isAdmin) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isAdmin ? const Color(0xFF1E293B) : const Color(0xFFF59E0B),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isAdmin ? Icons.person : Icons.support_agent,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Color bg,
    required Color textColor,
    required FontWeight fontWeight,
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
            color: Color(0xFF475569),
          ),
          dropdownColor: bg,
          borderRadius: BorderRadius.circular(12),
          style: TextStyle(
            fontSize: 14,
            fontWeight: fontWeight,
            color: textColor,
          ),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDropdownWithIcon({
    required String value,
    required List<String> items,
    required Color bg,
    required Color textColor,
    required ValueChanged<String?> onChanged,
  }) {
    IconData teamIcon(String team) {
      switch (team) {
        case "Network Team":
          return Icons.router_outlined;
        case "DevOps Team":
          return Icons.cloud_outlined;
        default:
          return Icons.support_agent_outlined;
      }
    }

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
            color: Color(0xFF475569),
          ),
          dropdownColor: bg,
          borderRadius: BorderRadius.circular(12),
          selectedItemBuilder: (context) {
            return items.map((item) {
              return Row(
                children: [
                  Icon(
                    teamIcon(item),
                    size: 18,
                    color: const Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              );
            }).toList();
          },
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Row(
                children: [
                  Icon(
                    teamIcon(item),
                    size: 18,
                    color: const Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case "OPEN":
        return const Color(0xFFEF4444);
      case "IN PROGRESS":
        return const Color(0xFF2563EB);
      case "PENDING":
        return const Color(0xFFF97316);
      case "RESOLVED":
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF0F172A);
    }
  }
}
