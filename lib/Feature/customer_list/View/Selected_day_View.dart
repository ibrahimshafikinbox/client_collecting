import 'package:client_app/Feature/customer_notes/cubit/custoemr_notes_cubit.dart';
import 'package:client_app/Feature/payment/cubit/paymant_cubit.dart';
import 'package:client_app/Feature/payment/widget/payment_Confirmatio.dart';
import 'package:client_app/Feature/resources/styles/app_text_style.dart';
import 'package:client_app/Feature/widget/customer_data.dart';
import 'package:flutter/material.dart';
import 'package:client_app/Feature/customer_list/customer_model/customer_model.dart';

class SelectedDayCustomersPage extends StatefulWidget {
  final int selectedDay;
  final List<CustomerModel> selectedCustomers;

  const SelectedDayCustomersPage({
    super.key,
    required this.selectedDay,
    required this.selectedCustomers,
  });

  @override
  State<SelectedDayCustomersPage> createState() =>
      _SelectedDayCustomersPageState();
}

class _SelectedDayCustomersPageState extends State<SelectedDayCustomersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('قائمه العملاء لليوم: ${widget.selectedDay}'),
      ),
      body: _buildCustomerTable(widget.selectedCustomers),
    );
  }

  Widget _buildCustomerTable(List<CustomerModel> customers) {
    return ListView(
      children: [
        customers.length != 0
            ? Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        "قائمه العملاء ",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Center(
                    child: Table(
                      border: TableBorder.all(),
                      columnWidths: const <int, TableColumnWidth>{
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(3),
                        3: FlexColumnWidth(2),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        // New row with blue background and specific text
                        const TableRow(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                          ),
                          children: [
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  ' كود العميل ',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'الاسم',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'الدفع ',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Display customer data rows
                        ...customers.map((customer) {
                          return TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Container(
                                        width: 40,
                                        decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Center(
                                            child: Text(
                                          customer.id?.toString() ?? '',
                                          style:
                                              AppTextStyle.textStyleWhiteMedium,
                                        ))),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return CustomerDatatWidget(
                                          id: customer.id?.toInt() ?? 0,
                                          name: customer.name ?? '',
                                          nickname: customer.nickName ?? '',
                                          address: customer.address?.area ?? '',
                                          detailedAddress:
                                              customer.address?.area ?? '',
                                          collectionDay:
                                              customer.collectDay?.toInt() ?? 0,
                                          amount: customer.amount ?? 0,
                                          abstainedonpress: () {
                                            CustomerNotesCubit.get(context)
                                                .addNote(customer.id, 1);
                                          },
                                          maintenanceonpress: () {
                                            CustomerNotesCubit.get(context)
                                                .addNote(customer.id, 2);
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    customer.name.toString(),
                                    style: AppTextStyle.textStyleMediumBlack,
                                  ),
                                ),
                              ),
                              customer.amount != 0
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (context) {
                                                return PaymentConfirmationWidget(
                                                  clientName:
                                                      customer.name ?? "",
                                                  onPressed: () {
                                                    PaymentCubit.get(context)
                                                        .postPayment(
                                                            customer.id, false);
                                                  },
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                              width: 50,
                                              decoration: BoxDecoration(
                                                  color: Colors.blue,
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: Center(
                                                  child: Text(
                                                '${customer.amount}',
                                                style: AppTextStyle
                                                    .textStyleWhiteMedium,
                                              ))),
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: const Center(
                                              child: Text(
                                            'تم الدفع',
                                            style: AppTextStyle
                                                .textStyleWhiteMedium,
                                          ))),
                                    ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  SizedBox(height: MediaQuery.sizeOf(context).height / 3),
                  Center(
                      child: Text(
                    "No Customer For Day : ${widget.selectedDay}",
                    style: AppTextStyle.textStyleBoldBlack,
                  )),
                ],
              )
      ],
    );
  }
}
