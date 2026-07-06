import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/ticket_service.dart';

class CreateTicketPage extends StatefulWidget {
  final Function(bool)? toggleTheme;

  const CreateTicketPage({super.key, this.toggleTheme});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  final TicketService _ticketService = TicketService();

  String selectedPriority = "Med";
  bool isSubmitting = false;

  File? _selectedFile;
  String? _fileName;
  bool _isImage = false;

  // ── STYLE GUIDE SEMANTIC COLORS ──
  static const _primary = Color(0xFF6C63FF);
  static const _danger = Color(0xFFF45B69);
  static const _warning = Color(0xFFFF9F43);
  static const _success = Color(0xFF21D07B);

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

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
    if (isSubmitting) return;
    setState(() => isSubmitting = true);

    try {
      String? attachmentUrl;

      if (_selectedFile != null) {
        final ext = _fileName?.split('.').last.toLowerCase() ?? 'bin';
        final fileNameToUpload =
            'ticket_${DateTime.now().millisecondsSinceEpoch}.$ext';

        await Supabase.instance.client.storage
            .from('attachments')
            .upload(fileNameToUpload, _selectedFile!);

        attachmentUrl = Supabase.instance.client.storage
            .from('attachments')
            .getPublicUrl(fileNameToUpload);
      }

      final insertedTicket = await _ticketService.createTicket(
        title: titleController.text.trim().isEmpty
            ? "Untitled Ticket"
            : titleController.text.trim(),
        // Kategori sudah dihapus dari sini agar sinkron dengan service
        description: descController.text.trim(),
        requestedPriority: selectedPriority.toUpperCase(),
        attachmentUrl: attachmentUrl,
      );

      if (context.mounted) {
        Navigator.pop(context, insertedTicket);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to submit ticket: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF14142B) : const Color(0xFFEDEFF7);
    final cardColor = isDark ? const Color(0xFF1F1B3A) : Colors.white;
    final textPrimary = isDark
        ? const Color(0xFFF1F1FB)
        : const Color(0xFF14142B);
    final textSecondary = isDark
        ? const Color(0xFFA0A0B8)
        : const Color(0xFF92929D);
    final fieldBg = isDark ? const Color(0xFF241F45) : const Color(0xFFF1E9FF);
    final hintColor = isDark
        ? const Color(0xFFA0A0B8)
        : const Color(0xFF92929D);
    final borderColor = isDark
        ? const Color(0xFF2E2A52)
        : const Color(0xFFF0F1F6);
    final labelColor = const Color(0xFF92929D);
    final navBg = isDark ? const Color(0xFF1F1B3A) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          decoration: BoxDecoration(
            color: navBg,
            border: Border(top: BorderSide(color: borderColor)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: isSubmitting ? null : _submitTicket,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
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
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.send_rounded, size: 18),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Max file size: 5MB. Photo or Document.",
                style: GoogleFonts.plusJakartaSans(
                  color: hintColor,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          color: const Color(0xFF14142B),
                          borderRadius: BorderRadius.circular(14),
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
                          color: _primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                "Create Ticket",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Tell us what's happening. Our digital concierge will prioritize your request immediately.",
                style: GoogleFonts.plusJakartaSans(
                  color: textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              _fieldLabel("SUBJECT"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: titleController,
                hint: "Brief summary of the issue",
                maxLines: 1,
                textPrimary: textPrimary,
                fieldBg: fieldBg,
                hintColor: hintColor,
              ),

              const SizedBox(height: 20),
              _fieldLabel("PRIORITY"),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: fieldBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: ["Low", "Med", "High"].map((priority) {
                    final isSelected = selectedPriority == priority;
                    Color selectedTextColor = priority == "High"
                        ? _danger
                        : (priority == "Med" ? _warning : _success);
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => selectedPriority = priority),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                      ? const Color(0xFF1F1B3A)
                                      : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              priority,
                              style: GoogleFonts.plusJakartaSans(
                                color: isSelected
                                    ? selectedTextColor
                                    : labelColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),
              _fieldLabel("DESCRIPTION"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: descController,
                hint: "Describe your problem in detail...",
                maxLines: 7,
                textPrimary: textPrimary,
                fieldBg: fieldBg,
                hintColor: hintColor,
              ),

              const SizedBox(height: 28),

              _fieldLabel("ATTACHMENT (OPTIONAL)"),
              const SizedBox(height: 8),

              if (_selectedFile != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: fieldBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _primary),
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
                          style: GoogleFonts.plusJakartaSans(color: _danger),
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
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: fieldBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 32,
                                color: hintColor,
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
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: fieldBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.upload_file_outlined,
                                size: 32,
                                color: hintColor,
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

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) => Text(
    label,
    style: GoogleFonts.plusJakartaSans(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF92929D),
      letterSpacing: 1.0,
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
    required Color textPrimary,
    required Color fieldBg,
    required Color hintColor,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.plusJakartaSans(fontSize: 15, color: textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(color: hintColor, fontSize: 14),
        filled: true,
        fillColor: fieldBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
