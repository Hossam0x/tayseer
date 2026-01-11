import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/session/view/widget/custom_sliver_app_bar_session.dart';

class SessionDetailsBody extends StatelessWidget {
  const SessionDetailsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        CustomSliverAppBarSession(
          title: context.tr("session_details"),
          showBackButton: true,
        ),

        // ---------- بيانات الشخص ----------
        const SliverToBoxAdapter(child: SectionTitle(title: 'بيانات الشخص')),
        SliverToBoxAdapter(
          child: PersonalInfoCard(
            name: 'أحمد منصور',
            handle: '@fdtgsyhujkl',
            avatarUrl: 'https://i.pravatar.cc/150?img=5',
          ),
        ),

        // ---------- بيانات الجلسة ----------
        const SliverToBoxAdapter(child: SectionTitle(title: 'بيانات الجلسة')),
        SliverToBoxAdapter(
          child: SessionInfoCard(
            dateText: 'اليوم ، 2 يناير',
            timeText: '03:00 م - 04:00 م',
          ),
        ),

        // ---------- بيانات السعر ----------
        const SliverToBoxAdapter(child: SectionTitle(title: 'بيانات السعر')),
        SliverToBoxAdapter(
          child: PriceInfoCard(
            rows: [
              PriceRow(label: 'سعر الجلسة', value: '180 ر.س'),
              PriceRow(label: 'الرسوم', value: '10 ر.س'),
              PriceRow(label: 'ضريبة القيمة المضافة', value: '20 ر.س'),
              PriceRow(label: 'رسوم التطبيق', value: '-30 ر.س'),
              PriceRow(label: 'الخصم', value: '-50 ر.س'),
            ],
            totalLabel: 'الإجمالي',
            totalValue: '150 ر.س',
          ),
        ),

        // ---------- مسافة إضافية أسفل ----------
        const SliverToBoxAdapter(child: Gap(20)),
      ],
    );
  }
}

/// عنوان كل قسم
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        context.height * 0.02,
        16,
        context.height * 0.01,
      ),
      child: Text(
        title,
        style: Styles.textStyle16.copyWith(
          color: const Color(0xFF5D6268),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// بطاقة بيانات الشخص
class PersonalInfoCard extends StatelessWidget {
  final String name;
  final String handle;
  final String avatarUrl;

  const PersonalInfoCard({
    super.key,
    required this.name,
    required this.handle,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: context.height * 0.01,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: context.height * 0.015,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(25),
            child: AppImage(
              avatarUrl,
              width: context.width * 0.1,
              height: context.height * 0.06,
            ),
          ),
          const Gap(12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Styles.textStyle16.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(4),
              Text(
                handle,
                style: Styles.textStyle12.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// بطاقة بيانات الجلسة (تاريخ + وقت)
class SessionInfoCard extends StatelessWidget {
  final String dateText;
  final String timeText;

  const SessionInfoCard({
    super.key,
    required this.dateText,
    required this.timeText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: context.height * 0.01,
      ),
      padding: EdgeInsets.all(context.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: context.width * 0.045,
                color: Colors.grey,
              ),
              const Gap(8),
              Flexible(
                child: Text(
                  dateText,
                  style: Styles.textStyle14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Gap(12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: context.width * 0.045,
                color: Colors.grey,
              ),
              const Gap(8),
              Flexible(
                child: Text(
                  timeText,
                  style: Styles.textStyle14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// نموذج صف في قسم السعر
class PriceRow {
  final String label;
  final String value;
  PriceRow({required this.label, required this.value});
}

/// بطاقة بيانات السعر
class PriceInfoCard extends StatelessWidget {
  final List<PriceRow> rows;
  final String totalLabel;
  final String totalValue;

  const PriceInfoCard({
    super.key,
    required this.rows,
    required this.totalLabel,
    required this.totalValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: context.height * 0.01,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: context.height * 0.02,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          ...rows.map(
            (r) => Padding(
              padding: EdgeInsets.symmetric(vertical: context.height * 0.006),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(r.label, style: Styles.textStyle14),
                  Text(r.value, style: Styles.textStyle14),
                ],
              ),
            ),
          ),
          const Gap(8),
          const Divider(color: Color(0xFFEEEEEE)),
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                totalLabel,
                style: Styles.textStyle16.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                totalValue,
                style: Styles.textStyle16.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD64D65),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
