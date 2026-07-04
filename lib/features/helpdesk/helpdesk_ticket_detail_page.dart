import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
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

  bool isUpdating = false;
  bool isLoadingComments = true;

  List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();

    _selectedStatus = widget.ticket["status"] ?? "IN PROGRESS";

    const validStatuses = ["OPEN", "IN PROGRESS", "CLOSED"];
    if (!validStatuses.contains(_selectedStatus)) {
      _selectedStatus = "IN PROGRESS";
    }

    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final dbId = widget.ticket["dbId"];
    if (dbId == null) {
      setState(() => isLoadingComments = false);
      return;
    }

    try {
      final data = await _ticketService.getComments(
        ticketId: dbId is int ? dbId : int.parse(dbId.toString()),
      );

      if (!mounted) return;

      setState(() {
        _comments = data.map<Map<String, dynamic>>((c) {
          final isAdmin = c["is_admin"] ?? c["isAdmin"] ?? false;
          return {
            "sender": isAdmin ? "admin" : "user",
            "name":
                c["sender_name"] ?? c["name"] ?? (isAdmin ? "Admin" : "User"),
            "time": c["time"] ?? c["created_at"] ?? "",
            "message": c["message"] ?? "",
            "isAdmin": isAdmin,
          };
        }).toList();
        isLoadingComments = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingComments = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load comments: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _finishTicket() async {
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
      await _ticketService.updateTicket(
        id: dbId is int ? dbId : int.parse(dbId.toString()),
        status: "CLOSED",
        priority: widget.ticket["priority"] ?? "HIGH",
        assignedTo: widget.ticket["assignedTo"] ?? "Helpdesk",
      );

      if (!mounted) return;
      setState(() => _selectedStatus = "CLOSED");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text("Ticket closed successfully"),
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
        Navigator.pop(context, true);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to close ticket: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isUpdating = false);
      }
    }
  }

  // Fungsi untuk membuka link PDF / Dokumen di browser bawaan HP
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Could not open file")));
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
    final infoBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFEEF2FF);

    final finalPriority = widget.ticket["priority"] ?? "HIGH";
    final assignedTo = widget.ticket["assignedTo"] ?? "Helpdesk";

    final attachmentUrl = widget.ticket["attachment_url"];

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
                    widget.ticket["title"] ?? "Untitled Ticket",
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
                              "No description provided.",
                          style: TextStyle(
                            height: 1.6,
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // TAMPILKAN LAMPIRAN (FOTO ATAU DOKUMEN)
                  if (attachmentUrl != null &&
                      attachmentUrl.toString().isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      "Attachment",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final urlString = attachmentUrl.toString();
                        final lowerUrl = urlString.toLowerCase();
                        // Cek apakah url adalah gambar atau dokumen
                        final isImage =
                            lowerUrl.endsWith('.jpg') ||
                            lowerUrl.endsWith('.jpeg') ||
                            lowerUrl.endsWith('.png');

                        if (isImage) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              urlString,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: borderColor),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                            ),
                          );
                        } else {
                          // Jika dokumen (PDF, Doc, dll), berikan tombol untuk buka file
                          return GestureDetector(
                            onTap: () => _launchURL(urlString),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.insert_drive_file_outlined,
                                    color: Color(0xFF2563EB),
                                    size: 32,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Document File",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: textPrimary,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Tap to view or download document",
                                          style: TextStyle(
                                            color: textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.open_in_new,
                                    color: textSecondary,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],

                  const SizedBox(height: 20),

                  // STATUS
                  Text(
                    "Status",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: _statusBadgeBg(_selectedStatus),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedStatus == "CLOSED"
                              ? Icons.check_circle_outline
                              : Icons.autorenew,
                          size: 16,
                          color: _statusTextColor(_selectedStatus),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedStatus,
                          style: TextStyle(
                            color: _statusTextColor(_selectedStatus),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
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
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: infoBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                finalPriority,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ASSIGNED TO
                  Text(
                    "Assigned To",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: infoBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.support_agent_outlined,
                          size: 18,
                          color: Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          assignedTo,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // FINISH TICKET BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedStatus == "CLOSED"
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: (isUpdating || _selectedStatus == "CLOSED")
                          ? null
                          : _finishTicket,
                      child: isUpdating
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _selectedStatus == "CLOSED"
                                  ? "Ticket Closed"
                                  : "Finish Ticket",
                              style: const TextStyle(
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

                  if (isLoadingComments)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_comments.isEmpty)
                    Center(
                      child: Text(
                        "No comments yet.",
                        style: TextStyle(fontSize: 13, color: textSecondary),
                      ),
                    )
                  else
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
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: TextStyle(fontSize: 14, color: textPrimary),
                      decoration: InputDecoration(
                        hintText: "Add a comment...",
                        hintStyle: TextStyle(color: labelColor, fontSize: 14),
                        border: InputBorder.none,
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
                      onPressed: () async {
                        final text = _commentController.text.trim();
                        if (text.isEmpty) return;
                        final dbId = widget.ticket["dbId"];
                        if (dbId == null) return;
                        FocusScope.of(context).unfocus();
                        _commentController.clear();
                        try {
                          await _ticketService.addComment(
                            ticketId: dbId is int
                                ? dbId
                                : int.parse(dbId.toString()),
                            senderRole: "helpdesk",
                            senderName: "Helpdesk Agent",
                            message: text,
                          );
                          await _loadComments();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Failed: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
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

  Color _statusTextColor(String status) {
    switch (status) {
      case "OPEN":
        return const Color(0xFFEF4444);
      case "IN PROGRESS":
        return const Color(0xFF2563EB);
      case "CLOSED":
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF0F172A);
    }
  }

  Color _statusBadgeBg(String status) {
    switch (status) {
      case "OPEN":
        return const Color(0xFFFEE2E2);
      case "IN PROGRESS":
        return const Color(0xFFEFF6FF);
      case "CLOSED":
        return const Color(0xFFDCFCE7);
      default:
        return const Color(0xFFF1F5F9);
    }
  }
}
