import 'package:supabase_flutter/supabase_flutter.dart';

class TicketService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getUserTickets() async {
    final response = await _client
        .from('tickets')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getAdminTickets() async {
    final response = await _client
        .from('tickets')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createTicket({
    required String title,
    required String category,
    required String description,
    required String requestedPriority,
  }) async {
    final ticketCode = '#TK-${DateTime.now().millisecondsSinceEpoch % 10000}';

    final insertedTicket = await _client
        .from('tickets')
        .insert({
          'ticket_code': ticketCode,
          'title': title,
          'description': description,
          'category': category,
          'status': 'OPEN',

          // priority final admin masih kosong dulu
          'priority': null,

          // ini priority yang dipilih user di form create ticket
          'requested_priority': requestedPriority,

          // assigned_to nanti ditentukan admin/helpdesk
          'assigned_to': null,

          'reporter': 'Alex Johnson',
          'source': 'Mobile App',
          'strikethrough': false,
        })
        .select()
        .single();

    await _client.from('notifications').insert({
      'role_target': 'admin_helpdesk',
      'title': 'New Ticket Created',
      'message': 'New ticket $ticketCode submitted by Alex Johnson',
      'ticket_id': insertedTicket['id'],
      'status': 'OPEN',
      'notification_type': 'new_ticket',
      'is_read': false,
    });

    return Map<String, dynamic>.from(insertedTicket);
  }

  Future<Map<String, dynamic>> updateTicket({
    required int id,
    required String status,
    required String priority,
    required String assignedTo,
  }) async {
    final updatedTicket = await _client
        .from('tickets')
        .update({
          'status': status,
          'priority': priority,
          'assigned_to': assignedTo,
          'strikethrough': status == 'RESOLVED',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();

    await _client.from('notifications').insert({
      'role_target': 'user',
      'title': 'Ticket Updated',
      'message':
          'Your ticket ${updatedTicket['ticket_code']} is now $status and assigned to $assignedTo',
      'ticket_id': id,
      'status': status,
      'notification_type': 'ticket_update',
      'is_read': false,
    });

    return Map<String, dynamic>.from(updatedTicket);
  }

  Future<List<Map<String, dynamic>>> getNotifications({
    required String roleTarget,
  }) async {
    final response = await _client
        .from('notifications')
        .select()
        .eq('role_target', roleTarget)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addComment({
    required int ticketId,
    required String senderRole,
    required String senderName,
    required String message,
  }) async {
    await _client.from('ticket_comments').insert({
      'ticket_id': ticketId,
      'sender_role': senderRole,
      'sender_name': senderName,
      'message': message,
    });
  }
}