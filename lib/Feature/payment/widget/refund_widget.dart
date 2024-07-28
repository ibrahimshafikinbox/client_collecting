import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:client_app/Feature/resources/colors/colors.dart';
import 'package:client_app/Feature/resources/styles/app_sized_box.dart';
import 'package:client_app/Feature/resources/styles/app_text_style.dart';

class RefundWidget extends StatelessWidget {
  const RefundWidget({
    Key? key,
    required this.clientName,
    required this.onPressed,
  }) : super(key: key);
  final String clientName;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 3,
      child: ListView(
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    "استرجاع الدفع    ",
                    style: AppTextStyle.textStyleWhiteSemiBold19,
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.close,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
            height: 80,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 71, 70, 70),
            ),
          ),
          AppSizedBox.sizedH10,
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "تاكيد الاسترجاع",
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "الاسم : ",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                " $clientName ",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
            ],
          ),
          AppSizedBox.sizedH20,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                    height: 70,
                    width: 100,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(15)),
                    child: Center(
                        child: GestureDetector(
                      onTap: onPressed,
                      child: Text(
                        "استرجاع",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      ),
                    ))),
              ),
            ],
          )
        ],
      ),
    );
  }
}
