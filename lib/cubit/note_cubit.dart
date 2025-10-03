import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/helper/firebase/firestore.dart';
import 'note_state.dart';

class NoteCubit extends Cubit<NoteState> {
  final FirestoreService firestoreService;
  NoteCubit(this.firestoreService) : super(NoteInitial());
  String? get uid => FirebaseAuth.instance.currentUser?.uid;
  Future<void> addNote({
    required String title,
    required String description,
  }) async {
    if (title.trim().isEmpty || description.trim().isEmpty) {
      emit(NoteEmptyFields());
      return;
    }
    emit(NoteLoading());
    try {
      await firestoreService.addNote(
        title: title.trim(),
        description: description.trim(),
      );
      emit(NoteSuccess());
    } catch (e) {
      emit(NoteFailure(e.toString()));
    }
  }

  Future<void> deleteNote(String title) async {
    if (title.trim().isEmpty) {
      emit(NoteEmptyFields());
      return;
    }
    emit(NoteLoading());
    try {
      await firestoreService.deleteNote(title.trim());
      emit(NoteSuccess());
    } catch (e) {
      emit(NoteFailure(e.toString()));
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getNotesStream() {
    final userId = uid;
    if (userId == null) throw Exception("User not logged in");
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("Notes")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getNoteStream(String title) {
    final userId = uid;
    if (userId == null) throw Exception("User not logged in");
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("Notes")
        .doc(title)
        .snapshots();
  }

  Future<Map<String, dynamic>?> getNoteDataOnce(String title) async {
    final userId = uid;
    if (userId == null) throw Exception("User not logged in");
    final doc =
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("Notes")
            .doc(title)
            .get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> updateNote({
    required String oldTitle,
    String? newTitle,
    String? newDescription,
  }) async {
    final trimmedNewTitle = newTitle?.trim();
    final trimmedNewDesc = newDescription?.trim();
    if ((trimmedNewTitle == null || trimmedNewTitle.isEmpty) &&
        (trimmedNewDesc == null || trimmedNewDesc.isEmpty)) {
      emit(NoteEmptyFields("Nothing to update"));
      return;
    }
    if (newTitle != null && trimmedNewTitle!.isEmpty) {
      emit(NoteEmptyFields());
      return;
    }
    emit(NoteLoading());
    try {
      await firestoreService.updateNote(
        oldTitle: oldTitle,
        newTitle: trimmedNewTitle,
        newDescription: trimmedNewDesc,
      );
      emit(NoteSuccess());
    } catch (e) {
      emit(NoteFailure(e.toString()));
    }
  }
}
