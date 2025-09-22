import 'package:equatable/equatable.dart';

abstract class NoteState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NoteInitial extends NoteState {}

class NoteLoading extends NoteState {}

class NoteSuccess extends NoteState {}

class NoteFailure extends NoteState {
  final String error;

  NoteFailure(this.error);

  @override
  List<Object?> get props => [error];
}
