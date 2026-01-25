import 'package:tayseer/features/user/my_space/data/repo/my_space_repo.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/advisor_profile/advisor_profile_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/advisorProfile/advisor_information_body.dart';
import 'package:tayseer/my_import.dart';

class AdvisorInformation extends StatefulWidget {
  const AdvisorInformation({super.key, required this.userid});
  final String userid;

  @override
  State<AdvisorInformation> createState() => _AdvisorInformationState();
}

class _AdvisorInformationState extends State<AdvisorInformation> {
  late AdvisorProfileCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = AdvisorProfileCubit(getIt<MySpaceRepo>());
    _cubit.fetchAdvisorProfile(widget.userid);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: AdvisorInformationBody(userid: widget.userid),
    );
  }
}
