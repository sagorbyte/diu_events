import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ticket.dart';

class TicketService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'event_tickets';

  Future<String> createTicket({
    required String userId,
    required String eventId,
    required String eventTitle,
  }) async {
    final docRef = await _firestore.collection(_collection).add({
      'userId': userId,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'createdAt': DateTime.now().toIso8601String(),
    });

    // write id into doc for easier retrieval
    await docRef.update({'id': docRef.id});
    return docRef.id;
  }

  Future<void> deleteTicket(String ticketId) async {
    await _firestore.collection(_collection).doc(ticketId).delete();
  }

  Future<Ticket?> getTicketByUserAndEvent(String userId, String eventId) async {
    try {
      // Add a timeout so the UI doesn't wait indefinitely in case of network
      // issues or Firestore index errors.
      final q = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));

      if (q.docs.isEmpty) return null;
      final data = Map<String, dynamic>.from(q.docs.first.data());
      data['id'] = q.docs.first.id;
      return Ticket.fromJson(data);
    } catch (e) {
      // Don't throw — return null and let callers show a friendly message.
      // Log the error for debugging in development.
      print('TicketService.getTicketByUserAndEvent error: $e');
      return null;
    }
  }

  // Fetch ticket by its document id
  Future<Ticket?> getTicketById(String ticketId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(ticketId).get().timeout(const Duration(seconds: 8));
      if (!doc.exists) return null;
      final data = Map<String, dynamic>.from(doc.data() ?? {});
      data['id'] = doc.id;
      return Ticket.fromJson(data);
    } catch (e) {
      print('TicketService.getTicketById error: $e');
      return null;
    }
  }

  /// Robust lookup: first try doc id, then common fields that may contain the code.
  Future<Ticket?> lookupTicketByAnyField(String code) async {
    try {
      final trimmed = code.trim();

  // 1) Try document id
  final doc = await _firestore.collection(_collection).doc(trimmed).get().timeout(const Duration(seconds: 6));
      if (doc.exists) {
        final data = Map<String, dynamic>.from(doc.data() ?? {});
        data['id'] = doc.id;
        print('TicketService.lookup: found by doc id: ${doc.id}');
        return Ticket.fromJson(data);
      }

      // 2) Try fields: id (stored), ticketId, code, ticketCode
      final queries = [
        {'field': 'id', 'value': trimmed},
        {'field': 'ticketId', 'value': trimmed},
        {'field': 'code', 'value': trimmed},
        {'field': 'ticketCode', 'value': trimmed},
      ];

      for (final q in queries) {
        try {
      final qSnap = await _firestore
        .collection(_collection)
        .where(q['field'] as String, isEqualTo: q['value'])
        .limit(1)
        .get()
        .timeout(const Duration(seconds: 6));
          if (qSnap.docs.isNotEmpty) {
            final d = qSnap.docs.first;
            final data = Map<String, dynamic>.from(d.data());
            data['id'] = d.id;
            print('TicketService.lookup: found by field ${q['field']} = ${q['value']} (doc: ${d.id})');
            return Ticket.fromJson(data);
          }
        } catch (e) {
          // ignore individual query errors
        }
      }

      // Not found
      print('TicketService.lookup: not found for code: $trimmed');
      return null;
    } catch (e) {
      print('TicketService.lookup error: $e');
      return null;
    }
  }
}
