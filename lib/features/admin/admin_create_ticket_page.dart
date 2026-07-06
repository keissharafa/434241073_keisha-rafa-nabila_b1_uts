import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminCreateTicketPage extends StatefulWidget {
  final Function(bool) toggleTheme;

  const AdminCreateTicketPage({super.key, required this.toggleTheme});

  @override
  State<AdminCreateTicketPage> createState() => _AdminCreateTicketPageState();
}

class _AdminCreateTicketPageState extends State<AdminCreateTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  // Dropdown values
  String _selectedCategory = "Technical Support";
  String _selectedPriority = "MEDIUM";
  String? _selectedReporter;

  // Data user untuk dropdown "On Behalf Of"
  List<String> _userList = ["Internal System"];
  bool _isLoadingUsers = true;

  // Attachment
  File? _selectedFile;
  final ImagePicker _picker = ImagePicker();

  bool _isSubmitting = false;

  final List<String> _categories = [
    "Technical Support",
    "Billing Issue",
    "Account Access",
    "Feature Request",
    "General Inquiry",
  ];

  final List<String> _priorities = ["LOW", "MEDIUM", "HIGH", "URGENT"];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Tarik daftar pengguna dari Supabase untuk diwakilkan
  Future<void> _fetchUsers() async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('full_name')
          .eq('role', 'user');

      final users = (response as List)
          .map((e) => e['full_name'] as String)
          .toList();

      if (!mounted) return;
      setState(() {
        _userList.addAll(users);
        _selectedReporter = _userList.first; // Default ke "Internal System"
        _isLoadingUsers = false;
      });
    } catch (e) {
      debugPrint("Error fetching users: $e");
      if (mounted) {
        setState(() {
          _selectedReporter = _userList.first;
          _isLoadingUsers = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() => _selectedFile = File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to pick image: $e")));
    }
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedReporter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a reporter.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? attachmentUrl;
      final ticketCode = '#TK-${Random().nextInt(9000) + 1000}';

      // 1. Upload File Jika Ada
      if (_selectedFile != null) {
        final fileExt = _selectedFile!.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = 'admin_uploads/$fileName';

        await Supabase.instance.client.storage
            .from('attachments')
            .upload(filePath, _selectedFile!);

        attachmentUrl = Supabase.instance.client.storage
            .from('attachments')
            .getPublicUrl(filePath);
      }

      // 2. Insert Langsung ke Database (Override Reporter)
      await Supabase.instance.client.from('tickets').insert({
        'ticket_code': ticketCode,
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'category': _selectedCategory,
        'priority': _selectedPriority,
        'requested_priority': _selectedPriority,
        'reporter': _selectedReporter,
        'status': 'OPEN',
        'attachment_url': attachmentUrl,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text("Ticket created successfully!"),
            ],
          ),
          backgroundColor: Color(0xFF21D07B),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true); // Kembali & beri sinyal sukses
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to create ticket: $e"),
          backgroundColor: const Color(0xFFF45B69),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
    final fieldBg = isDark ? const Color(0xFF14142B) : const Color(0xFFF8F9FB);

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
          "Create Ticket",
          style: GoogleFonts.plusJakartaSans(
            color: textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
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
                            color: Colors.black.withOpacity(0.04),
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
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings,
                            color: primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Admin Override",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Create a ticket on behalf of a user or for internal system issues.",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- ON BEHALF OF ---
                    _buildLabel("On Behalf Of (Reporter)", textPrimary),
                    const SizedBox(height: 8),
                    _isLoadingUsers
                        ? const Center(child: CircularProgressIndicator())
                        : _buildDropdown(
                            value: _selectedReporter,
                            items: _userList,
                            onChanged: (v) =>
                                setState(() => _selectedReporter = v),
                            fieldBg: fieldBg,
                            borderColor: borderColor,
                            textPrimary: textPrimary,
                          ),
                    const SizedBox(height: 20),

                    // --- TITLE ---
                    _buildLabel("Ticket Title", textPrimary),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: textPrimary,
                      ),
                      decoration: _inputDecoration(
                        "Briefly summarize the issue",
                        fieldBg,
                        borderColor,
                        textSecondary,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Title is required" : null,
                    ),
                    const SizedBox(height: 20),

                    // --- CATEGORY & PRIORITY ---
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Category", textPrimary),
                              const SizedBox(height: 8),
                              _buildDropdown(
                                value: _selectedCategory,
                                items: _categories,
                                onChanged: (v) =>
                                    setState(() => _selectedCategory = v!),
                                fieldBg: fieldBg,
                                borderColor: borderColor,
                                textPrimary: textPrimary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Priority", textPrimary),
                              const SizedBox(height: 8),
                              _buildDropdown(
                                value: _selectedPriority,
                                items: _priorities,
                                onChanged: (v) =>
                                    setState(() => _selectedPriority = v!),
                                fieldBg: fieldBg,
                                borderColor: borderColor,
                                textPrimary: textPrimary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- DESCRIPTION ---
                    _buildLabel("Description", textPrimary),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      maxLines: 5,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: textPrimary,
                      ),
                      decoration: _inputDecoration(
                        "Provide details about the issue...",
                        fieldBg,
                        borderColor,
                        textSecondary,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Description is required" : null,
                    ),
                    const SizedBox(height: 24),

                    // --- ATTACHMENT ---
                    _buildLabel("Attachment (Optional)", textPrimary),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: fieldBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: borderColor,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          children: [
                            if (_selectedFile != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedFile!,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Tap to change image",
                                style: GoogleFonts.plusJakartaSans(
                                  color: primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ] else ...[
                              Icon(
                                Icons.cloud_upload_outlined,
                                color: textSecondary,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Upload Screenshot/File",
                                style: GoogleFonts.plusJakartaSans(
                                  color: textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "JPG, PNG (Max 5MB)",
                                style: GoogleFonts.plusJakartaSans(
                                  color: textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- SUBMIT BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _isSubmitting ? null : _submitTicket,
                        child: _isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                "Submit Ticket",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    Color fill,
    Color border,
    Color hintColor,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(color: hintColor, fontSize: 14),
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFF45B69)),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required Color fieldBg,
    required Color borderColor,
    required Color textPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: textPrimary.withOpacity(0.5),
          ),
          dropdownColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1F1B3A)
              : Colors.white,
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: textPrimary),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
