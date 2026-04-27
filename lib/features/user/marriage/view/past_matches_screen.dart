import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/features/user/interactions/data/Model/history_response_model.dart';
import 'package:tayseer/features/user/interactions/data/repos/interactions_repository.dart';
import 'package:tayseer/my_import.dart';

class PastMatchesScreen extends StatefulWidget {
  const PastMatchesScreen({super.key});

  @override
  State<PastMatchesScreen> createState() => _PastMatchesScreenState();
}

class _PastMatchesScreenState extends State<PastMatchesScreen> {
  final _repo = getIt<InteractionsRepository>();
  List<PastMatchItem> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _repo.fetchPastMatches(page: 1);
    result.fold(
      (f) => setState(() {
        _error = f.message;
        _loading = false;
      }),
      (r) => setState(() {
        _items = r.items;
        _loading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9EEF4),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_forward_ios, size: 20),
                  ),
                  Column(
                    children: [
                      Text(
                        context.tr('past_matches'),
                        style: Styles.textStyle18SemiBold,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        context.tr('past_matches_subtitle'),
                        style: Styles.textStyle12.copyWith(
                          color: AppColors.secondary600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SizedBox(width: 20.w),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: Styles.textStyle14),
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: _load,
              child: Text(context.tr('retry')),
            ),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Text(
          context.tr('no_past_matches'),
          style: Styles.textStyle16.copyWith(color: AppColors.secondary600),
        ),
      );
    }
    return RefreshIndicator.adaptive(
      onRefresh: _load,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        itemCount: _items.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (_, i) => _PastMatchCard(item: _items[i]),
      ),
    );
  }
}

class _PastMatchCard extends StatelessWidget {
  final PastMatchItem item;
  const _PastMatchCard({required this.item});

  String _reason(BuildContext context) {
    if (item.expiredAt != null) {
      return context.tr('match_expired_duration');
    }
    return context.tr('match_ended');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Re-match button
          OutlinedButton(
            onPressed: () {
              // TODO: re-match action
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary400,
              side: BorderSide(color: AppColors.primary400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
            child: Text(
              context.tr('rematch'),
              style: Styles.textStyle12.copyWith(color: AppColors.primary400),
            ),
          ),
          SizedBox(width: 12.w),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.name,
                  style: Styles.textStyle16SemiBold,
                  textAlign: TextAlign.end,
                ),
                SizedBox(height: 4.h),
                Text(
                  _reason(context),
                  style: Styles.textStyle12.copyWith(
                    color: AppColors.secondary600,
                  ),
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          // Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary300, width: 2),
            ),
            child: CircleAvatar(
              radius: 28.r,
              backgroundImage: item.image.isNotEmpty
                  ? NetworkImage(item.image)
                  : null,
              backgroundColor: AppColors.secondary100,
              child: item.image.isEmpty
                  ? Icon(Icons.person, color: AppColors.secondary400)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
