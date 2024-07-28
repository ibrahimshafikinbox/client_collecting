// import 'package:client_app/Core/Helper/naviagation_helper.dart';
// import 'package:client_app/Feature/collecting/daily_payment.dart';
// import 'package:client_app/Feature/customer_list/cubit/get_customer_cubit.dart';
// import 'package:client_app/Feature/customer_list/records_model/records_model.dart';
// import 'package:client_app/Feature/resources/colors/colors.dart';
// import 'package:client_app/Feature/resources/styles/app_sized_box.dart';
// import 'package:client_app/Feature/resources/styles/app_text_style.dart';
// import 'package:flutter/material.dart';

// AppBar custom_appBar(BuildContext context) {
//     return AppBar(
//       iconTheme: IconThemeData(color: AppColors.white),
//       backgroundColor: Color(0xFF0F1451),
//       title: Row(
//         children: [
//           AppSizedBox.sizedW10,
//           TextButton(
//             onPressed: () {
//               navigateTo(context, RecordsPage());
//             },
//             child: Text(
//               'التحصيل',
//               style: AppTextStyle.textStyleWhiteSemiBold,
//             ),
//           ),
//           AppSizedBox.sizedW25,
//           FutureBuilder<RecordsModel>(
//             future: GetCustomerCubit.get(context)
//                 .getRecords(), // Your future function
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 // While the Future is being fetched
//                 return CircularProgressIndicator(
//                   color: Colors.white,
//                 );
//               } else if (snapshot.hasError) {
//                 // If an error occurred while fetching the data
//                 return Text(
//                   'Error', // Optionally show the error
//                   style: AppTextStyle.textStyleWhiteSemiBold,
//                 );
//               } else if (snapshot.hasData) {
//                 // If data was successfully fetched
//                 final recordsModel = snapshot.data!;
//                 return Text(
//                   '${recordsModel.totalAmount} \$',
//                   style: AppTextStyle.textStyleWhiteSemiBold,
//                 );
//               } else {
//                 return Text("Error");
//               }
//             },
//           ),
//           Spacer(),
//           _selectedDay != null
//               ? Text(
//                   '$_selectedDay',
//                   style: AppTextStyle.textStyleWhiteSemiBold,
//                 )
//               : GestureDetector(
//                   onTap: () {
//                     _showCollectionDayPicker(context);
//                   },
//                   child: Text(
//                     DateFormat('d/M/y').format(DateTime.now()),
//                     style: AppTextStyle.textStyleWhiteSemiBold,
//                   ),
//                 ),
//         ],
//       ),
//     );
//   }
