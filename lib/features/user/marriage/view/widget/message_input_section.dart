import 'package:tayseer/features/user/marriage/view_model/marriage_cubit.dart';
import 'package:tayseer/my_import.dart';

class MessageInputSection extends StatefulWidget {
  final String name;
  final String personId;

  const MessageInputSection({
    super.key,
    required this.name,
    this.personId = '',
  });

  @override
  State<MessageInputSection> createState() => _MessageInputSectionState();
}

class _MessageInputSectionState extends State<MessageInputSection> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _hasText(String text) => text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${widget.name} ${context.tr('messge_profil_title')}",
          style: Styles.textStyle14Bold,
        ),
        Text(
          context
              .tr('messge_profil_sub_title')
              .replaceAll('{name}', widget.name),
          style: Styles.textStyle10.copyWith(color: Colors.grey),
        ),
        Gap(10.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                maxLines: 4,
                decoration: InputDecoration(
                  fillColor: HexColor('f9f8ec'),
                  filled: true,
                  hintText: context.tr('type_your_message'),
                  hintStyle: Styles.textStyle12.copyWith(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              Gap(20.h),

              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, _) {
                  final enabled = _hasText(value.text);

                  return CustomBotton(
                    backGroundcolor: AppColors.kgreyColor,
                    useGradient: enabled,
                    title: context.tr('send_reply'),
                    onPressed: enabled
                        ? () {
                            context.read<MarriageCubit>().sendRegardText(
                              personId: widget.personId,
                              text: value.text.trim(),
                            );

                            _controller.clear();
                          }
                        : null,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
