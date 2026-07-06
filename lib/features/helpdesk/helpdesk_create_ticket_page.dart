import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/ticket_service.dart';

class HelpdeskCreateTicketPage extends StatefulWidget {
  final Function(bool) toggleTheme;

  const HelpdeskCreateTicketPage({super.key, required this.toggleTheme});

  @override
  State<HelpdeskCreateTicketPage> createState() =>
      _HelpdeskCreateTicketPageState();
}

class _HelpdeskCreateTicketPageState extends State<HelpdeskCreateTicketPage> {
  final TicketService _ticketService = TicketService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String _selectedPriority = "MEDIUM";
  bool _isLoading = false;

  File? _selectedFile;
  String? _fileName;
  bool _isImage = false;

  final List<String> _priorities = ["LOW", "MEDIUM", "HIGH", "URGENT"];

  // ---- Style guide constants ----
  static const _bgLight = Color(0xFFEDEFF7);
  static const _surfaceLight = Color(0xFFFFFFFF);
  static const _primary = Color(0xFF6C63FF);
  static const _textPrimaryLight = Color(0xFF14142B);
  static const _textSecondaryLight = Color(0xFF92929D);
  static const _fieldBgLight = Color(0xFFF1E9FF);
  static const _payIcon = Color(0xFF8B5CF6);
  static const _success = Color(0xFF21D07B);
  static const _warning = Color(0xFFFF9F43);
  static const _danger = Color(0xFFF45B69);

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedFile = File(pickedFile.path);
          _fileName = pickedFile.name;
          _isImage = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to pick image: $e")));
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
          _isImage = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to pick document: $e")));
    }
  }

  Future<void> _submitTicket() async {
    if (_titleController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Title and Description cannot be empty!"),
          backgroundColor: _danger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? attachmentUrl;

      // Upload file jika ada attachment yang dipilih
      if (_selectedFile != null) {
        final ext = _fileName?.split('.').last.toLowerCase() ?? 'bin';
        final fileNameToUpload =
            'ticket_onbehalf_${DateTime.now().millisecondsSinceEpoch}.$ext';

        await Supabase.instance.client.storage
            .from('attachments')
            .upload(fileNameToUpload, _selectedFile!);

        attachmentUrl = Supabase.instance.client.storage
            .from('attachments')
            .getPublicUrl(fileNameToUpload);
      }

      await _ticketService.createTicket(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        requestedPriority: _selectedPriority,
        attachmentUrl: attachmentUrl, // Kirim URL attachment ke database
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text("Ticket created successfully on behalf of user"),
            ],
          ),
          backgroundColor: _success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: _danger),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Color _priorityColor(String p) {
    switch (p) {
      case "URGENT":
        return const Color(0xFFE0374B);
      case "HIGH":
        return _danger;
      case "MEDIUM":
        return _warning;
      case "LOW":
        return _success;
      default:
        return _textSecondaryLight;
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
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.3)
        : const Color(0xFF6C63FF).withOpacity(0.07);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
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
                      "Create Ticket (On Behalf)",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TICKET TITLE",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      style: GoogleFonts.plusJakartaSans(
                        color: textPrimary,
                        fontSize: 15,
                      ),
                      decoration: _inputDecoration(
                        fieldBg,
                        "E.g., Printer Error in Floor 3",
                      ),
                    ),
                    const SizedBox(height: 22),

                    Text(
                      "PRIORITY",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: fieldBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPriority,
                          isExpanded: true,
                          dropdownColor: cardColor,
                          borderRadius: BorderRadius.circular(14),
                          style: GoogleFonts.plusJakartaSans(
                            color: textPrimary,
                            fontSize: 15,
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: _payIcon,
                          ),
                          items: _priorities
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: _priorityColor(p),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(p),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedPriority = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    Text(
                      "DESCRIPTION",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descController,
                      maxLines: 5,
                      style: GoogleFonts.plusJakartaSans(
                        color: textPrimary,
                        fontSize: 15,
                      ),
                      decoration: _inputDecoration(
                        fieldBg,
                        "Describe the issue reported by the user...",
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ---- BAGIAN ATTACHMENT ----
                    Text(
                      "ATTACHMENT (OPTIONAL)",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (_selectedFile != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: fieldBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            if (_isImage)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _selectedFile!,
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              Column(
                                children: [
                                  const Icon(
                                    Icons.insert_drive_file,
                                    size: 48,
                                    color: _primary,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _fileName ?? "Document Selected",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: () => setState(() {
                                _selectedFile = null;
                                _fileName = null;
                                _isImage = false;
                              }),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: _danger,
                                size: 18,
                              ),
                              label: Text(
                                "Remove Attachment",
                                style: GoogleFonts.plusJakartaSans(
                                  color: _danger,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: fieldBg,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 32,
                                      color: textSecondary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Upload Photo",
                                      style: GoogleFonts.plusJakartaSans(
                                        color: textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickDocument,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: fieldBg,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.upload_file_outlined,
                                      size: 32,
                                      color: textSecondary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Upload File",
                                      style: GoogleFonts.plusJakartaSans(
                                        color: textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 8),
                    Text(
                      "Max file size: 5MB. Photo or Document.",
                      style: GoogleFonts.plusJakartaSans(
                        color: textSecondary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 36),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: _isLoading ? null : _submitTicket,
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Submit Ticket",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.send_rounded, size: 18),
                                ],
                              ),
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

  InputDecoration _inputDecoration(Color fill, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(
        color: _textSecondaryLight,
        fontSize: 14,
      ),
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
    );
  }
}
