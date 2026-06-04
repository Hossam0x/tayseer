import 'package:tayseer/features/user/my_space/data/model/sessiondetailes/session_detailes_model.dart';
import 'package:tayseer/my_import.dart';

class PackageDetailsCard extends StatelessWidget {
  final SessionCreditModel sessionCredit;
  final VoidCallback onScheduleSession;

  const PackageDetailsCard({
    super.key,
    required this.sessionCredit,
    required this.onScheduleSession,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        sessionCredit.creditLeft,
        (index) => Padding(
          padding: EdgeInsets.only(
            bottom: index < sessionCredit.creditLeft - 1 ? 12.h : 0,
          ),
          child: _PackageSessionRow(
            offerName: sessionCredit.offerName,
            onSchedule: onScheduleSession,
          ),
        ),
      ),
    );
  }
}

class _PackageSessionRow extends StatelessWidget {
  final String offerName;
  final VoidCallback onSchedule;

  const _PackageSessionRow({required this.offerName, required this.onSchedule});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              offerName,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(width: 12.w),
          CustomBotton(
            width: context.width * 0.30,
            useGradient: true,
            title: context.tr('schedule_appointment'),
            onPressed: onSchedule,
          ),
        ],
      ),
    );
  }
}
