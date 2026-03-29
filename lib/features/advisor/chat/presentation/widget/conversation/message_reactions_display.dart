import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/services/socket_events/chat_socket_events.dart';

class MessageReactionsDisplay extends StatelessWidget {
  final List<MessageReaction> reactions;
  final String currentUserId;
  final Function(String emoji) onReactionTap;

  const MessageReactionsDisplay({
    super.key,
    required this.reactions,
    required this.currentUserId,
    required this.onReactionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    // تجميع الـ reactions حسب الـ emoji
    final Map<String, List<String>> groupedReactions = {};
    for (final reaction in reactions) {
      if (!groupedReactions.containsKey(reaction.emoji)) {
        groupedReactions[reaction.emoji] = [];
      }
      groupedReactions[reaction.emoji]!.add(reaction.userId);
    }

    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: groupedReactions.entries.map((entry) {
        final emoji = entry.key;
        final userIds = entry.value;
        final count = userIds.length;
        final isMyReaction = userIds.contains(currentUserId);

        return _ReactionChip(
          emoji: emoji,
          count: count,
          isMyReaction: isMyReaction,
          onTap: () => onReactionTap(emoji),
        );
      }).toList(),
    );
  }
}

class _ReactionChip extends StatefulWidget {
  final String emoji;
  final int count;
  final bool isMyReaction;
  final VoidCallback onTap;

  const _ReactionChip({
    required this.emoji,
    required this.count,
    required this.isMyReaction,
    required this.onTap,
  });

  @override
  State<_ReactionChip> createState() => _ReactionChipState();
}

class _ReactionChipState extends State<_ReactionChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: widget.isMyReaction
                ? const Color(0xFFE96E88).withOpacity(0.15)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: widget.isMyReaction
                  ? const Color(0xFFE96E88)
                  : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.emoji,
                style: TextStyle(fontSize: 16.sp),
              ),
              if (widget.count > 1) ...[
                SizedBox(width: 4.w),
                Text(
                  '${widget.count}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: widget.isMyReaction
                        ? const Color(0xFFE96E88)
                        : Colors.grey.shade700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
