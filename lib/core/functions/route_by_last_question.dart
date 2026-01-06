import '../../my_import.dart';

String routeByLastQuestion(int? lastQuestionNumber) {
  switch (lastQuestionNumber) {
    case 1:
      return AppRouter.kChooseGenderView;
    case 2:
      return AppRouter.kNationalityView;
    case 3:
      return AppRouter.kCountryView;
    case 4:
      return AppRouter.kChooseAgeView;
    case 5:
      return AppRouter.kSocialStatusView;
    case 6:
      return AppRouter.kChooseWeightView;
    case 7:
      return AppRouter.kChooseHeightView;
    case 8:
      return AppRouter.kSkinColorView;
    case 9:
      return AppRouter.kSmokingView;
    case 10:
      return AppRouter.kReligiousCommitmentView;
    case 11:
      return AppRouter.kHasChildrenView;
    case 12:
      return AppRouter.kChildrenNumberView;
    case 13:
      return AppRouter.kChildrenLivingStatusView;
    case 14:
      return AppRouter.kEducationLevelView;
    case 15:
      return AppRouter.kChooseJobView;
    case 16:
      return AppRouter.kChooseEmployerView;
    case 17:
      return AppRouter.kAcceptMarriedView;
    case 18:
      return AppRouter.kHealthStatusView;
    case 19:
      return AppRouter.kHobbiesView;
    case 20:
      return AppRouter.kAddYourCvView;

    default:
      return AppRouter.kChooseGenderView;
  }
}
