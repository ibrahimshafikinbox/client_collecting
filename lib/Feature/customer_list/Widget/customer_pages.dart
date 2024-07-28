import 'package:flutter/material.dart';
import 'package:client_app/Feature/customer_list/customer_model/customer_model.dart';
import 'customer_table.dart';
import 'page_controls.dart';

class CustomerPages extends StatefulWidget {
  final List<CustomerModel> customers;

  const CustomerPages({Key? key, required this.customers}) : super(key: key);

  @override
  State<CustomerPages> createState() => _CustomerPagesState();
}

class _CustomerPagesState extends State<CustomerPages> {
  int _currentPageIndex = 0;
  final int _customersPerPage = 10;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalPageCount = (widget.customers.length / _customersPerPage).ceil();

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalPageCount,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            itemBuilder: (context, pageIndex) {
              final start = pageIndex * _customersPerPage;
              final end = start + _customersPerPage;
              final currentPageCustomers = widget.customers.sublist(
                  start,
                  end < widget.customers.length
                      ? end
                      : widget.customers.length);
              return CustomerTable(customers: currentPageCustomers);
            },
          ),
        ),
        PageControls(
          currentPageIndex: _currentPageIndex,
          totalPageCount: totalPageCount,
          onPageChanged: (index) {
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      ],
    );
  }
}
