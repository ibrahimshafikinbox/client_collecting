import 'package:client_app/Feature/customer_notes/cubit/custoemr_notes_cubit.dart';
import 'package:client_app/Feature/customer_notes/cubit/customer_notes_state.dart';
import 'package:client_app/Feature/customer_notes/widget/customer_build_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotesPageContent extends StatefulWidget {
  @override
  State<NotesPageContent> createState() => _NotesPageContentState();
}

class _NotesPageContentState extends State<NotesPageContent> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerNotesCubit, CustomerNotesState>(
      builder: (context, state) {
        if (state is CustomerNotesLoading) {
          return Center(
              child:
                  CircularProgressIndicator()); // Show loading indicator while fetching notes
        } else if (state is CustomerNotesLoaded) {
          final notes =
              state.customerNotes; // Access notes from the loaded state
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return CustomerBuildCard(
                  name: note.customer?.name ?? '',
                  noteType: note.noteType ?? 0,
                  address: note.customer!.address ?? "",
                  dateOfCreate: "${note.createdAt ?? ''}");
            },
          );
        } else if (state is CustomerNotesError) {
          return Center(
              child:
                  CircularProgressIndicator()); // Show error message if failed to fetch notes
        } else {
          return Center(
              child: Text('Unknown state')); // Handle any unexpected state
        }
      },
    );
  }
}
