import 'package:tayseer/features/user/my_space/presentation/widget/session_start_toast.dart';
import 'package:tayseer/my_import.dart';

void showSessionStartedToast({
  required BuildContext context,
  required String message,
  required VoidCallback onJoin,
}) {
  OverlayEntry? overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => SessionToastWidget(
      message: message,
      onJoinTap: onJoin,
      onDismiss: () {
        overlayEntry?.remove();
        overlayEntry = null;
      },
    ),
  );

  Overlay.of(context).insert(overlayEntry!);
}
