import 'package:tayseer/my_import.dart';

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final LinearGradient? gradient;
  final int maxLines;
  final TextOverflow overflow;

  const GradientText({
    super.key,
    required this.text,
    required this.style,
    this.gradient,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return (gradient ?? AppColors.textGradient).createShader(bounds);
      },
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
