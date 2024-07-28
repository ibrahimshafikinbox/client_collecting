// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:client_app/Feature/customer_list/cubit/get_customer_cubit.dart';
// import 'package:client_app/Feature/resources/styles/app_text_style.dart';
// import 'package:client_app/Feature/resources/styles/app_sized_box.dart';
// import 'package:client_app/Feature/resources/colors/colors.dart';
// import 'package:client_app/Core/Helper/naviagation_helper.dart';
// import 'package:client_app/Feature/customer_list/records_model/records_model.dart';
// import 'package:client_app/Feature/collecting/daily_payment.dart';

// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final int? selectedDay;
//   final Function() onDateTap;

//   const CustomAppBar({
//     Key? key,
//     required this.selectedDay,
//     required this.onDateTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       iconTheme: const IconThemeData(color: AppColors.white),
//       backgroundColor: const Color(0xFF0F1451),
//       title: Row(
//         children: [
//           AppSizedBox.sizedW10,
//           TextButton(
//             onPressed: () {
//               navigateTo(context, RecordsPage());
//             },
//             child: const Text(
//               'التحصيل',
//               style: AppTextStyle.textStyleWhiteSemiBold,
//             ),
//           ),
//           AppSizedBox.sizedW25,
//           FutureBuilder<RecordsModel>(
//             future: GetCustomerCubit.get(context).getRecords(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return SizedBox();
//               } else if (snapshot.hasError) {
//                 return SizedBox();
//               } else if (snapshot.hasData) {
//                 final recordsModel = snapshot.data!;
//                 return Text(
//                   '${recordsModel.totalAmount} \$',
//                   style: AppTextStyle.textStyleWhiteSemiBold,
//                 );
//               } else {
//                 return SizedBox();
//               }
//             },
//           ),
//           const Spacer(),
//           selectedDay != null
//               ? Text(
//                   '$selectedDay',
//                   style: AppTextStyle.textStyleWhiteSemiBold,
//                 )
//               : GestureDetector(
//                   onTap: onDateTap,
//                   child: Text(
//                     DateFormat('d/M/y').format(DateTime.now()),
//                     style: AppTextStyle.textStyleWhiteSemiBold,
//                   ),
//                 ),
//         ],
//       ),
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:client_app/Feature/customer_list/cubit/get_customer_cubit.dart';
import 'package:client_app/Feature/resources/styles/app_text_style.dart';
import 'package:client_app/Feature/resources/styles/app_sized_box.dart';
import 'package:client_app/Feature/resources/colors/colors.dart';
import 'package:client_app/Core/Helper/naviagation_helper.dart';
import 'package:client_app/Feature/customer_list/records_model/records_model.dart';
import 'package:client_app/Feature/collecting/daily_payment.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final int? selectedDay;
  final Function() onDateTap;

  const CustomAppBar({
    Key? key,
    required this.selectedDay,
    required this.onDateTap,
  }) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  late StreamSubscription<InternetConnectionStatus> _connectivitySubscription;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription =
        InternetConnectionChecker().onStatusChange.listen((status) {
      setState(() {
        _isConnected = status == InternetConnectionStatus.connected;
      });
    });

    // Initial connection check
    InternetConnectionChecker().hasConnection.then((isConnected) {
      setState(() {
        _isConnected = isConnected;
      });
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  String get connectionStatus {
    return _isConnected ? 'Online' : 'Offline';
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: AppColors.white),
      backgroundColor: const Color(0xFF0F1451),
      title: Row(
        children: [
          AppSizedBox.sizedW10,
          TextButton(
            onPressed: () {
              navigateTo(context, RecordsPage());
            },
            child: const Text(
              'التحصيل',
              style: AppTextStyle.textStyleWhiteSemiBold,
            ),
          ),
          AppSizedBox.sizedW25,
          FutureBuilder<RecordsModel>(
            future: GetCustomerCubit.get(context).getRecords(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox();
              } else if (snapshot.hasError) {
                return SizedBox();
              } else if (snapshot.hasData) {
                final recordsModel = snapshot.data!;
                return Text(
                  '${recordsModel.totalAmount} \$',
                  style: AppTextStyle.textStyleWhiteSemiBold,
                );
              } else {
                return SizedBox();
              }
            },
          ),
          const Spacer(),
          Text(
            connectionStatus,
            style: AppTextStyle.textStyleWhiteSemiBold.copyWith(
              color: _isConnected ? Colors.green : Colors.red,
            ),
          ),
          AppSizedBox.sizedW10,
          widget.selectedDay != null
              ? Text(
                  '${widget.selectedDay}',
                  style: AppTextStyle.textStyleWhiteSemiBold,
                )
              : GestureDetector(
                  onTap: widget.onDateTap,
                  child: Text(
                    DateFormat('d/M/y').format(DateTime.now()),
                    style: AppTextStyle.textStyleWhiteSemiBold,
                  ),
                ),
        ],
      ),
    );
  }
}
