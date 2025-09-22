import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addNote({
    required String title,
    required String description,
  }) async {
    try {
      await _firestore.collection("Notes").doc(title).set({
        "description": description,
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Error adding note: $e");
    }
  }

  Future<void> deleteNote(String title) async {
    try {
      await _firestore.collection("Notes").doc(title).delete();
    } catch (e) {
      throw Exception("Error deleting note: $e");
    }
  }

  Stream<QuerySnapshot> getNotes() {
    return _firestore
        .collection("Notes")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  Future<void> updateNote({
    required String oldTitle,
    String? newTitle,
    String? newDescription,
  }) async {
    try {
      final oldDocRef = _firestore.collection("Notes").doc(oldTitle);

      if (newTitle != null && newTitle != oldTitle) {
        // Get existing data
        final snapshot = await oldDocRef.get();
        final data = snapshot.data()!;
        // Update title and/or description
        if (newDescription != null) {
          data['description'] = newDescription;
        }
        await _firestore.collection("Notes").doc(newTitle).set(data);
        await oldDocRef.delete();
      } else {
        Map<String, dynamic> updateData = {};
        if (newDescription != null) updateData['description'] = newDescription;
        if (updateData.isNotEmpty) await oldDocRef.update(updateData);
      }
    } catch (e) {
      throw Exception("Error updating note: $e");
    }
  }
}
