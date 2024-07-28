import 'package:client_app/Feature/customer_notes/customer_notes_model/customer_notes_model.dart';
import 'package:client_app/Feature/customer_notes/model/notes_model/notes_model.dart';

abstract class CustomerNotesState {}

class CustomerNotesInitial extends CustomerNotesState {}

class CustomerNotesLoading extends CustomerNotesState {}

class CustomerNotesLoaded extends CustomerNotesState {
  final List<NotesModel> customerNotes;

  CustomerNotesLoaded(this.customerNotes);
}

class CustomerNotesError extends CustomerNotesState {
  final String error;

  CustomerNotesError(this.error);
}
