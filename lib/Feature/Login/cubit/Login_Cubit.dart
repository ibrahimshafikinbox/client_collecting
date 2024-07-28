import 'package:client_app/Core/Helper/constants.dart';
import 'package:client_app/Feature/Login/cubit/Login_States.dart';
import 'package:client_app/Feature/Login/login_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginCubit extends Cubit<LoginState> {
  final Dio _dio = Dio();

  LoginCubit() : super(LoginInitial());
  static LoginCubit get(context) => BlocProvider.of(context);
  LoginModel? loginModel;
  Future<void> loginuser({
    required String username,
    required String password,
  }) async {
    emit(LoginLoading());
    await _dio
        .post(
      '${Constants.baseUrl}${Constants.login}',
      data: {
        'username': username,
        'password': password,
      },
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Accept-Language': 'en',
        },
      ),
    )
        .then((value) async {
      loginModel = LoginModel.fromJson(value.data);
      print(loginModel?.username);
      print("🚀🚀${value.data["token"]}");
      final token = value.data['token'];
      final userName = value.data['username'];

      // Save the token and username to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('username', userName);

      emit(LoginSuccess());
    }).catchError((onError) {
      emit(LoginError());
    });
  }

  // Future<void> loginuser({
  //   required String username,
  //   required String password,
  // }) async {
  //   emit(LoginLoading());
  //   await _dio
  //       .post(
  //     '${Constants.baseUrl}${Constants.login}',
  //     data: {
  //       'username': username,
  //       'password': password,
  //     },
  //     options: Options(
  //       headers: {
  //         'Accept': 'application/json',
  //         'Accept-Language': 'en',
  //       },
  //     ),
  //   )
  //       .then((value) async {
  //     loginModel = LoginModel.fromJson(value.data);
  //     print(loginModel?.username);
  //     print("🚀🚀${value.data["token"]}");
  //     final token = value.data['token'];
  //     // Save the token to SharedPreferences
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('token', token);

  //     emit(LoginSuccess());
  //   }).catchError((onError) {
  //     emit(LoginError());
  //   });
  // }

  Future<void> logOutUser() async {
    try {
      // Get SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();

      // Remove the token
      await prefs.remove('token');

      // Emit success state if needed
    } catch (error) {
      // Emit error state if something goes wrong
    }
  }
}
