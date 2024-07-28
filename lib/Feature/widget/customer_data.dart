// import 'package:client_app/Feature/resources/colors/colors.dart';
import 'package:flutter/material.dart';

import 'package:client_app/Feature/resources/colors/colors.dart';
import 'package:client_app/Feature/resources/styles/app_sized_box.dart';
import 'package:client_app/Feature/resources/styles/app_text_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerDatatWidget extends StatefulWidget {
  final String name;
  final int id;
  final String nickname;
  final String address;
  final String detailedAddress;
  final int collectionDay;
  final VoidCallback abstainedonpress;
  final VoidCallback maintenanceonpress;

  final double amount;

  const CustomerDatatWidget({
    Key? key,
    required this.name,
    required this.id,
    required this.nickname,
    required this.address,
    required this.detailedAddress,
    required this.collectionDay,
    required this.abstainedonpress,
    required this.maintenanceonpress,
    required this.amount,
  }) : super(key: key);

  @override
  State<CustomerDatatWidget> createState() => _CustomerDatatWidgetState();
}

class _CustomerDatatWidgetState extends State<CustomerDatatWidget> {
  double? subtractiveValue;
  Future<void> _loadSubtractiveValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // subtractiveValue = prefs.getString('subtractiveValue') ?? '';
      subtractiveValue = prefs.getDouble('subtractionValue') ?? 0.0;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadSubtractiveValue();
  }

  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: ListView(
        children: [
          Container(
            height: 80,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: const Color.fromARGB(255, 71, 70, 70),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text(
                    "تفاصيل المستخدم ",
                    style: AppTextStyle.textStyleWhiteSemiBold19,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppSizedBox.sizedH10,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text(
                  "رقم المستخدم : ",
                  style: AppTextStyle.textStyleMediumBlack,
                ),
                Text(
                  widget.id.toString(),
                  style:
                      const TextStyle(color: Color.fromARGB(255, 52, 50, 50)),
                ),
              ],
            ),
          ),
          AppSizedBox.sizedH10,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text(
                  "الاسم : ",
                  style: AppTextStyle.textStyleMediumBlack,
                ),
                Text(
                  widget.name,
                  style:
                      const TextStyle(color: Color.fromARGB(255, 52, 50, 50)),
                ),
              ],
            ),
          ),
          AppSizedBox.sizedH10,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text(
                  "اسم الشهره : ",
                  style: AppTextStyle.textStyleMediumBlack,
                ),
                Text(
                  widget.nickname,
                  style:
                      const TextStyle(color: Color.fromARGB(255, 52, 50, 50)),
                ),
              ],
            ),
          ),
          AppSizedBox.sizedH10,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text(
                  "العنوان  : ",
                  style: AppTextStyle.textStyleMediumBlack,
                ),
                Text(
                  widget.address,
                  style:
                      const TextStyle(color: Color.fromARGB(255, 52, 50, 50)),
                ),
              ],
            ),
          ),
          AppSizedBox.sizedH10,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text(
                  "العنوان بالتفصيل : ",
                  style: AppTextStyle.textStyleMediumBlack,
                ),
                Text(
                  widget.detailedAddress,
                  style:
                      const TextStyle(color: Color.fromARGB(255, 52, 50, 50)),
                ),
              ],
            ),
          ),
          AppSizedBox.sizedH10,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text(
                  "يوم التحصيل : ",
                  style: AppTextStyle.textStyleMediumBlack,
                ),
                Text(
                  widget.collectionDay.toString(),
                  style:
                      const TextStyle(color: Color.fromARGB(255, 52, 50, 50)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text(
                  "المبلغ : ",
                  style: AppTextStyle.textStyleMediumBlack,
                ),
                widget.amount >= subtractiveValue!
                    ? Text(
                        widget.amount.toString(),
                        style: const TextStyle(
                            color: Color.fromARGB(255, 52, 50, 50)),
                      )
                    : Text(
                        widget.amount.toString(),
                        style: const TextStyle(
                            color: Color.fromARGB(255, 213, 16, 16)),
                      ),
              ],
            ),
          ),
          const Divider(
            color: AppColors.gray,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.red,
                ),
                child: Center(
                    child: TextButton(
                  child: const Text(
                    "ممتنع ",
                    style: AppTextStyle.textStyleWhiteSemiBold19,
                  ),
                  onPressed: widget.abstainedonpress,
                )),
              ),
              AppSizedBox.sizedW100,
              Container(
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.yellow,
                ),
                child: Center(
                    child: TextButton(
                  child: Text("صيانه ", style: AppTextStyle.textStyleBoldBlack),
                  onPressed: widget.maintenanceonpress,
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
