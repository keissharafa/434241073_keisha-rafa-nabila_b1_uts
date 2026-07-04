import 'dart:io';
import 'package:flutter/material.dart';
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
        category: "General",
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

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark
        ? const Color(0xFFF1F5F9)
        : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : Colors.grey[500]!;
    final fieldBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF);
    final hintColor = isDark ? const Color(0xFF64748B) : Colors.grey[400]!;
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final labelColor = const Color(0xFF94A3B8);
    final navBg = isDark ? const Color(0xFF1E293B) : Colors.white;

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
                    backgroundColor: const Color(0xFF2563EB),
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
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Submit Ticket",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.send_rounded, size: 18),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Max file size: 5MB. Photo or Document.",
                style: TextStyle(
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
                      const Text(
                        "Concierge",
                        style: TextStyle(
                          color: Color(0xFF2563EB),
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
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Tell us what's happening. Our digital concierge will prioritize your request immediately.",
                style: TextStyle(
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
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: ["Low", "Med", "High"].map((priority) {
                    final isSelected = selectedPriority == priority;
                    Color selectedTextColor = priority == "High"
                        ? const Color(0xFFEF4444)
                        : (priority == "Med"
                              ? const Color(0xFFF97316)
                              : const Color(0xFF16A34A));
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => selectedPriority = priority),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                      ? const Color(0xFF334155)
                                      : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              priority,
                              style: TextStyle(
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
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF2563EB)),
                  ),
                  child: Column(
                    children: [
                      if (_isImage)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
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
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _fileName ?? "Document Selected",
                              style: TextStyle(
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
                          color: Colors.red,
                          size: 18,
                        ),
                        label: const Text(
                          "Remove Attachment",
                          style: TextStyle(color: Colors.red),
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
                            borderRadius: BorderRadius.circular(14),
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
                                style: TextStyle(
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
                            borderRadius: BorderRadius.circular(14),
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
                                style: TextStyle(
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
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: Color(0xFF94A3B8),
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
      style: TextStyle(fontSize: 15, color: textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor, fontSize: 14),
        filled: true,
        fillColor: fieldBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
