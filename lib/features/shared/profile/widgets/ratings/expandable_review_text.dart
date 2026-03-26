import 'package:tayseer/core/cubits/toggle_cubit.dart';
import 'package:tayseer/my_import.dart';

class ExpandableReviewText extends StatelessWidget {
  final String text;

  const ExpandableReviewText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ToggleCubit(false),
      child: BlocBuilder<ToggleCubit, bool>(
        builder: (context, isExpanded) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final style = Styles.textStyle14.copyWith(
                color: AppColors.secondaryText,
                height: 1.6,
              );
              final span = TextSpan(text: text, style: style);
              final tp = TextPainter(
                text: span,
                maxLines: 3,
                textDirection: Directionality.of(context),
              );
              tp.layout(maxWidth: constraints.maxWidth);

              if (!tp.didExceedMaxLines) {
                return Text(
                  text,
                  style: style,
                  textAlign: TextAlign.right,
                  textDirection: Directionality.of(context),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    textAlign: TextAlign.right,
                    textDirection: Directionality.of(context),
                    style: style,
                    maxLines: isExpanded ? null : 3,
                    overflow:
                        isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  ),
                  InkWell(
                    onTap: () => context.read<ToggleCubit>().toggle(),
                    child: Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        isExpanded
                            ? context.tr('see_less')
                            : context.tr('see_more'),
                        style: Styles.textStyle12.copyWith(
                          color: AppColors.kprimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
