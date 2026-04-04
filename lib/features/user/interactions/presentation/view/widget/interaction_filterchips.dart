import 'package:tayseer/my_import.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_state.dart';

class FilterChips extends StatefulWidget {
  final Function(String)? onFilterChanged;
  const FilterChips({super.key, this.onFilterChanged});

  @override
  _FilterChipsState createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  late final List<FilterItem> _filters;
  String _selectedFilterKey = "liked_you";

  @override
  void initState() {
    super.initState();
    _filters = [
      FilterItem(key: "favorites", labelKey: "favorites"),
      FilterItem(key: "liked_you", labelKey: "liked_you"),
      FilterItem(key: "met_them", labelKey: "met_them"),
      FilterItem(key: "sent_compliment", labelKey: "sent_compliment"),
    ];

  
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onFilterChanged?.call(_selectedFilterKey);
    });
  }

  int _getCountForFilter(String key, InteractionsState state) {
    switch (key) {
      case 'liked_you':
        return state.likesNotificationCount;
      case 'favorites':
        return state.favoritesNotificationCount;
      case 'sent_compliment':
        return state.regardsNotificationCount;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InteractionsCubit, InteractionsState>(
      buildWhen: (prev, curr) =>
          prev.likesNotificationCount != curr.likesNotificationCount ||
          prev.favoritesNotificationCount != curr.favoritesNotificationCount ||
          prev.regardsNotificationCount != curr.regardsNotificationCount,
      builder: (context, state) {
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: context.width * 0.07,
            vertical: 7.h,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12.0.r),
            border: Border.all(color: Color(0xffF9F8EC), width: 1.0.w),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _filters.map((filter) {
              final bool isSelected = _selectedFilterKey == filter.key;
              final int count = _getCountForFilter(filter.key, state);

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilterKey = filter.key;
                    });
                    widget.onFilterChanged?.call(filter.key);

                    // Reset notification count when tab is opened
                    if (count > 0) {
                      context
                          .read<InteractionsCubit>()
                          .resetNotificationCountForFilter(filter.key);
                    }
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary100
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.0.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15.0.h),
                    alignment: Alignment.center,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Text(
                          context.tr(filter.labelKey),
                          textAlign: TextAlign.center,
                          style: isSelected
                              ? Styles.textStyle14.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary800,
                                )
                              : Styles.textStyle14.copyWith(
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.secondary600,
                                ),
                        ),
                        if (count > 0)
                          Positioned(
                            top: -8.h,
                            right: -12.w,
                            child: Container(
                              padding: EdgeInsets.all(3.r),
                              constraints: BoxConstraints(
                                minWidth: 16.w,
                                minHeight: 16.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                count > 99 ? '99+' : '$count',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
class FilterItem {
  final String key;
  final String labelKey;

  FilterItem({required this.key, required this.labelKey});
}