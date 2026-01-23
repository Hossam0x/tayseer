// lib/features/user/my_space/presentation/view/rating_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/user/my_space/data/model/sessiondetailes/session_detailes_model.dart';
import 'package:tayseer/features/user/my_space/data/repo/my_space_repo.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/user_rate_advisor/user_rate_advisor_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/rating/user_rating_advisor_body.dart';
import 'package:tayseer/my_import.dart';

class RatingView extends StatelessWidget {
  const RatingView({super.key, required this.data});
  final SessionDetailsDataResponse data;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RateAdvisorCubit(getIt.get<MySpaceRepo>()),
      child: Scaffold(
        body: AdvisorBackground(child: RatingViewBody(data: data)),
      ),
    );
  }
}
