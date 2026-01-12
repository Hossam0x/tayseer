import 'package:flutter/material.dart';
import 'package:tayseer/core/widgets/custom_background.dart';
import 'package:tayseer/features/advisor/session/view/widget/order_session_body.dart';

class OrderSessionView extends StatelessWidget {
  const OrderSessionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: CustomBackground(child: const OrderSessionBody()));
  }
}
