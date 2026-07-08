import 'package:supabase_flutter/supabase_flutter.dart';

/// Service class to handle all ticket-related database operations.
/// Implements the Service Layer pattern to separate business logic from UI.
class TicketService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Subscribes to real-time notification changes based on the target role.
  RealtimeChannel subscribeToNotifications(
    String roleTarget,
    Function(Map<String, dynamic>) onNewNotification,
  ) {
    return _client
        .channel('public:notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'role_target',
            value: roleTarget,
          ),
          callback: (payload) {
            onNewNotification(payload.newRecord);
          },
        )
        .subscribe();
  }

  /// Retrieves the count of tickets filtered by status or assignee.
  Future<int> getTicketCount({String? status, String? assignedTo}) async {
    var query = _client.from('tickets').select('id');

    if (status != null) {
      query = query.eq('status', status);
    }
    if (assignedTo != null) {
      query = query.eq('assigned_to', assignedTo);
    }

    final response = await query;
    return (response as List).length;
  }

  /// Fetches a list of tickets for regular users.
  Future<List<Map<String, dynamic>>> getUserTickets() async {
    final response = await _client
        .from('tickets')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetches a list of tickets for administrative purposes.
  Future<List<Map<String, dynamic>>> getAdminTickets() async {
    final response = await _client
        .from('tickets')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Creates a new ticket entry in the database.
  Future<Map<String, dynamic>> createTicket({
    required String title,
    required String description,
    required String requestedPriority,
    String? attachmentUrl,
  }) async {
    final ticketCode = '#TK-${DateTime.now().millisecondsSinceEpoch % 10000}';

    final insertedTicket = await _client
        .from('tickets')
        .insert({
          'ticket_code': ticketCode,
          'title': title,
          'description': description,
          'status': 'OPEN',
          'priority': null,
          'requested_priority': requestedPriority,
          'assigned_to': null,
          'reporter': 'Alex Johnson',
          'source': 'Mobile App',
          'strikethrough': false,
          'attachment_url': attachmentUrl,
        })
        .select()
        .single();

    // Create an initial notification for admins/helpdesk
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

  /// Updates ticket status, priority, and assignee.
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
          'strikethrough': status == 'CLOSED' || status == 'RESOLVED',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();

    final List<Map<String, dynamic>> notificationsToInsert = [
      {
        'role_target': 'user',
        'title': 'Ticket Updated',
        'message':
            'Your ticket ${updatedTicket['ticket_code']} is now $status and assigned to $assignedTo',
        'ticket_id': id,
        'status': status,
        'notification_type': 'ticket_update',
        'is_read': false,
      },
    ];

    if (assignedTo != 'Unassigned' && assignedTo.isNotEmpty) {
      notificationsToInsert.add({
        'role_target': 'admin_helpdesk',
        'title': 'Ticket Assigned',
        'message':
            'Admin assigned ticket ${updatedTicket['ticket_code']} to $assignedTo',
        'ticket_id': id,
        'status': status,
        'notification_type': 'ticket_assigned',
        'is_read': false,
      });
    }

    await _client.from('notifications').insert(notificationsToInsert);

    return Map<String, dynamic>.from(updatedTicket);
  }

  /// Retrieves notifications for a specific user role.
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

  /// Adds a new comment to an existing ticket.
  Future<void> addComment({
    required int ticketId,
    required String senderRole,
    required String senderName,
    required String message,
    String? attachmentUrl,
  }) async {
    await _client.from('ticket_comments').insert({
      'ticket_id': ticketId,
      'sender_role': senderRole,
      'sender_name': senderName,
      'message': message,
      'attachment_url': attachmentUrl,
    });
  }

  /// Retrieves all comments associated with a specific ticket.
  Future<List<Map<String, dynamic>>> getComments({
    required int ticketId,
  }) async {
    final response = await _client
        .from('ticket_comments')
        .select()
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  // --- NEW FUNCTIONS FOR SRS COMPLIANCE ---

  /// Uploads an attachment to Supabase Storage and returns the public URL.
  Future<String> uploadAttachment(var file, String fileName) async {
    await _client.storage.from('attachments').upload(fileName, file);
    return _client.storage.from('attachments').getPublicUrl(fileName);
  }

  /// Retrieves detailed information for a specific ticket.
  Future<Map<String, dynamic>> getTicketDetail(int ticketId) async {
    final response = await _client
        .from('tickets')
        .select()
        .eq('id', ticketId)
        .single();
    return Map<String, dynamic>.from(response);
  }

  /// Deletes a ticket and its associated data (comments/notifications).
  Future<void> deleteTicket(int ticketId) async {
    await _client.from('tickets').delete().eq('id', ticketId);
    await _client.from('notifications').delete().eq('ticket_id', ticketId);
    await _client.from('ticket_comments').delete().eq('ticket_id', ticketId);
  }

  /// Updates the active status of a user account.
  Future<void> deactivateUser(String userId) async {
    await _client.from('users').update({'is_active': false}).eq('id', userId);
  }
}
