import 'package:client_app/Feature/resources/colors/colors.dart';
import 'package:client_app/Feature/resources/styles/app_text_style.dart';
import 'package:flutter/material.dart';

class CustomerBuildCard extends StatelessWidget {
  const CustomerBuildCard(
      {super.key,
      required this.name,
      required this.noteType,
      required this.address,
      required this.dateOfCreate});
  final String name;
  final int noteType;
  final String address;
  final String dateOfCreate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: AppColors.white,
            borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Text(
                      "اسم العميل ",
                      style: AppTextStyle.textStyleMediumBlack,
                    ),
                    Spacer(),
                    Text("$name"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Text(
                      "نوع الملاحظه ",
                      style: AppTextStyle.textStyleMediumBlack,
                    ),
                    Spacer(),
                    // ignore: unrelated_type_equality_checks
                    noteType == 1
                        ? Text(
                            "ممتنع",
                            style: TextStyle(color: Colors.red),
                          )
                        : Text(
                            "صيانه ",
                            style: TextStyle(
                                color: Color.fromARGB(255, 31, 233, 4)),
                          ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Text(
                      "العنوان",
                      style: AppTextStyle.textStyleMediumBlack,
                    ),
                    Spacer(),
                    Text("$address"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Text(
                      "تاريخ الانشاء",
                      style: AppTextStyle.textStyleMediumBlack,
                    ),
                    Spacer(),
                    Text("${dateOfCreate}"),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
