import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/message_model.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/bubble/message_bubble.dart';

class MessageDetailsScreen extends StatelessWidget {
  final ChatMessage? chatMessage;
  final Message? oldMessage;
  final String readMessageIcon;
  final String deliveredMessageIcon;

  const MessageDetailsScreen({
    super.key,
    this.chatMessage,
    this.oldMessage,
    required this.readMessageIcon,
    required this.deliveredMessageIcon,
  });

  // --- المسارات والألوان ---
  static const String homeBackgroundImage = "assets/images/home_background.png";
  static const Color kBackgroundColor = Color(0xFFF9EEFA);
  static const Color kPrimaryColor = Color(0xFFD84D65);
  static const Color kTitleColor = Color(0xFF1E1B4B);

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '---';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

      String dateLabel;
      if (messageDate == today) {
        dateLabel = 'اليوم';
      } else if (messageDate == today.subtract(const Duration(days: 1))) {
        dateLabel = 'أمس';
      } else {
        dateLabel = DateFormat('d/M/yyyy', 'ar').format(dateTime);
      }
      final timeLabel = DateFormat('h:mm', 'en').format(dateTime);
      return '$timeLabel $dateLabel';
    } catch (e) {
      return dateTimeString;
    }
  }

  String _getDateLabel(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return 'اليوم';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (messageDate == today) {
        return 'اليوم';
      } else if (messageDate == today.subtract(const Duration(days: 1))) {
        return 'أمس';
      } else {
        return DateFormat('EEEE d MMMM', 'ar').format(dateTime);
      }
    } catch (e) {
      return 'اليوم';
    }
  }

  bool _checkIsMedia(ChatMessage? msg) {
    final type = msg?.messageType;
    return type == 'image' || type == 'video' || type == 'voice';
  }

  @override
  Widget build(BuildContext context) {
    log(chatMessage?.contentList.toString() ?? "No Content");

    final time = chatMessage?.createdAt ?? oldMessage?.time ?? '';
    final isRead = chatMessage?.isRead ?? true;
    final deliveredAt = chatMessage?.createdAt;
    final readAt = isRead ? (chatMessage?.createdAt) : null;

    final isMedia = _checkIsMedia(chatMessage);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'تفاصيل الرسالة',
          style: TextStyle(
            color: kTitleColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ═══════════════════════════════════════════════════════════════
              // القسم العلوي (صورة الخلفية + الرسالة)
              // ═══════════════════════════════════════════════════════════════
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(homeBackgroundImage),
                    fit: BoxFit.cover,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    _buildDateChip(_getDateLabel(time)),
                    const SizedBox(height: 24),

                    if (isMedia)
                      SizedBox(
                        height: 250,
                        width: size.width * 0.7,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: MessageBubble(
                            chatMessage: chatMessage,
                            oldMessage: oldMessage,
                            isOverlay: false,
                            isHighlighted: false,
                          ),
                        ),
                      )
                    else
                      MessageBubble(
                        chatMessage: chatMessage,
                        oldMessage: oldMessage,
                        isOverlay: false,
                        isHighlighted: false,
                      ),
                  ],
                ),
              ),

              // ═══════════════════════════════════════════════════════════════
              // القسم السفلي (تفاصيل الحالة - خلفية بيضاء)
              // ═══════════════════════════════════════════════════════════════
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    _buildStatusRow(
                      icon: deliveredMessageIcon,
                      label: 'تم الاستلام',
                      time: _formatDateTime(deliveredAt),
                      // isActive: true, // لم نعد بحاجة إليها للستايل
                    ),
                    const SizedBox(height: 24),
                    Divider(
                      color: Colors.grey.shade100,
                      height: 1,
                      thickness: 1,
                    ),
                    const SizedBox(height: 24),
                    _buildStatusRow(
                      icon: readMessageIcon,
                      label: 'قراءة',
                      time: isRead ? _formatDateTime(readAt) : '---',
                      // isActive: isRead, // لم نعد بحاجة إليها للستايل
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: kPrimaryColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  /// ✅ تم التعديل: عكس الاتجاه + تثبيت الألوان (منورة دائماً)
  Widget _buildStatusRow({
    required String icon,
    required String label,
    required String time,
    // isActive أزيلت من المنطق لأننا نريدها منورة دائماً
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 1. المجموعة الأولى (النص + الأيقونة) - تظهر يمين في العربي
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87, // أسود دائماً
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(width: 12),
            SvgPicture.asset(
              icon,
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(
                kPrimaryColor, // وردي دائماً
                BlendMode.srcIn,
              ),
            ),
          ],
        ),

        // 2. الوقت - يظهر يسار في العربي
        Text(
          time,
          style: const TextStyle(
            color: Colors.black87, // أسود دائماً
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}
