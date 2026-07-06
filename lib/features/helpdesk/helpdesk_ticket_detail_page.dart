import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
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

  // Variabel untuk Upload Gambar
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  String _selectedStatus = "IN PROGRESS";
  bool isUpdating = false;
  bool isLoadingComments = true;
  bool _isSendingComment = false;

  List<Map<String, dynamic>> _comments = [];

  // ---- Style guide constants ----
  static const _bgLight = Color(0xFFEDEFF7);
  static const _surfaceLight = Color(0xFFFFFFFF);
  static const _primary = Color(0xFF6C63FF);
  static const _textPrimaryLight = Color(0xFF14142B);
  static const _textSecondaryLight = Color(0xFF92929D);
  static const _fieldBgLight = Color(0xFFF1E9FF); // pastel "Pay" category
  static const _payIcon = Color(0xFF8B5CF6);
  static const _success = Color(0xFF21D07B);
  static const _successBg = Color(0xFFE3FAEC);
  static const _warning = Color(0xFFFF9F43);
  static const _danger = Color(0xFFF45B69);
  static const _dangerBg = Color(0xFFFCE9EB);

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
        // 🔥 FIX LOGIKA MAPPING DATA DARI DATABASE 🔥
        _comments = data.map<Map<String, dynamic>>((c) {
          return {
            "sender_role": c["sender_role"] ?? "user",
            "sender_name": c["sender_name"] ?? "Unknown",
            "created_at": c["created_at"] ?? "",
            "message": c["message"] ?? "",
            "attachment_url": c["attachment_url"],
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

      // Upload Gambar ke Supabase Storage (Jika Ada)
      if (_selectedImage != null) {
        final fileExt = _selectedImage!.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = 'ticket_$dbId/$fileName';

        await Supabase.instance.client.storage
            .from('attachments')
            .upload(filePath, _selectedImage!);

        attachmentUrl = Supabase.instance.client.storage
            .from('attachments')
            .getPublicUrl(filePath);
      }

      await _ticketService.addComment(
        ticketId: dbId is int ? dbId : int.parse(dbId.toString()),
        senderRole: "helpdesk",
        senderName: "Helpdesk Agent", // Bisa disesuaikan dari SharedPreferences
        message: text.isEmpty ? "Sent an attachment" : text,
        attachmentUrl: attachmentUrl,
      );

      _commentController.clear();
      setState(() {
        _selectedImage = null; // Hapus preview setelah terkirim
      });
      await _loadComments();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to send: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSendingComment = false);
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
          backgroundColor: _success,
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

  // Fungsi formatter tanggal
  String _formatDate(dynamic rawDate) {
    if (rawDate == null || rawDate.toString().isEmpty) return "";
    try {
      final dt = DateTime.parse(rawDate.toString()).toLocal();
      return "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return "";
    }
  }

  // Buka link PDF / Dokumen di browser
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF14142B) : _bgLight;
    final cardColor = isDark ? const Color(0xFF1F1F3A) : _surfaceLight;
    final textPrimary = isDark ? const Color(0xFFF4F4FB) : _textPrimaryLight;
    final textSecondary = isDark
        ? const Color(0xFFA0A0B8)
        : _textSecondaryLight;
    final fieldBg = isDark ? const Color(0xFF2A2A55) : _fieldBgLight;
    final infoBg = isDark ? const Color(0xFF2A2A55) : _fieldBgLight;
    final inputBarBg = isDark ? const Color(0xFF1F1F3A) : _surfaceLight;
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.3)
        : const Color(0xFF6C63FF).withOpacity(0.07);

    final finalPriority = widget.ticket["priority"] ?? "HIGH";
    final assignedTo = widget.ticket["assignedTo"] ?? "Helpdesk";

    final attachmentUrl = widget.ticket["attachment_url"];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ---- Top App Bar (minimal, no elevation, nyatu background) ----
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: _primary,
                        size: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Ticket Details",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.more_vert_rounded,
                      color: textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                children: [
                  // ID + TITLE
                  Text(
                    widget.ticket["id"] ?? "#TK-8821",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.ticket["title"] ?? "Untitled Ticket",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                      height: 1.3,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ORIGINAL REPORT
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          blurRadius: 24,
                          offset: const Offset(0, 8),
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
                              color: textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "ORIGINAL REPORT",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: textSecondary,
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
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // TAMPILKAN LAMPIRAN (FOTO ATAU DOKUMEN UTAMA TIKET)
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
                        final isImage =
                            lowerUrl.contains('.jpg') ||
                            lowerUrl.contains('.jpeg') ||
                            lowerUrl.contains('.png');

                        if (isImage) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(18),
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
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: [
                                          BoxShadow(
                                            color: shadowColor,
                                            blurRadius: 24,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: _primary,
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
                                color: cardColor,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: shadowColor,
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: fieldBg,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.insert_drive_file_outlined,
                                      color: _payIcon,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Document File",
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.bold,
                                            color: textPrimary,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Tap to view or download document",
                                          style: GoogleFonts.plusJakartaSans(
                                            color: textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.open_in_new_rounded,
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
                    style: GoogleFonts.plusJakartaSans(
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
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: _statusBadgeBg(_selectedStatus),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedStatus == "CLOSED"
                              ? Icons.check_circle_outline_rounded
                              : Icons.autorenew_rounded,
                          size: 16,
                          color: _statusTextColor(_selectedStatus),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedStatus,
                          style: GoogleFonts.plusJakartaSans(
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
                              style: GoogleFonts.plusJakartaSans(
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
                                color: _dangerBg,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                widget.ticket["requestedPriority"] ?? "-",
                                style: GoogleFonts.plusJakartaSans(
                                  color: _danger,
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
                              style: GoogleFonts.plusJakartaSans(
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
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                finalPriority,
                                style: GoogleFonts.plusJakartaSans(
                                  color: isDark ? textPrimary : _payIcon,
                                  fontWeight: FontWeight.w700,
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
                    style: GoogleFonts.plusJakartaSans(
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
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.support_agent_outlined,
                            size: 17,
                            color: _payIcon,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          assignedTo,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // FINISH TICKET BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedStatus == "CLOSED"
                            ? (isDark
                                  ? const Color(0xFF3A3A5C)
                                  : const Color(0xFFD8DAE8))
                            : _success,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
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
                              style: GoogleFonts.plusJakartaSans(
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
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (isLoadingComments)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(color: _primary),
                      ),
                    )
                  else if (_comments.isEmpty)
                    Center(
                      child: Text(
                        "No comments yet.",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: textSecondary,
                        ),
                      ),
                    )
                  else
                    ..._comments.map(
                      (c) => _buildChatBubble(
                        c,
                        isDark,
                        cardColor,
                        fieldBg,
                        textPrimary,
                        textSecondary,
                      ),
                    ),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            // COMMENT INPUT BAR DENGAN ATTACHMENT
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: inputBarBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Preview Gambar
                  if (_selectedImage != null)
                    Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
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
                            icon: const Icon(Icons.cancel, color: _danger),
                            onPressed: () =>
                                setState(() => _selectedImage = null),
                          ),
                        ),
                      ],
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: fieldBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextField(
                            controller: _commentController,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: "Add a comment...",
                              hintStyle: GoogleFonts.plusJakartaSans(
                                color: textSecondary,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _selectedImage != null
                                      ? Icons.image_rounded
                                      : Icons.attach_file_rounded,
                                  color: _selectedImage != null
                                      ? _primary
                                      : textSecondary,
                                  size: 20,
                                ),
                                onPressed: _pickImage,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _isSendingComment ? null : _sendComment,
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: _primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _primary.withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: _isSendingComment
                              ? const Padding(
                                  padding: EdgeInsets.all(13.0),
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
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(
    Map<String, dynamic> c,
    bool isDark,
    Color cardColor,
    Color fieldBg,
    Color textPrimary,
    Color textSecondary,
  ) {
    // 🔥 LOGIKA KANAN-KIRI FIX 🔥
    final senderRole = (c["sender_role"] ?? "user").toString();
    final isMe = senderRole == "helpdesk";

    final attachment = c["attachment_url"] as String?;
    final senderName = c["sender_name"] ?? "Unknown";
    final timeStr = _formatDate(c["created_at"]);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[_avatar(false), const SizedBox(width: 10)],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? _primary : fieldBg,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isMe ? 18 : 4),
                      topRight: Radius.circular(isMe ? 4 : 18),
                      bottomLeft: const Radius.circular(18),
                      bottomRight: const Radius.circular(18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      // RENDER GAMBAR KALAU ADA
                      if (attachment != null && attachment.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              attachment,
                              width: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => const Icon(
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
                            fontSize: 14,
                            height: 1.5,
                            color: isMe ? Colors.white : textPrimary,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "$senderName • $timeStr",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[const SizedBox(width: 10), _avatar(true)],
        ],
      ),
    );
  }

  Widget _avatar(bool isMe) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: isMe ? _primary : _warning,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isMe ? Icons.support_agent_rounded : Icons.person_rounded,
        color: Colors.white,
        size: 17,
      ),
    );
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case "OPEN":
        return _danger;
      case "IN PROGRESS":
        return _primary;
      case "CLOSED":
        return _success;
      default:
        return _textPrimaryLight;
    }
  }

  Color _statusBadgeBg(String status) {
    switch (status) {
      case "OPEN":
        return _dangerBg;
      case "IN PROGRESS":
        return const Color(0xFFEEECFF);
      case "CLOSED":
        return _successBg;
      default:
        return const Color(0xFFF0F1F6);
    }
  }
}
