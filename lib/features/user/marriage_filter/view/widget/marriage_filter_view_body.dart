import 'package:tayseer/features/user/marriage_filter/view/widget/custom_data_card.dart';
import 'package:tayseer/features/user/marriage_filter/view/widget/filter_selection_body.dart';
import 'package:tayseer/features/user/marriage_filter/view_models/marriage_filter_cubit.dart';
import 'package:tayseer/features/user/marriage_filter/view_models/marriage_filter_state.dart';
import 'package:tayseer/my_import.dart';

class MarriageFilterBody extends StatelessWidget {
  const MarriageFilterBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MarriageFilterCubit(),
      child: CustomBackground(
        child: BlocBuilder<MarriageFilterCubit, MarriageFilterState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                _buildSliverAppBar(context),

                // 1. قسم العمر والبلد
                SliverToBoxAdapter(
                  child: _buildAgeAndCountrySection(context, state),
                ),

                // 2. قسم بيانات وأنشطة
                SliverToBoxAdapter(
                  child: CustomDataCard(
                    sectionTitle: "بيانات وأنشطة 🔥",
                    items: [
                      _buildRow(context, "cv", "cv"),
                      _buildRow(context, "verified_id", "verified_id"),
                      _buildRow(context, "recently_online", "recently_online"),
                      _buildRow(context, "gold_account", "gold_account"),
                      _buildRow(context, "new_member", "new_member"),
                      _buildRow(context, "photo_status", "photo_status"),
                    ],
                  ),
                ),

                // 3. قسم بيانات شخصية
                SliverToBoxAdapter(
                  child: CustomDataCard(
                    sectionTitle: "بيانات شخصية",
                    items: [
                      _buildRow(context, "height", "height"),
                      _buildRow(context, "marital_status", "marital_status"),
                      _buildRow(context, "job", "job"),
                      _buildRow(context, "education", "education"),
                      _buildRow(context, "hobbies", "hobbies"),
                    ],
                  ),
                ),

                // 4. قسم الأهداف
                SliverToBoxAdapter(
                  child: CustomDataCard(
                    sectionTitle: "الأهداف",
                    items: [
                      _buildRow(context, "marriage_goal", "marriage"),
                      _buildRow(context, "engagement_goal", "engagement"),
                      _buildRow(context, "travel_goal", "travel"),
                      _buildRow(context, "family_goal", "family"),
                    ],
                  ),
                ),
                // 5. قسم الدين والعادات
                SliverToBoxAdapter(
                  child: CustomDataCard(
                    sectionTitle: "الدين والعادات",
                    items: [
                      _buildRow(
                        context,
                        "religious_commitment",
                        "religious_commitment",
                      ),
                      _buildRow(context, "alcohol", "alcohol"),
                      _buildRow(context, "smoking", "smoking"),
                      _buildRow(context, "hijab", "hijab"),
                    ],
                  ),
                ),

                const SliverPadding(padding: EdgeInsets.only(bottom: 20)),

                // زر التطبيق
                _buildApplyButton(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  // ميثود بناء السطر وربطه بشاشة الاختيار
  FilterItemModel _buildRow(
    BuildContext context,
    String title,
    String fieldKey,
  ) {
    final state = context.read<MarriageFilterCubit>().state;
    final value = state.selectedFilters[fieldKey];

    // منطق عرض القيمة
    String displayValue = "لا يوجد تفضيل";
    if (value is String) displayValue = context.tr(value);
    if (value is List) displayValue = "${value.length} مختارة";

    return FilterItemModel(
      title: context.tr(title),
      value: displayValue,
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                FilterSelectionScreen(fieldKey: fieldKey, initialValue: value),
          ),
        );
        if (result != null) {
          context.read<MarriageFilterCubit>().updateField(fieldKey, result);
        }
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(context.tr('filter_profiles'), style: Styles.textStyle18Bold),
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.grey),
        onPressed: () => context.pop(),
      ),
      actions: [
        TextButton(
          onPressed: () => context.read<MarriageFilterCubit>().resetFilters(),
          child: Text(
            context.tr('clear_filters'),
            style: Styles.textStyle14.copyWith(
              color: Colors.grey[700],
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeAndCountrySection(
    BuildContext context,
    MarriageFilterState state,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("العمر", style: Styles.textStyle16Bold),
          const SizedBox(height: 10),

          // استخدام SliderTheme لتخصيص شكل الدوائر والـ Tooltip (نفس الديزاين الخاص بك)
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              rangeThumbShape: const RoundRangeSliderThumbShape(
                enabledThumbRadius: 12,
                elevation: 4,
                pressedElevation: 6,
              ),
              thumbColor: Colors.white,
              activeTrackColor: const Color(0xFFE91E63),
              inactiveTrackColor: Colors.grey[200],

              showValueIndicator: ShowValueIndicator.always,
              valueIndicatorColor: Colors.pink[50],
              valueIndicatorTextStyle: const TextStyle(
                color: Color(0xFF535353),
                fontWeight: FontWeight.bold,
              ),
              rangeValueIndicatorShape:
                  const PaddleRangeSliderValueIndicatorShape(),
            ),
            child: RangeSlider(
              values: state.ageRange,
              min: 18,
              max: 60,
              labels: RangeLabels(
                state.ageRange.start.round().toString(),
                state.ageRange.end.round().toString(),
              ),
              onChanged: (values) {
                // تحديث الـ Cubit مباشرة بدل الـ setState
                context.read<MarriageFilterCubit>().updateAgeRange(values);
              },
            ),
          ),

          const Divider(height: 30, thickness: 0.8),
          _buildInternalRow(context, "البلد", "country"),
          const Divider(height: 30, thickness: 0.8),
          _buildInternalRow(context, "الجنسية", "nationality"),
        ],
      ),
    );
  }

  // ميثود مساعدة لربط الصفوف الداخلية (البلد والجنسية) بـ Cubit وشاشة الاختيار
  Widget _buildInternalRow(
    BuildContext context,
    String title,
    String fieldKey,
  ) {
    final state = context.read<MarriageFilterCubit>().state;
    final value = state.selectedFilters[fieldKey];

    // تحديد النص المعروض (قيمة مختارة أو قيمة افتراضية)
    String displayValue = "لا يوجد تفضيل";
    if (value != null) {
      displayValue = context.tr(value.toString());
    } else {
      if (fieldKey == 'country') displayValue = "مصر";
      if (fieldKey == 'nationality') displayValue = "مصري";
    }

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                FilterSelectionScreen(fieldKey: fieldKey, initialValue: value),
          ),
        );
        if (result != null) {
          context.read<MarriageFilterCubit>().updateField(fieldKey, result);
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Styles.textStyle16.copyWith(fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Text(
                displayValue,
                style: Styles.textStyle14.copyWith(color: Colors.grey[600]),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton(BuildContext context, MarriageFilterState state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Center(
          child: CustomBotton(
            width: context.width * 0.9,
            title: context.tr('apply_filters'),
            onPressed: () {
              // هنا الداتا كاملة جاهزة للإرسال للسيرفر
              print("Age: ${state.ageRange}");
              print("Filters: ${state.selectedFilters}");
            },
          ),
        ),
      ),
    );
  }
}
