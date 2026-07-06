import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/ticket_service.dart';

class AdminTicketDetailPage extends StatefulWidget {
  final Map<String, dynamic> ticket;
  final Function(bool) toggleTheme;

  const AdminTicketDetailPage({
    super.key,
    required this.ticket,
    required this.toggleTheme,
  });

  @override
  State<AdminTicketDetailPage> createState() => _AdminTicketDetailPageState();
}

class _AdminTicketDetailPageState extends State<AdminTicketDetailPage> {
  final TicketService _ticketService = TicketService();
  final TextEditingController _commentController = TextEditingController();

  // Variabel untuk Attachment Gambar
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> _comments = [];
  bool _isLoadingComments = true;
  bool _isAssigning = false;
  bool _isSendingComment = false;

  List<String> _helpdeskAgents = [];
  bool _isLoadingAgents = true;
  String? _selectedHelpdesk;

  // 🔥 Tambahan Variabel untuk menyimpan URL Attachment 🔥
  String? _ticketAttachmentUrl;

  @override
  void initState() {
    super.initState();
    // Coba ambil dari parameter yang dipassing dulu (kalau ada)
    _ticketAttachmentUrl =
        widget.ticket["attachment_url"] ?? widget.ticket["attachmentUrl"];

    _fetchComments();
    _fetchHelpdeskAgents();

    // Tarik langsung URL gambar dari DB buat nambal error dari halaman sebelumnya
    _fetchTicketAttachment();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Fungsi tarikan ghaib biar gambar 100% muncul
  Future<void> _fetchTicketAttachment() async {
    try {
      final dbId = widget.ticket["dbId"];
      if (dbId == null) return;

      final response = await Supabase.instance.client
          .from('tickets')
          .select('attachment_url')
          .eq('id', dbId)
          .single();

      if (mounted && response['attachment_url'] != null) {
        setState(() {
          _ticketAttachmentUrl = response['attachment_url'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching ticket attachment: $e");
    }
  }

  // Fungsi ambil gambar dari galeri
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to pick image: $e")));
    }
  }

  Future<void> _fetchHelpdeskAgents() async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('full_name')
          .eq('role', 'helpdesk');

      final agents = (response as List)
          .map((e) => e['full_name'] as String)
          .toList();

      if (!mounted) return;
      setState(() {
        _helpdeskAgents = agents;
        _isLoadingAgents = false;
      });
    } catch (e) {
      debugPrint("Error fetching agents: $e");
      if (mounted) {
        setState(() => _isLoadingAgents = false);
      }
    }
  }

  Future<void> _fetchComments() async {
    try {
      final dbId = widget.ticket["dbId"];
      if (dbId == null) return;

      final data = await _ticketService.getComments(ticketId: dbId);
      if (!mounted) return;

      setState(() {
        _comments = data.map<Map<String, dynamic>>((c) {
          return {
            "sender_role": c["sender_role"] ?? "user",
            "sender_name": c["sender_name"] ?? "Unknown",
            "created_at": c["created_at"] ?? "",
            "message": c["message"] ?? "",
            "attachment_url": c["attachment_url"],
          };
        }).toList();

        _isLoadingComments = false;
      });
    } catch (e) {
      debugPrint("Error fetching comments: $e");
      if (mounted) setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    final dbId = widget.ticket["dbId"];

    if ((text.isEmpty && _selectedImage == null) ||
        dbId == null ||
        _isSendingComment)
      return;

    setState(() => _isSendingComment = true);
    FocusScope.of(context).unfocus();

    try {
      String? attachmentUrl;

      // 1. Upload Gambar ke Supabase Storage (Jika Ada)
      if (_selectedImage != null) {
        final fileExt = _selectedImage!.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = 'ticket_$dbId/$fileName';

        // Upload ke bucket 'attachments'
        await Supabase.instance.client.storage
            .from('attachments')
            .upload(filePath, _selectedImage!);

        // Dapatkan Public URL
        attachmentUrl = Supabase.instance.client.storage
            .from('attachments')
            .getPublicUrl(filePath);
      }

      // 2. Simpan Data ke Database
      await _ticketService.addComment(
        ticketId: dbId,
        senderRole: "admin",
        senderName: "System Admin",
        message: text.isEmpty ? "Sent an attachment" : text,
        attachmentUrl: attachmentUrl, // Mengirim URL gambar
      );

      _commentController.clear();
      setState(() {
        _selectedImage = null; // Hapus preview setelah terkirim
      });
      await _fetchComments();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to send: $e")));
    } finally {
      if (mounted) setState(() => _isSendingComment = false);
    }
  }

  Future<void> _assignTicket() async {
    if (_selectedHelpdesk == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a Helpdesk agent first.")),
      );
      return;
    }

    setState(() => _isAssigning = true);

    try {
      await _ticketService.updateTicket(
        id: widget.ticket["dbId"],
        priority: widget.ticket["priority"] ?? "LOW",
        assignedTo: _selectedHelpdesk!,
        status: "IN PROGRESS",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Ticket assigned! Status automatically changed to IN PROGRESS.",
          ),
          backgroundColor: Color(0xFF21D07B),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAssigning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to assign ticket: $e"),
          backgroundColor: const Color(0xFFF45B69),
        ),
      );
    }
  }

  // Buka link PDF / Dokumen di browser dengan aman
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Could not open file")));
      }
    }
  }

  String _formatDate(dynamic rawDate) {
    if (rawDate == null || rawDate.toString().isEmpty) return "";
    try {
      final dt = DateTime.parse(rawDate.toString()).toLocal();
      return "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return "";
    }
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const primary = Color(0xFF6C63FF);
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
    final fieldBg = isDark ? const Color(0xFF14142B) : const Color(0xFFF0F1F6);
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.25)
        : const Color(0xFF6C63FF).withOpacity(0.06);

    final status = (widget.ticket["status"] ?? "OPEN").toString().toUpperCase();
    final isClosed = status == "CLOSED" || status == "RESOLVED";

    // 🔥 Gunakan nilai _ticketAttachmentUrl yang ditarik dari fungsi _fetchTicketAttachment
    final attachmentUrl = _ticketAttachmentUrl;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.ticket["id"] ?? "Ticket Detail",
          style: GoogleFonts.plusJakartaSans(
            color: textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF2A2456)
                                    : const Color(0xFFEDEBFF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.ticket["category"] ??
                                    "Technical Support",
                                style: GoogleFonts.plusJakartaSans(
                                  color: primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: _priorityColor(
                                    widget.ticket["priority"] ?? "LOW",
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.ticket["priority"] ?? "LOW",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _priorityColor(
                                      widget.ticket["priority"] ?? "LOW",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.ticket["title"] ?? "Untitled Ticket",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.ticket["description"] ??
                              "No description provided.",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: textSecondary,
                            height: 1.5,
                          ),
                        ),

                        // Render Attachment Utama
                        if (attachmentUrl != null &&
                            attachmentUrl.toString().isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text(
                            "Attachment",
                            style: GoogleFonts.plusJakartaSans(
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
                              // Gunakan .contains() agar kebal query parameter dari Supabase
                              final isImage =
                                  lowerUrl.contains('.jpg') ||
                                  lowerUrl.contains('.jpeg') ||
                                  lowerUrl.contains('.png');

                              if (isImage) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    urlString,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            height: 200,
                                            decoration: BoxDecoration(
                                              color: fieldBg,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                color: primary,
                                              ),
                                            ),
                                          );
                                        },
                                  ),
                                );
                              } else {
                                return GestureDetector(
                                  onTap: () => _launchURL(urlString),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: fieldBg,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: borderColor),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.insert_drive_file_outlined,
                                          color: primary,
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
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: textPrimary,
                                                      fontSize: 14,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Tap to view or download document",
                                                style:
                                                    GoogleFonts.plusJakartaSans(
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
                        Divider(height: 1, color: borderColor),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: primary.withOpacity(0.1),
                              child: const Icon(
                                Icons.person,
                                size: 16,
                                color: primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Reported by",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: textSecondary,
                                    ),
                                  ),
                                  Text(
                                    widget.ticket["reporter"] ?? "Unknown",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Current Status",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: textSecondary,
                                  ),
                                ),
                                Text(
                                  status,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: status == "OPEN"
                                        ? const Color(0xFFF45B69)
                                        : status == "IN PROGRESS"
                                        ? primary
                                        : const Color(0xFF21D07B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Assign Helpdesk Box
                  if (!isClosed)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: primary.withOpacity(0.3)),
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
                              const Icon(
                                Icons.assignment_ind_outlined,
                                color: primary,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Assign Helpdesk",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Assigning a helpdesk agent will automatically change the status to IN PROGRESS.",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: fieldBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: _isLoadingAgents
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: primary,
                                        ),
                                      ),
                                    ),
                                  )
                                : DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedHelpdesk,
                                      hint: Text(
                                        _helpdeskAgents.isEmpty
                                            ? "No agent available"
                                            : "Select Helpdesk Agent",
                                        style: GoogleFonts.plusJakartaSans(
                                          color: textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                      isExpanded: true,
                                      dropdownColor: cardColor,
                                      icon: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: textSecondary,
                                      ),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        color: textPrimary,
                                      ),
                                      items: _helpdeskAgents
                                          .map(
                                            (agent) => DropdownMenuItem(
                                              value: agent,
                                              child: Text(agent),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) =>
                                          setState(() => _selectedHelpdesk = v),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _isAssigning || _helpdeskAgents.isEmpty
                                  ? null
                                  : _assignTicket,
                              child: _isAssigning
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      "Assign Ticket",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (!isClosed) const SizedBox(height: 24),

                  Text(
                    "Activity & Comments",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_isLoadingComments)
                    const Center(
                      child: CircularProgressIndicator(color: primary),
                    )
                  else if (_comments.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          "No comments yet.",
                          style: GoogleFonts.plusJakartaSans(
                            color: textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._comments.map((c) {
                      final isMe = c["sender_role"] == "admin";
                      final attachment = c["attachment_url"] as String?;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: isMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (!isMe) ...[
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: borderColor,
                                child: Text(
                                  (c["sender_name"] ?? "?")
                                      .toString()[0]
                                      .toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Flexible(
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        isMe
                                            ? "You"
                                            : (c["sender_name"] ?? "User"),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _formatDate(c["created_at"]),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isMe ? primary : cardColor,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(16),
                                        topRight: const Radius.circular(16),
                                        bottomLeft: Radius.circular(
                                          isMe ? 16 : 4,
                                        ),
                                        bottomRight: Radius.circular(
                                          isMe ? 4 : 16,
                                        ),
                                      ),
                                      border: isMe
                                          ? null
                                          : Border.all(color: borderColor),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: isMe
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        // RENDER GAMBAR KALAU ADA
                                        if (attachment != null &&
                                            attachment.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 8.0,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                attachment,
                                                width: 200,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (ctx, err, stack) =>
                                                        const Icon(
                                                          Icons.broken_image,
                                                          color: Colors.grey,
                                                        ),
                                              ),
                                            ),
                                          ),
                                        // RENDER TEKS
                                        if (c["message"] != null &&
                                            c["message"].toString().isNotEmpty)
                                          Text(
                                            c["message"].toString(),
                                            style: GoogleFonts.plusJakartaSans(
                                              color: isMe
                                                  ? Colors.white
                                                  : textPrimary,
                                              fontSize: 13,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cardColor,
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Preview Gambar sebelum dikirim
                    if (_selectedImage != null)
                      Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            right: -10,
                            top: -10,
                            child: IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () =>
                                  setState(() => _selectedImage = null),
                            ),
                          ),
                        ],
                      ),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: "Write an internal note...",
                              hintStyle: GoogleFonts.plusJakartaSans(
                                color: textSecondary,
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
                              // TOMBOL CLIP DI SINI
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _selectedImage != null
                                      ? Icons.image
                                      : Icons.attach_file,
                                  color: _selectedImage != null
                                      ? primary
                                      : textSecondary,
                                  size: 20,
                                ),
                                onPressed: _pickImage,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _isSendingComment ? null : _sendComment,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: primary,
                              shape: BoxShape.circle,
                            ),
                            child: _isSendingComment
                                ? const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ],
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
}
