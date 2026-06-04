import 'package:flutter/material.dart';
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

  String selectedCategory = "Technical Support";
  String selectedPriority = "Med";
  bool isSubmitting = false;

  final List<String> categories = [
    "Technical Support",
    "Network",
    "Hardware",
    "Software",
    "Other",
  ];

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    if (isSubmitting) return;

    setState(() => isSubmitting = true);

    try {
      final insertedTicket = await _ticketService.createTicket(
        title: titleController.text.trim().isEmpty
            ? "Untitled Ticket"
            : titleController.text.trim(),
        category: selectedCategory,
        description: descController.text.trim(),
        requestedPriority: selectedPriority.toUpperCase(),
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
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : Colors.grey[500]!;
    final fieldBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF);
    final hintColor = isDark ? const Color(0xFF64748B) : Colors.grey[400]!;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final labelColor = const Color(0xFF94A3B8);
    final dropdownBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final navBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,

      // ─── SUBMIT BUTTON FIXED BOTTOM ─────────────────────────────
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
                "Max file size: 25MB. PDF, PNG, JPG supported.",
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
              // ─── HEADER ─────────────────────────────────────────────
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
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF475569),
                      size: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ─── PAGE TITLE ─────────────────────────────────────────
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

              // ─── SUBJECT ─────────────────────────────────────────────
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

              // ─── CATEGORY ────────────────────────────────────────────
              _fieldLabel("CATEGORY"),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: fieldBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF475569),
                    ),
                    style: TextStyle(
                      fontSize: 15,
                      color: textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    dropdownColor: dropdownBg,
                    borderRadius: BorderRadius.circular(14),
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => selectedCategory = value);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ─── PRIORITY ────────────────────────────────────────────
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

                    Color selectedTextColor;
                    switch (priority) {
                      case "High":
                        selectedTextColor = const Color(0xFFEF4444);
                        break;
                      case "Med":
                        selectedTextColor = const Color(0xFFF97316);
                        break;
                      default:
                        selectedTextColor = const Color(0xFF16A34A);
                    }

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => selectedPriority = priority);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? const Color(0xFF334155) : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isSelected && !isDark
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              priority,
                              style: TextStyle(
                                color: isSelected ? selectedTextColor : labelColor,
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

              // ─── DESCRIPTION ────────────────────────────────────────
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

              // ─── ATTACHMENT ─────────────────────────────────────────
              _fieldLabel("ATTACHMENT"),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // TODO: implement pick from gallery
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        decoration: BoxDecoration(
                          color: fieldBg,
                          borderRadius: BorderRadius.circular(14),
                          border: isDark
                              ? Border.all(color: const Color(0xFF334155))
                              : null,
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.folder_open_outlined,
                              color: Color(0xFF2563EB),
                              size: 28,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Upload from\nGallery",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                height: 1.4,
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
                      onTap: () {
                        // TODO: implement camera capture
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        decoration: BoxDecoration(
                          color: fieldBg,
                          borderRadius: BorderRadius.circular(14),
                          border: isDark
                              ? Border.all(color: const Color(0xFF334155))
                              : null,
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              color: Color(0xFF2563EB),
                              size: 28,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Take Photo",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                height: 1.4,
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

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF94A3B8),
        letterSpacing: 1.0,
      ),
    );
  }

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
      style: TextStyle(
        fontSize: 15,
        color: textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor, fontSize: 14),
        filled: true,
        fillColor: fieldBg,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
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
          borderSide: const BorderSide(
            color: Color(0xFF2563EB),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}