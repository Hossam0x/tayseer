import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/my_import.dart';

/// Helper class للـ dialogs المشتركة في chat rooms
/// يستخدم نفس تصميم show_confirmation_dialog
class ChatRoomDialogHelper {
  /// عرض dialog تأكيد الحذف
  static void showDeleteDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
    String? title,
    String? subtitle,
  }) {
    _showConfirmationDialog(
      context: context,
      imagePath: AssetsData.deleteIcon,
      title: title ?? 'حذف المحادثة',
      subtitle: subtitle ?? 'هل أنت متأكد من حذف هذه المحادثة؟',
      onConfirm: onConfirm,
    );
  }

  /// عرض dialog تأكيد الأرشفة
  static void showArchiveDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
    String? title,
    String? subtitle,
  }) {
    _showConfirmationDialog(
      context: context,
      imagePath: AssetsData.chatArchiveIcon,
      title: title ?? 'أرشفة المحادثة',
      subtitle: subtitle ?? 'هل أنت متأكد من أرشفة هذه المحادثة؟',
      onConfirm: onConfirm,
    );
  }

  /// عرض dialog تأكيد الإبلاغ
  static void showReportDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
    String? title,
    String? subtitle,
  }) {
    _showConfirmationDialog(
      context: context,
      imagePath: AssetsData.reportIcon,
      title: title ?? 'إبلاغ',
      subtitle: subtitle ?? 'هل تريد الإبلاغ عن هذه المحادثة؟',
      onConfirm: onConfirm,
    );
  }

  /// عرض dialog تأكيد الحظر
  static void showBlockDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
    String? title,
    String? subtitle,
  }) {
    _showConfirmationDialog(
      context: context,
      imagePath: AssetsData.deleteIcon,
      title: title ?? 'حظر المستخدم',
      subtitle: subtitle ?? 'هل أنت متأكد من حظر هذا المستخدم؟',
      onConfirm: onConfirm,
    );
  }

  /// عرض dialog تأكيد إلغاء الحظر
  static void showUnblockDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
    String? title,
    String? subtitle,
  }) {
    _showConfirmationDialog(
      context: context,
      imagePath: AssetsData.deleteIcon,
      title: title ?? 'إلغاء حظر المستخدم',
      subtitle: subtitle ?? 'هل أنت متأكد من إلغاء حظر هذا المستخدم؟',
      onConfirm: onConfirm,
    );
  }

  /// Dialog موحد بنفس تصميم show_confirmation_dialog
  static void _showConfirmationDialog({
    required BuildContext context,
    required String imagePath,
    required String title,
    required String subtitle,
    required VoidCallback onConfirm,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'confirmation',
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return ScaleTransition(
          scale: curvedAnimation,
          child: FadeTransition(
            opacity: animation,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 396,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  image: DecorationImage(
                    image: AssetImage(AssetsData.homeBackgroundImage),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    AppImage(imagePath, width: 76, fit: BoxFit.cover),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              onConfirm();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2ECC71),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              context.tr('yes'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE74C3C),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              context.tr('no'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
