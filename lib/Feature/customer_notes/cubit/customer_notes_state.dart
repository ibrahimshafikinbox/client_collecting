import 'package:client_app/Feature/customer_notes/model/notes_model/notes_model.dart';

// customer get notes
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

// cutomer add notes
class CustomerAddNotesLoading extends CustomerNotesState {}

class CustomerAddNotesSuccess extends CustomerNotesState {}

class CustomerAddNotesFailure extends CustomerNotesState {}

class NotaAouthorized extends CustomerNotesState {}
