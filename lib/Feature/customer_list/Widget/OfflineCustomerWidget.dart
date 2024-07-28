// import 'package:client_app/Feature/customer_list/cubit/get_customer_cubit.dart';
// import 'package:client_app/Feature/customer_list/cubit/get_customer_state.dart';
// import 'package:client_app/Feature/customer_list/customer_model/customer_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class CustomerListScreen extends StatefulWidget {
//   @override
//   State<CustomerListScreen> createState() => _CustomerListScreenState();
// }

// class _CustomerListScreenState extends State<CustomerListScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Customer List'),
//       ),
//       body: BlocBuilder<GetCustomerCubit, GetCustomerState>(
//         builder: (context, state) {
//           if (state is GetCustomerLoading) {
//             return Center(child: CircularProgressIndicator());
//           } else if (state is GetCustomerSuccess) {
//             final List<CustomerModel> customers = state.customers;
//             if (customers.isEmpty) {
//               return Center(child: Text('No customers found'));
//             }
//             return ListView.builder(
//               itemCount: customers.length,
//               itemBuilder: (context, index) {
//                 final CustomerModel customer = customers[index];
//                 return ListTile(
//                   title: Text("${customer.name}"),
//                   subtitle: Text(
//                     'Collect Day: ${customer.collectDay}\n'
//                     'Phone: ${customer.phone}\n'
//                     'Address Area: ${customer.address?.area}',
//                   ),
//                 );
//               },
//             );
//           } else if (state is GetCustomerError) {
//             return Center(child: Text('Failed to load customers:}'));
//           } else {
//             return Center(child: Text('No data available'));
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           context.read<GetCustomerCubit>().getCustomer();
//         },
//         child: Icon(Icons.refresh),
//       ),
//     );
//   }
// }
