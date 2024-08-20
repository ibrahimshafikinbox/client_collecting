import 'package:client_app/Feature/customer_notes/cubit/custoemr_notes_cubit.dart';
import 'package:client_app/Feature/customer_notes/widget/NotesPageContent.dart';
import 'package:client_app/Feature/resources/colors/colors.dart';
import 'package:client_app/Feature/resources/styles/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotesPage extends StatefulWidget {
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
          backgroundColor: const Color(0xFF0F1451),
          title: const Text('ملاحظات المستخدمين',
              style: AppTextStyle.textStyleWhiteSemiBold19),
          actions: [
            IconButton(
                onPressed: () {
                  CustomerNotesCubit().getCustomerNotes();
                },
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ))
          ]),
      body: NotesPageContent(),
    );
  }
}
