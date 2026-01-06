import '../../my_import.dart';

class CustomNoteCard extends StatelessWidget {
  final VoidCallback? onSend;
  final TextEditingController? controller;
  final bool? isNoteYourRequest;

  const CustomNoteCard({
    super.key,
    this.onSend,
    this.controller,
    this.isNoteYourRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: context.width * 0.9,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isNoteYourRequest == null
                    ? AppColors.kGradineNoteColors
                    : AppColors.kGradineYourRequestNoteColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.12),
              offset: Offset(0, 6),
              blurRadius: 14,
            ),
          ],
          border: Border.all(
            color:
                isNoteYourRequest == null
                    ? Colors.blue.withOpacity(0.25)
                    : HexColor('99bdf0'),
            width: 2,
          ),
        ),
        padding: EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  context.tr(
                    isNoteYourRequest == null
                        ? 'note_addition'
                        : 'your_request',
                  ),
                  style: Styles.textStyle12,
                ),
                Expanded(child: SizedBox()),
              ],
            ),
            SizedBox(height: context.height * 0.02),
            if (isNoteYourRequest != null)
              Text(
                context.tr('your_request_title'),
                style: Styles.textStyle10.copyWith(color: Colors.grey),
              ),
            SizedBox(height: context.height * 0.02),
            Container(
              height:
                  isNoteYourRequest == null
                      ? context.height * 0.25
                      : context.height * 0.4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.06),
                    offset: Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
                border: Border.all(
                  color: Colors.blue.withOpacity(0.12),
                  width: 1.5,
                ),
              ),
              padding: EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Stack(
                children: [
                  TextField(
                    style: Styles.textStyle10.copyWith(color: Colors.grey),
                    controller: controller,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: context.tr('write_your_note_here'),
                      hintStyle: Styles.textStyle10.copyWith(
                        color: Colors.grey[400],
                      ),
                      border: InputBorder.none,
                    ),
                  ),

                  Positioned(
                    left: context.width * 0.005,
                    bottom: context.height * 0.001,
                    child: CustomBotton(
                      title: context.tr('send'),
                      onPressed: onSend,
                      height: context.height * 0.05,
                      width: context.width * 0.3,
                    ),
                  ),

                  // Positioned(
                  //   right: 6,
                  //   bottom: 6,
                  //   child: Transform.rotate(
                  //     angle: -0.6,
                  //     child: Container(
                  //       width: 20,
                  //       height: 12,
                  //       decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(2),
                  //         color: Colors.white.withOpacity(0.6),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
