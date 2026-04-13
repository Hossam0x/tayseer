import 'package:tayseer/features/user/marriage_filter/view/widget/marriage_filter_view_body.dart';
import 'package:tayseer/features/user/marriage_filter/view_models/marriage_filter_cubit.dart';
import 'package:tayseer/features/user/user_profile/presentation/view_model/user_packages_cubit.dart';
import 'package:tayseer/core/widgets/custom_show_dialog.dart';
import 'package:tayseer/my_import.dart';

class MarriageFilterView extends StatelessWidget {
  const MarriageFilterView({super.key});

  void _onBackPressed(BuildContext context) {
    final cubit = context.read<MarriageFilterCubit>();
    final state = cubit.state;

    final hasFilters =
        state.selectedFilters.isNotEmpty ||
        state.ageRange != const RangeValues(22, 35);

    if (!hasFilters) {
      context.pop();
      return;
    }

    CustomshowDialogWithImage(
      context,
      title: context.tr("filter_profiles"),
      supTitle: context.tr("apply_filters"),
      imageUrl: AssetsData.kWoriningImage,
      bottonText: context.tr("no"),
      cancelText: context.tr("yes"),
      showCancelButton: true,
      onPressed: () {
        Navigator.pop(context); // ✅ ارجع من صفحة الفلتر
      },
      onCancel: () async {
        final cachedSub = await UserPackagesCubit.getCachedSubType();
        final isFree = cachedSub == null;
        if (!context.mounted) return;
        if (isFree) {
          showFiltterLimitDialogs(
            context,
            onSubscribe: () => context.pushNamed(AppRouter.kUserPackagesView),
          );
        } else {
          cubit.sendMarriageFilter();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => MarriageFilterCubit(),
        child: Builder(
          builder: (context) {
            return WillPopScope(
              onWillPop: () async {
                final cubit = context.read<MarriageFilterCubit>();
                if (cubit.state.marriageFilterStatus == CubitStates.success) {
                  return true; // ✅ ارجع عادي
                }
                _onBackPressed(context);
                return false;
              },
              child: MarriageFilterBody(
                onBackPressed: () => _onBackPressed(context),
              ),
            );
          },
        ),
      ),
    );
  }
}
