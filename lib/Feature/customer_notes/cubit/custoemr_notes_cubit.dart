import 'package:client_app/Core/Helper/constants.dart';
import 'package:client_app/Core/Helper/snack_bar_helper.dart';
import 'package:client_app/Feature/customer_notes/cubit/customer_notes_state.dart';
import 'package:client_app/Feature/customer_notes/model/notes_model/notes_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerNotesCubit extends Cubit<CustomerNotesState> {
  final Dio _dio = Dio();
  String? _token; // Store token as a member variable

  CustomerNotesCubit() : super(CustomerNotesInitial()) {
    _initializeToken().then((value) {
      getCustomerNotes();
    }); // Initialize token
  }
  static CustomerNotesCubit get(context) => BlocProvider.of(context);
  Future<void> _initializeToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token == null) {
      print("Token not found in SharedPreferences.");
    } else {
      print("Token initialized: $_token");
    }
  }

  Future<void> getCustomerNotes() async {
    emit(CustomerNotesLoading());

    try {
      final response = await _dio.get(
        '${Constants.baseUrl}${Constants.notes}',
        options: Options(
          headers: {
            "Authorization": "Token $_token",
          },
        ),
      );

      final List<NotesModel> customerNotes = List<NotesModel>.from(
        response.data.map((noteJson) => NotesModel.fromJson(noteJson)),
      );
      emit(CustomerNotesLoaded(customerNotes));
    } catch (e) {
      if (e is DioError) {
        if (e.response?.statusCode == 401) {
          print("Not Authorized: Invalid Token");
          emit(NotaAouthorized());
        } else {
          print("Error: ${e.response?.statusCode}");
          emit(CustomerNotesError("فشل في تحميل الملاحظات"));
          showToast(
              text: "حدث خطأ ما أثناء تحميل الملاحظات",
              state: ToastStates.ERROR);
        }
      } else {
        print(e.toString());
        emit(CustomerNotesError("فشل في تحميل الملاحظات"));
        showToast(
            text: "حدث خطأ ما أثناء تحميل الملاحظات", state: ToastStates.ERROR);
      }
    }
  }

  Future<void> addNote(id, noteType) async {
    emit(CustomerAddNotesLoading());
    await _dio
        .post(
      "${Constants.baseUrl}${Constants.notes}",
      data: {
        "customer_id": id,
        "note_type": noteType,
      },
      options: Options(
        headers: {
          "Authorization": "Token $_token",
        },
      ),
    )
        .then((value) {
      print(value.data);
      emit(CustomerAddNotesSuccess());

      showToast(text: "تم تسجيل ملاحظتك بنجاح", state: ToastStates.SUCCESS);
    }).catchError((e) {
      print("${e.toString()}");

      showToast(
          text: "لم يتم تسجيل ملاحظتك , حاول مجددا", state: ToastStates.ERROR);

      emit(CustomerAddNotesFailure());
    });
  }
}
