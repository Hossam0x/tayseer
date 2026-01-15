import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/my_space/my_state_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/my_space_view_body.dart';
import 'package:tayseer/my_import.dart';

class MySpaceView extends StatelessWidget {
  const MySpaceView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MySpaceCubit>(
      create: (context) => getIt<MySpaceCubit>(),
      child: const Scaffold(body: MySpaceViewBody()),
    );
  }
}
