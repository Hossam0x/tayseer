import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';
import 'package:tayseer/core/widgets/custom_background.dart';
import 'package:tayseer/core/widgets/custom_button.dart';

class MarriageFilterBody extends StatefulWidget {
  const MarriageFilterBody({super.key});

  @override
  State<MarriageFilterBody> createState() => _MarriageFilterBodyState();
}

class _MarriageFilterBodyState extends State<MarriageFilterBody> {
  RangeValues ageRange = const RangeValues(22, 35);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            _buildAgeFilter(),
            _buildSection(
              title: 'الحالة الاجتماعية',
              items: ['أعزب', 'متزوج', 'مطلق', 'أرمل'],
            ),
            _buildSection(title: 'الجنسية', items: ['سعودي', 'مصري', 'أردني']),
            _buildSection(
              title: 'مكان الإقامة',
              items: ['داخل الدولة', 'خارج الدولة'],
            ),
            _buildSection(
              title: 'المؤهل',
              items: ['ثانوي', 'جامعي', 'دراسات عليا'],
            ),
            SliverToBoxAdapter(
              child: CustomBotton(
                title: context.tr('apply_filter'),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- AppBar ----------------
  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      centerTitle: true,
      title: const Text('فلتر', style: TextStyle(color: Colors.black)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  // ---------------- Age Filter ----------------
  SliverToBoxAdapter _buildAgeFilter() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'العمر',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            RangeSlider(
              values: ageRange,
              min: 18,
              max: 60,
              divisions: 42,
              labels: RangeLabels(
                ageRange.start.round().toString(),
                ageRange.end.round().toString(),
              ),
              onChanged: (value) {
                setState(() => ageRange = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Sections ----------------
  SliverToBoxAdapter _buildSection({
    required String title,
    required List<String> items,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => FilterTile(title: item)),
          ],
        ),
      ),
    );
  }
}

// ---------------- Tile ----------------
class FilterTile extends StatelessWidget {
  final String title;

  const FilterTile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
          const Icon(Icons.arrow_forward_ios, size: 14),
        ],
      ),
    );
  }
}
