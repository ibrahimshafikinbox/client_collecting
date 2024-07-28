import 'package:flutter/material.dart';
import 'package:client_app/Feature/customer_list/customer_model/customer_model.dart';
import 'package:client_app/Feature/widget/customer_data.dart';
import 'package:client_app/Feature/resources/styles/app_text_style.dart';
import 'package:client_app/Feature/payment/widget/payment_Confirmatio.dart';
import 'package:client_app/Feature/payment/cubit/paymant_cubit.dart';

class CustomerTable extends StatefulWidget {
  final List<CustomerModel> customers;

  const CustomerTable({Key? key, required this.customers}) : super(key: key);

  @override
  State<CustomerTable> createState() => _CustomerTableState();
}

class _CustomerTableState extends State<CustomerTable> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              "قائمة العملاء",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Center(
          child: Table(
            border: TableBorder.all(),
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              const TableRow(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                children: [
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          'كود العميل',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          'الاسم',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          'الموقع',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'الدفع ',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              ...widget.customers.map((customer) {
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
                                  borderRadius: BorderRadius.circular(8)),
                              child: Center(
                                  child: Text(
                                customer.id?.toString() ?? '',
                                style: AppTextStyle.textStyleWhiteMedium,
                              ))),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
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
                                  detailedAddress: customer.address?.area ?? '',
                                  collectionDay:
                                      customer.collectDay?.toInt() ?? 0,
                                  amount: customer.amount ?? 0,
                                  abstainedonpress: () {},
                                  maintenanceonpress: () {},
                                );
                              },
                            );
                          },
                          child: Text(customer.name ?? ''),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(customer.address?.area ?? ''),
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
                                        clientName: customer.name ?? "",
                                        onPressed: () {
                                          PaymentCubit.get(context)
                                              .postPayment(customer.id, true);
                                        },
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                    width: 50,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Center(
                                        child: Text(
                                      '${customer.amount ?? 0}',
                                      style: AppTextStyle.textStyleWhiteMedium,
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
                                    borderRadius: BorderRadius.circular(12)),
                                child: const Center(
                                    child: Text(
                                  'تم الدفع',
                                  style: AppTextStyle.textStyleWhiteMedium,
                                ))),
                          ),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}
