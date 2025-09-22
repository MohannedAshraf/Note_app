import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/helper/firebase/firestore.dart';
import 'note_state.dart';

class NoteCubit extends Cubit<NoteState> {
  final FirestoreService firestoreService;

  NoteCubit(this.firestoreService) : super(NoteInitial());

  Future<void> addNote({
    required String title,
    required String description,
  }) async {
    emit(NoteLoading());
    try {
      await firestoreService.addNote(title: title, description: description);
      emit(NoteSuccess());
    } catch (e) {
      emit(NoteFailure(e.toString()));
    }
  }

  Future<void> deleteNote(String title) async {
    emit(NoteLoading());
    try {
      await firestoreService.deleteNote(title);
      emit(NoteSuccess());
    } catch (e) {
      emit(NoteFailure(e.toString()));
    }
  }

  Stream<QuerySnapshot> getNotesStream() {
    return firestoreService.getNotes();
  }

  Future<void> updateNote({
    required String oldTitle,
    String? newTitle,
    String? newDescription,
  }) async {
    emit(NoteLoading());
    try {
      await firestoreService.updateNote(
        oldTitle: oldTitle,
        newTitle: newTitle,
        newDescription: newDescription,
      );
      emit(NoteSuccess());
    } catch (e) {
      emit(NoteFailure(e.toString()));
    }
  }
}
