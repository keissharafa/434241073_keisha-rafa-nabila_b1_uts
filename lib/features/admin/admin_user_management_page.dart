import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  State<AdminUserManagementPage> createState() =>
      _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];

  // Style guide
  static const _primary = Color(0xFF6C63FF);
  static const _bgLight = Color(0xFFEDEFF7);
  static const _surfaceLight = Color(0xFFFFFFFF);
  static const _textPrimaryLight = Color(0xFF14142B);
  static const _textSecondaryLight = Color(0xFF92929D);

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('id, full_name, role, email')
          .order('full_name', ascending: true);

      if (mounted) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memuat data pengguna: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // FITUR UPDATE (UBAH ROLE)
  Future<void> _updateRole(
    String userId,
    String currentRole,
    String userName,
  ) async {
    final String? newRole = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Ubah Role",
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            "Pilih role baru untuk $userName:",
            style: GoogleFonts.plusJakartaSans(fontSize: 14),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'USER'),
              child: Text(
                "USER",
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF21D07B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'HELPDESK'),
              child: Text(
                "HELPDESK",
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFFF9F43),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'ADMIN'),
              child: Text(
                "ADMIN",
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFF45B69),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (newRole != null && newRole != currentRole) {
      setState(() => _isLoading = true);
      try {
        await Supabase.instance.client
            .from('users')
            .update({'role': newRole})
            .eq('id', userId);

        await _fetchUsers(); // Refresh data
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Role $userName berhasil diubah menjadi $newRole"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal mengubah role: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // FITUR DELETE (HAPUS PENGGUNA)
  Future<void> _deleteUser(String userId, String userName) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Hapus Pengguna",
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.red,
          ),
        ),
        content: Text(
          "Yakin ingin menghapus $userName dari sistem? Aksi ini tidak dapat dibatalkan.",
          style: GoogleFonts.plusJakartaSans(fontSize: 14),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Batal",
              style: GoogleFonts.plusJakartaSans(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Hapus",
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await Supabase.instance.client.from('users').delete().eq('id', userId);

        await _fetchUsers(); // Refresh data
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Pengguna $userName berhasil dihapus"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal menghapus pengguna: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
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
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.3)
        : _primary.withOpacity(0.07);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
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
                      "User Management",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),

            // Body Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: _primary),
                    )
                  : _users.isEmpty
                  ? Center(
                      child: Text(
                        "Belum ada pengguna terdaftar.",
                        style: GoogleFonts.plusJakartaSans(
                          color: textSecondary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        final role = (user['role'] ?? 'USER')
                            .toString()
                            .toUpperCase();
                        final userId = user['id'].toString();
                        final userName = user['full_name'] ?? 'Unknown User';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF2E2A52)
                                  : const Color(0xFFF0F1F6),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: _primary.withOpacity(0.15),
                              child: Text(
                                userName.substring(0, 1).toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  color: _primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              userName,
                              style: GoogleFonts.plusJakartaSans(
                                color: textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  user['email'] ?? 'No email',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: role == 'ADMIN'
                                        ? const Color(
                                            0xFFF45B69,
                                          ).withOpacity(0.1)
                                        : (role == 'HELPDESK'
                                              ? const Color(
                                                  0xFFFF9F43,
                                                ).withOpacity(0.1)
                                              : const Color(
                                                  0xFF21D07B,
                                                ).withOpacity(0.1)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    role,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: role == 'ADMIN'
                                          ? const Color(0xFFF45B69)
                                          : (role == 'HELPDESK'
                                                ? const Color(0xFFFF9F43)
                                                : const Color(0xFF21D07B)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.grey,
                              ),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _updateRole(userId, role, userName);
                                } else if (value == 'delete') {
                                  _deleteUser(userId, userName);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Ubah Role",
                                        style: GoogleFonts.plusJakartaSans(),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Hapus Pengguna",
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
