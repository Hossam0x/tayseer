import '../../../../../my_import.dart';

class StepHeader extends StatelessWidget {
  const StepHeader({super.key, required this.titleKey, required this.progress});

  final String titleKey;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              SizedBox(width: context.width * 0.04),
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade300,
                  color: HexColor('bb3e57'),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          context.tr(titleKey),
          style: Styles.textStyle20.copyWith(
            fontWeight: FontWeight.bold,
            color: HexColor('590d1c'),
          ),
        ),
      ],
    );
  }
}
