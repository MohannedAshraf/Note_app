import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_app/repo/model/app_user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> addNote({
    required String title,
    required String description,
  }) async {
    if (uid == null) throw Exception("User not logged in");

    try {
      await _firestore
          .collection("users")
          .doc(uid)
          .collection("Notes")
          .doc(title)
          .set({
            "description": description,
            "createdAt": FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception("Error adding note: $e");
    }
  }

  Future<void> deleteNote(String title) async {
    if (uid == null) throw Exception("User not logged in");

    try {
      await _firestore
          .collection("users")
          .doc(uid)
          .collection("Notes")
          .doc(title)
          .delete();
    } catch (e) {
      throw Exception("Error deleting note: $e");
    }
  }

  Stream<QuerySnapshot> getNotes() {
    if (uid == null) throw Exception("User not logged in");

    return _firestore
        .collection("users")
        .doc(uid)
        .collection("Notes")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  Future<void> updateNote({
    required String oldTitle,
    String? newTitle,
    String? newDescription,
  }) async {
    if (uid == null) throw Exception("User not logged in");

    try {
      final oldDocRef = _firestore
          .collection("users")
          .doc(uid)
          .collection("Notes")
          .doc(oldTitle);

      if (newTitle != null && newTitle != oldTitle) {
        final snapshot = await oldDocRef.get();
        final data = snapshot.data()!;
        if (newDescription != null) {
          data['description'] = newDescription;
        }
        await _firestore
            .collection("users")
            .doc(uid)
            .collection("Notes")
            .doc(newTitle)
            .set(data);
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

  // User data
  Future<void> saveUser(AppUser user) async {
    await _firestore.collection("users").doc(user.uid).set(user.toMap());
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _firestore.collection("users").doc(uid).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Stream<AppUser?> streamUser(String uid) {
    return _firestore.collection("users").doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return AppUser.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }
}
