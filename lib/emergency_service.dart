import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../firebase_options.dart';

class EmergencyContactsService {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();

  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await _ensureEmergencyContactsExist();
  }

  static DatabaseReference get emergencyContactsRef =>
      _database.child('official_numbers');

  static DatabaseReference get suggestionsRef => _database.child('suggestions');

  static Future<void> _ensureEmergencyContactsExist() async {
    final snapshot = await emergencyContactsRef.get();
    if (snapshot.value == null) {
      await _addDefaultEmergencyContacts();
    }
  }

  static Future<void> _addDefaultEmergencyContacts() async {
    final defaultContacts = [
      {
        'name': 'Egyptian Ambulance Organization',
        'phone': '01062682775',
        'category': 'Medical',
      },
      {
        'name': 'Ambulance - October 6 Wholesale Market',
        'phone': '01000723139',
        'category': 'Medical',
      },
      {
        'name': 'National Ambulance Hotline',
        'phone': '123',
        'category': 'Medical',
      },
    ];

    for (var contact in defaultContacts) {
      await emergencyContactsRef.push().set(contact);
    }
  }

  static Stream<DatabaseEvent> getEmergencyContactsStream() {
    return emergencyContactsRef.onValue;
  }

  static Future<void> submitSuggestion(
    Map<String, dynamic> suggestionData,
  ) async {
    final newKey = suggestionsRef.push().key;
    if (newKey != null) {
      await suggestionsRef.child(newKey).set(suggestionData);
    }
  }

  // New method to update suggestion status
  static Future<void> updateSuggestionStatus(
    String suggestionId,
    String newStatus,
  ) async {
    final updates = {
      'status': newStatus,
      'statusUpdatedAt': DateTime.now().toIso8601String(),
    };

    await suggestionsRef.child(suggestionId).update(updates);
  }

  // Enhanced method to get suggestions with status filtering
  static Future<List<Map<String, dynamic>>> getSuggestionsByStatus(
    String status,
  ) async {
    final snapshot = await suggestionsRef.get();
    if (snapshot.value == null) return [];

    final data = snapshot.value as Map;
    return data.entries
        .map((e) {
          final suggestion = Map<String, dynamic>.from(e.value as Map);
          suggestion['id'] = e.key;
          return suggestion;
        })
        .where((suggestion) => suggestion['status'] == status)
        .toList();
  }

  // Method to get all suggestions for admin
  static Future<List<Map<String, dynamic>>> getAllSuggestions() async {
    final snapshot = await suggestionsRef.get();
    if (snapshot.value == null) return [];

    final data = snapshot.value as Map;
    return data.entries.map((e) {
      final suggestion = Map<String, dynamic>.from(e.value as Map);
      suggestion['id'] = e.key;
      return suggestion;
    }).toList();
  }

  // Method to get user's own suggestions
  static Future<List<Map<String, dynamic>>> getUserSuggestions(
    String userId,
  ) async {
    final snapshot = await suggestionsRef.get();
    if (snapshot.value == null) return [];

    final data = snapshot.value as Map;
    return data.entries
        .map((e) {
          final suggestion = Map<String, dynamic>.from(e.value as Map);
          suggestion['id'] = e.key;
          return suggestion;
        })
        .where((suggestion) => suggestion['submittedBy'] == userId)
        .toList();
  }

  static Future<void> likeSuggestion(String suggestionId) async {
    final ref = suggestionsRef.child(suggestionId).child('likes');
    await ref.runTransaction((value) {
      final updated = (value as int? ?? 0) + 1;
      return Transaction.success(updated);
    });
  }

  static Future<void> dislikeSuggestion(String suggestionId) async {
    final ref = suggestionsRef.child(suggestionId).child('dislikes');
    await ref.runTransaction((value) {
      final updated = (value as int? ?? 0) + 1;
      return Transaction.success(updated);
    });
  }

  // Method to get suggestions count by status (useful for admin dashboard)
  static Future<Map<String, int>> getSuggestionsCountByStatus() async {
    final snapshot = await suggestionsRef.get();
    if (snapshot.value == null) {
      return {'pending': 0, 'approved': 0, 'rejected': 0};
    }

    final data = snapshot.value as Map;
    final suggestions =
        data.entries.map((e) {
          final suggestion = Map<String, dynamic>.from(e.value as Map);
          return suggestion;
        }).toList();

    int pendingCount = 0;
    int approvedCount = 0;
    int rejectedCount = 0;

    for (var suggestion in suggestions) {
      switch (suggestion['status']) {
        case 'pending':
          pendingCount++;
          break;
        case 'approved':
          approvedCount++;
          break;
        case 'rejected':
          rejectedCount++;
          break;
      }
    }

    return {
      'pending': pendingCount,
      'approved': approvedCount,
      'rejected': rejectedCount,
    };
  }

  // Method to bulk update suggestion statuses (for admin operations)
  static Future<void> bulkUpdateSuggestionStatus(
    List<String> suggestionIds,
    String newStatus,
  ) async {
    final updates = <String, dynamic>{};
    final timestamp = DateTime.now().toIso8601String();

    for (String id in suggestionIds) {
      updates['$id/status'] = newStatus;
      updates['$id/statusUpdatedAt'] = timestamp;
    }

    await suggestionsRef.update(updates);
  }

  // Method to delete a suggestion (admin only)
  static Future<void> deleteSuggestion(String suggestionId) async {
    await suggestionsRef.child(suggestionId).remove();
  }

  static Stream<DatabaseEvent> getSuggestionsStream() {
    return suggestionsRef.onValue;
  }

  // Method to get suggestions stream filtered by status
  static Stream<DatabaseEvent> getSuggestionsStreamByStatus(String status) {
    return suggestionsRef.orderByChild('status').equalTo(status).onValue;
  }

  // Method to get pending suggestions count for admin notifications
  static Future<int> getPendingSuggestionsCount() async {
    final snapshot =
        await suggestionsRef.orderByChild('status').equalTo('pending').get();
    if (snapshot.value == null) return 0;

    final data = snapshot.value as Map;
    return data.length;
  }
}
