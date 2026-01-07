import 'package:tayseer/my_import.dart';

class ControlButtons extends StatelessWidget {
  final VoidCallback onMyLocation;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const ControlButtons({
    super.key,
    required this.onMyLocation,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FloatingActionButton(
          heroTag: 'myLocation',
          onPressed: onMyLocation,
          backgroundColor: Colors.white,
          elevation: 4,
          child: Icon(Icons.my_location, color: AppColors.kprimaryColor),
        ),
        Gap(context.responsiveHeight(12)),
        FloatingActionButton.small(
          heroTag: 'zoomIn',
          onPressed: onZoomIn,
          backgroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.black87),
        ),
        Gap(context.responsiveHeight(8)),
        FloatingActionButton.small(
          heroTag: 'zoomOut',
          onPressed: onZoomOut,
          backgroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.remove, color: Colors.black87),
        ),
      ],
    );
  }
}
