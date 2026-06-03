import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/message_model.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/data/repo/chat_repo_simple.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/message_details_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/bubble/message_bubble.dart';
import 'package:tayseer/my_import.dart';

/// Entry point — wraps the screen in its own BlocProvider so the cubit
/// lifetime is scoped to this route only.
class MessageDetailsScreen extends StatelessWidget {
  final ChatMessage? chatMessage;
  final Message? oldMessage;
  final String readMessageIcon;
  final String deliveredMessageIcon;
  // ✅ لو في حظر بأي اتجاه → يُخفى React و Reply
  final bool isBlocked;

  const MessageDetailsScreen({
    super.key,
    this.chatMessage,
    this.oldMessage,
    required this.readMessageIcon,
    required this.deliveredMessageIcon,
    this.isBlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MessageDetailsCubit(getIt<ChatRepoSimple>())
            ..load(chatMessage?.id ?? ''),
      child: _MessageDetailsBody(
        chatMessage: chatMessage,
        oldMessage: oldMessage,
        readMessageIcon: readMessageIcon,
        deliveredMessageIcon: deliveredMessageIcon,
        isBlocked: isBlocked,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private body widget
// ─────────────────────────────────────────────────────────────────────────────

class _MessageDetailsBody extends StatelessWidget {
  final ChatMessage? chatMessage;
  final Message? oldMessage;
  final String readMessageIcon;
  final String deliveredMessageIcon;
  final bool isBlocked;

  // --- الألوان الثابتة ---
  static const String _homeBackgroundImage =
      "assets/images/home_background.png";
  static const Color _kBackgroundColor = Color(0xFFF9EEFA);
  static const Color _kPrimaryColor = Color(0xFFD84D65);
  static const Color _kTitleColor = Color(0xFF1E1B4B);

  const _MessageDetailsBody({
    this.chatMessage,
    this.oldMessage,
    required this.readMessageIcon,
    required this.deliveredMessageIcon,
    this.isBlocked = false,
  });

  // ─── Formatting helpers ──────────────────────────────────────────────────

  /// Formats a [DateTime] as "h:mm Today / Yesterday / d/M/yyyy".
  String _formatDateTime(DateTime? dt, BuildContext context) {
    if (dt == null) return '---';
    return '${DateFormat('h:mm', isArabic ? 'ar' : 'en').format(dt.toLocal())} ${_dateLabel(dt, context)}';
  }

  String _dateLabel(DateTime dt, BuildContext context) {
    final local = dt.toLocal();
    final today = DateTime.now();
    final d = DateTime(local.year, local.month, local.day);
    final t = DateTime(today.year, today.month, today.day);
    if (d == t) return context.tr('date_today');
    if (d == t.subtract(const Duration(days: 1))) {
      return context.tr('date_yesterday');
    }
    return DateFormat('d/M/yyyy').format(local);
  }

  /// Formats the date chip label at the top of the bubble section.
  String _getDateChipLabel(String? dateTimeString, BuildContext context) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return context.tr('date_today');
    }
    try {
      final dt = DateTime.parse(dateTimeString).toLocal();
      return _dateLabel(dt, context);
    } catch (_) {
      return context.tr('date_today');
    }
  }

  bool _checkIsMedia(ChatMessage? msg) {
    final t = msg?.messageType;
    return t == 'image' || t == 'video' || t == 'voice';
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    log(chatMessage?.contentList.toString() ?? 'No Content');

    final time = chatMessage?.createdAt ?? oldMessage?.time ?? '';
    final isMedia = _checkIsMedia(chatMessage);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _kBackgroundColor,
      appBar: AppBar(
        backgroundColor: _kBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('message_details_title'),
          style: const TextStyle(
            color: _kTitleColor,
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
              // ── Message bubble section ──────────────────────────────────
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(_homeBackgroundImage),
                    fit: BoxFit.cover,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    _buildDateChip(_getDateChipLabel(time, context)),
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

              // ── Status / details section ────────────────────────────────
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
                child: BlocBuilder<MessageDetailsCubit, MessageDetailsState>(
                  builder: (context, state) {
                    if (state is MessageDetailsLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (state is MessageDetailsError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            // ── Fallback static rows from local message data ─
                            _buildStatusRow(
                              context: context,
                              icon: deliveredMessageIcon,
                              label: context.tr('delivered_status'),
                              time: chatMessage?.createdAt != null
                                  ? _formatDateTime(
                                      DateTime.tryParse(chatMessage!.createdAt),
                                      context,
                                    )
                                  : '---',
                            ),
                            const SizedBox(height: 24),
                            Divider(
                              color: Colors.grey.shade100,
                              height: 1,
                              thickness: 1,
                            ),
                            const SizedBox(height: 24),
                            _buildStatusRow(
                              context: context,
                              icon: readMessageIcon,
                              label: context.tr('read_status'),
                              time: (chatMessage?.isRead ?? false)
                                  ? _formatDateTime(
                                      DateTime.tryParse(chatMessage!.createdAt),
                                      context,
                                    )
                                  : context.tr('not_read_yet'),
                            ),
                            const SizedBox(height: 16),
                            // ── Error message ───────────────────────────────
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade400,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      context.tr('details_load_error'),
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 12,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => context
                                        .read<MessageDetailsCubit>()
                                        .load(chatMessage?.id ?? ''),
                                    child: Icon(
                                      Icons.refresh,
                                      color: Colors.red.shade400,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isBlocked) ...[
                              const SizedBox(height: 24),
                              Divider(
                                color: Colors.grey.shade100,
                                height: 1,
                                thickness: 1,
                              ),
                              const SizedBox(height: 24),
                              _buildActionRow(context),
                            ],
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    }

                    // ── Loaded state ─────────────────────────────────────
                    final details = state is MessageDetailsLoaded
                        ? state.details
                        : null;

                    return Column(
                      children: [
                        _buildStatusRow(
                          context: context,
                          icon: deliveredMessageIcon,
                          label: context.tr('delivered_status'),
                          time: _formatDateTime(details?.receivedAt, context),
                        ),
                        const SizedBox(height: 24),
                        Divider(
                          color: Colors.grey.shade100,
                          height: 1,
                          thickness: 1,
                        ),
                        const SizedBox(height: 24),
                        _buildStatusRow(
                          context: context,
                          icon: readMessageIcon,
                          label: context.tr('read_status'),
                          time: details?.readAt != null
                              ? _formatDateTime(details!.readAt, context)
                              : context.tr('not_read_yet'),
                        ),
                        // ✅ React و Reply يُخفيان عند وجود حظر بأي اتجاه
                        if (!isBlocked) ...[
                          const SizedBox(height: 24),
                          Divider(
                            color: Colors.grey.shade100,
                            height: 1,
                            thickness: 1,
                          ),
                          const SizedBox(height: 24),
                          _buildActionRow(context),
                        ],
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Shared widgets ───────────────────────────────────────────────────────

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
          color: _kPrimaryColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  Widget _buildStatusRow({
    required BuildContext context,
    required String icon,
    required String label,
    required String time,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
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
                _kPrimaryColor,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
        Text(
          time,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  /// ✅ صف أزرار React و Reply — يُعرض فقط عندما لا يوجد حظر
  Widget _buildActionRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context: context,
            icon: Icons.reply_rounded,
            label: context.tr('reply'),
            onTap: () => Navigator.pop(context, {'action': 'reply'}),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            context: context,
            icon: Icons.add_reaction_outlined,
            label: context.tr('react_text'),
            onTap: () => Navigator.pop(context, {'action': 'react'}),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: _kPrimaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kPrimaryColor.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _kPrimaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: _kPrimaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
