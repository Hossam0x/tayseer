import 'package:flutter/material.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/default_appbar.dart';
import 'package:tayseer/my_import.dart';

class InteractionFilterPage extends StatelessWidget {
  const InteractionFilterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DefaultAppBar(
              title: 'تصفية التفاعل',
              leadingWidget: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back, size: 27.w),
              ),
            ),
          
          ],
        ),
      ),
    );
  }
}
