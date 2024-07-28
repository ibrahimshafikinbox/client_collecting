import 'package:client_app/Feature/payment/cubit/paymant_cubit.dart';
import 'package:client_app/Feature/payment/widget/refund_widget.dart';
import 'package:client_app/Feature/resources/styles/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:client_app/Feature/customer_list/cubit/get_customer_cubit.dart';
import 'package:client_app/Feature/customer_list/cubit/get_customer_state.dart';
import 'package:client_app/Feature/customer_list/records_model/records_model.dart';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  @override
  void initState() {
    super.initState();
    GetCustomerCubit.get(context).getRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GetCustomerCubit.get(context).getRecords();
        },
        child: const Icon(Icons.refresh),
      ),
      appBar: AppBar(
        title: const Text('السجلات'),
      ),
      body: BlocBuilder<GetCustomerCubit, GetCustomerState>(
        builder: (context, state) {
          if (state is GetRecordsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GetRecordsSuccess) {
            return _buildRecordsTable(state.recordsModel);
          } else if (state is GetRecordsError) {
            return Center(child: Text('خطأ: ${state.error}'));
          } else {
            return const Center(child: Text('لم يتم العثور على سجلات.'));
          }
        },
      ),
    );
  }

  Widget _buildRecordsTable(RecordsModel recordsModel) {
    return ListView(
      children: [
        if (recordsModel.records != null && recordsModel.records!.isNotEmpty)
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    "قائمة السجلات",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Center(
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: const <int, TableColumnWidth>{
                    0: FlexColumnWidth(),
                    1: FlexColumnWidth(),
                    2: FlexColumnWidth(),
                    3: FlexColumnWidth(),
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
                            child: Text(
                              'العميل',
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
                              'المبلغ',
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
                              'تاريخ الإنشاء',
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
                              'استرداد',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ...recordsModel.records!.map((record) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child: Text(record.customer?.name ?? '')),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(record.amount.toString()),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                record.createdAt != null
                                    ? DateFormat('d/M')
                                        .format(record.createdAt!)
                                    : '',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.blue,
                              ),
                              child: Center(
                                  child: TextButton(
                                child: const Text(
                                  "استرجاع ",
                                  style: AppTextStyle.textStyleMediumBlack,
                                ),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return RefundWidget(
                                        clientName: record.customer?.name ?? "",
                                        onPressed: () {
                                          PaymentCubit.get(context).postPayment(
                                              record.customer!.id, true);
                                        },
                                      );
                                    },
                                  );
                                },
                              )),
                            ),
                          ),
                        ],
                      );
                    })
                  ],
                ),
              ),
            ],
          )
        else
          const Column(
            children: [
              SizedBox(height: 100),
              Center(
                  child: Text(
                "لم يتم العثور على سجلات.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )),
            ],
          )
      ],
    );
  }
}
