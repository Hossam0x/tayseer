// lib/features/user/my_space/presentation/widget/reschedule/old_session_info_widget.dart

import 'package:flutter/material.dart';
import 'package:tayseer/features/user/my_space/data/model/sessiondetailes/session_detailes_model.dart';

class OldSessionInfoWidget extends StatelessWidget {
  final SessionDetailsDataResponse oldSession;
  final bool showFullDetails;

  const OldSessionInfoWidget({
    super.key,
    required this.oldSession,
    this.showFullDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.event_note, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'بيانات الجلسة السابقة',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // التاريخ
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: 'التاريخ',
            value: oldSession.displayDate,
            isAvailable: true,
          ),
          const SizedBox(height: 8),

          // الوقت
          _buildInfoRow(
            icon: Icons.access_time,
            label: 'الوقت',
            value: oldSession.displayTime,
            isAvailable: oldSession.hasTimeInfo,
          ),
          const SizedBox(height: 8),

          // المدة
          _buildInfoRow(
            icon: Icons.timelapse,
            label: 'المدة',
            value: '${oldSession.duration} دقيقة',
            isAvailable: oldSession.duration > 0,
          ),

          if (showFullDetails) ...[
            const SizedBox(height: 8),
            // طريقة الدفع
            _buildInfoRow(
              icon: Icons.payment,
              label: 'الدفع',
              value: oldSession.paymentMethodDisplayName,
              isAvailable: oldSession.paymentMethods.isNotEmpty,
            ),
            const SizedBox(height: 8),
            // الهوية
            _buildInfoRow(
              icon: oldSession.isAnonymous
                  ? Icons.visibility_off
                  : Icons.person,
              label: 'الهوية',
              value: oldSession.isAnonymous ? 'مجهول' : 'معروف',
              isAvailable: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isAvailable,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isAvailable ? Colors.grey.shade600 : Colors.orange.shade400,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isAvailable ? Colors.black87 : Colors.grey,
              fontStyle: isAvailable ? FontStyle.normal : FontStyle.italic,
            ),
          ),
        ),
        if (!isAvailable)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'غير متاح',
              style: TextStyle(fontSize: 10, color: Colors.orange.shade700),
            ),
          ),
      ],
    );
  }
}

/// Widget مصغر لعرض الوقت فقط
class TimeDisplayWidget extends StatelessWidget {
  final SessionDetailsDataResponse session;

  const TimeDisplayWidget({Key? key, required this.session}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.access_time,
          size: 14,
          color: session.hasTimeInfo ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          session.displayTime,
          style: TextStyle(
            fontSize: 12,
            color: session.hasTimeInfo ? Colors.black87 : Colors.grey,
            fontStyle: session.hasTimeInfo
                ? FontStyle.normal
                : FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
