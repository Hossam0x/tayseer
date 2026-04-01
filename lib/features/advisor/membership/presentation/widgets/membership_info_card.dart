import 'package:tayseer/features/advisor/membership/data/models/my_subscription_model.dart';
import 'package:tayseer/my_import.dart';
import 'package:intl/intl.dart';

class MembershipInfoCard extends StatelessWidget {
  final MySubscriptionModel sub;

  const MembershipInfoCard({super.key, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            label: context.tr('subscribed_since'),
            value: _formatDate(sub.subscriptionActivatedAt),
            isFirst: true,
          ),
          _Divider(),
          _InfoRow(
            label: context.tr('subscription_status_label'),
            value: _statusText(context),
            valueColor: _statusColor(),
          ),
          if (sub.subscriptionExpiresAt != null) ...[
            _Divider(),
            _InfoRow(
              label: context.tr('next_billing_date'),
              value: _formatDate(sub.subscriptionExpiresAt),
              isLast: true,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '—';
    final dt = DateTime.tryParse(dateStr)?.toLocal();
    if (dt == null) return '—';
    return DateFormat('d MMMM yyyy', 'ar').format(dt);
  }

  String _statusText(BuildContext context) {
    if (sub.isCancelled) return context.tr('status_cancelled');
    if (sub.isExpired) return context.tr('status_ended');
    return context.tr('status_active');
  }

  Color _statusColor() {
    if (sub.isActive && !sub.isCancelled) return AppColors.kprimaryColor;
    return Colors.red.shade400;
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isFirst;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Styles.textStyle14Bold.copyWith(color: Colors.black87),
          ),
          Text(
            value,
            style: Styles.textStyle14.copyWith(
              color: valueColor ?? Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    color: Colors.grey.shade200,
    indent: 16,
    endIndent: 16,
  );
}
