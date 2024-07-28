import 'package:client_app/Feature/payment/cubit/paymant_cubit.dart';
import 'package:client_app/Feature/widget/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client_app/Feature/resources/colors/colors.dart';
import 'package:client_app/Feature/resources/styles/app_sized_box.dart';
import 'package:client_app/Feature/resources/styles/app_text_style.dart';
import 'package:client_app/Feature/payment/cubit/payment_state.dart';

class PaymentConfirmationWidget extends StatefulWidget {
  const PaymentConfirmationWidget({
    Key? key,
    required this.clientName,
    required this.onPressed,
  }) : super(key: key);

  final String clientName;
  final VoidCallback onPressed;

  @override
  State<PaymentConfirmationWidget> createState() =>
      _PaymentConfirmationWidgetState();
}

class _PaymentConfirmationWidgetState extends State<PaymentConfirmationWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentCubit, PaymentStates>(
      listener: (context, state) {
        if (state is PaymentSuccess) {
          Navigator.of(context).pop(); // Close the bottom sheet on success
          showCustomDialog(context, "تمت بنجاح");
        } else if (state is PaymentFailure) {
          showCustomDialog(context, "فشلت العملية،");

          // showToast(
          //     text: "فشلت العملية، يرجى المحاولة مرة أخرى.",
          //     state: ToastStates.ERROR);
        } else if (state is Paymentaddeddtoqueuee) {
          showCustomDialog(context, "تمت الاضافه الى قائمه الانتظار ");

          // showToast(
          //     text: "فشلت العملية، يرجى المحاولة مرة أخرى.",
          //     state: ToastStates.ERROR);
        }
      },
      builder: (context, state) {
        bool isLoading = state is PaymentLoading;

        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 3,
          child: ListView(
            children: [
              Container(
                height: 80,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 71, 70, 70),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text(
                        "تاكيد الدفع  ",
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
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "تاكيد الدفع",
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
                    " ${widget.clientName} ",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              AppSizedBox.sizedH20,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: isLoading
                        ? null
                        : widget.onPressed, // Disable tap when loading
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isLoading
                            ? Colors.grey
                            : Colors.green, // Change color when loading
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "دفع",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
