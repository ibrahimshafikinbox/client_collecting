import 'package:client_app/Core/Helper/naviagation_helper.dart';
import 'package:client_app/Feature/Login/Widget/default_button.dart';
import 'package:client_app/Feature/Login/Widget/default_form_field.dart';

import 'package:client_app/Feature/Login/cubit/Login_Cubit.dart';
import 'package:client_app/Feature/Login/cubit/Login_States.dart';
import 'package:client_app/Feature/customer_list/View/customer_list_view.dart';
import 'package:client_app/Feature/resources/styles/app_sized_box.dart';
import 'package:client_app/Feature/resources/styles/app_text_style.dart';

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 244, 244),
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("بيانات دخول صحيحه"),
              ),
            );
            navigateAndFinish(context, CustomerListView());
          } else if (state is LoginError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("تاكد من البيانات "),
              ),
            );
          }
        },
        builder: (context, state) {
          return Form(
            key: formKey,
            child: ListView(
              children: [
                AppSizedBox.sizedH100,
                Center(
                  child: SizedBox(
                    child: Center(
                      child: Image.asset("assets/images/logo.jpg"),
                    ),
                  ),
                ),
                AppSizedBox.sizedH20,
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("اسم المستخدم",
                          style: AppTextStyle.textStyleBoldBlack),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DefaultFormField(
                    controller: usernameController,
                    type: TextInputType.visiblePassword,
                    label: "اسم المستخدم",
                    hint: 'اسم المستخدم',
                    // prefix: Icons.phone,
                    onValidate: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال اسم المستخدم الخاص بك';
                      }
                      return null;
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(" كلمه المرور ",
                          style: AppTextStyle.textStyleBoldBlack),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DefaultFormField(
                    controller: passwordController,
                    type: TextInputType.visiblePassword,
                    label: "كلمة المرور",
                    hint: 'كلمة المرور',
                    // prefix: Icons.phone,
                    onValidate: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمه المرور الخاص بك';
                      }
                      return null;
                    },
                  ),
                ),
                AppSizedBox.sizedH25,
                ConditionalBuilder(
                  condition: state is! LoginLoading,
                  builder: (BuildContext context) => DefaultButton(
                    text: "تسجيل الدخول",
                    function: () {
                      if (formKey.currentState!.validate()) {
                        LoginCubit.get(context).loginuser(
                          username: usernameController.text,
                          password: passwordController.text,
                        );
                      }
                    },
                    textColor: Colors.white,
                    bottonColor: const Color.fromARGB(255, 52, 15, 154),
                  ),
                  fallback: (BuildContext context) =>
                      const Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
