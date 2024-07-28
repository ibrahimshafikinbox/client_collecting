import 'package:client_app/Core/Helper/constants.dart';
import 'package:client_app/Core/Helper/snack_bar_helper.dart';
import 'package:client_app/Feature/customer_notes/cubit/customer_notes_state.dart';
import 'package:client_app/Feature/customer_notes/customer_notes_model/customer_notes_model.dart';
import 'package:client_app/Feature/customer_notes/model/notes_model/notes_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomerNotesCubit extends Cubit<CustomerNotesState> {
  final Dio _dio = Dio();

  CustomerNotesCubit() : super(CustomerNotesInitial());
  static CustomerNotesCubit get(context) => BlocProvider.of(context);

  Future<void> getCustomerNotes() async {
    try {
      emit(CustomerNotesLoading());
      final response = await _dio.get(
        '${Constants.baseUrl}${Constants.notes}',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Accept-Language': 'en',
            "Authorization": "Token 55c754cbcb7b0a0631b13a44d0641514d5171175",
          },
        ),
      );
      final List<NotesModel> customerNotes = List<NotesModel>.from(
        response.data.map((noteJson) => NotesModel.fromJson(noteJson)),
      );
      print(customerNotes.first.customer?.address);
      emit(CustomerNotesLoaded(customerNotes));
    } catch (e) {
      emit(CustomerNotesError(e.toString()));
    }
  }

  Future<void> addNote(id, noteType) async {
    await _dio
        .post(
      "${Constants.baseUrl}${Constants.notes}",
      data: {
        "customer_id": id,
        "note_type": noteType,
      },
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Accept-Language': 'en',
          "Authorization": "Token 55c754cbcb7b0a0631b13a44d0641514d5171175",
        },
      ),
    )
        .then((value) {
      print(value.data);
      showToast(text: "تم تسجيل ملاحظتك بنجاح", state: ToastStates.SUCCESS);
    }).catchError((e) {
      showToast(
          text: "لم يتم تسجيل ملاحظتك , حاول مجددا", state: ToastStates.ERROR);

      print("$e");
    });
  }
}
