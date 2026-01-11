import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/selection/message_selection_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/selection/message_selection_state.dart';

/// Bottom bar that appears during selection mode
class SelectionBottomBar extends StatelessWidget {
  final VoidCallback onDeleteForMe;
  final VoidCallback onDeleteForAll;
  final VoidCallback onCancel;

  const SelectionBottomBar({
    super.key,
    required this.onDeleteForMe,
    required this.onDeleteForAll,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageSelectionCubit, MessageSelectionState>(
      builder: (context, state) {
        if (!state.isSelectionMode) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Cancel button
              IconButton(
                onPressed: onCancel,
                icon: const Icon(Icons.close),
                tooltip: 'إلغاء',
              ),
              const SizedBox(width: 8),
              // Selection count
              Text(
                '${state.selectionCount} محدد',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              // Delete for me button
              _DeleteButton(
                label: 'حذف لديّ',
                onTap: onDeleteForMe,
                isDestructive: true,
              ),
              // Delete for all button (only if all selected are mine)
              if (state.canDeleteForAll) ...[
                const SizedBox(width: 8),
                _DeleteButton(
                  label: 'حذف للجميع',
                  onTap: onDeleteForAll,
                  isDestructive: true,
                  isFilled: true,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isFilled;

  const _DeleteButton({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : Colors.blue;

    if (isFilled) {
      return ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      );
    }

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
