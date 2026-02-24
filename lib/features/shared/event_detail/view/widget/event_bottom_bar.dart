import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/widgets/custom_outline_button.dart';
import 'package:tayseer/my_import.dart';

class EventBottomBar extends StatelessWidget {
  const EventBottomBar({
    super.key,
    this.onBoostPressed,
    this.onEditPressed,
    required this.priceAfterDiscount,
    this.onBookTicketPressed,
    required this.isMyEvent,
  });
  final VoidCallback? onBoostPressed;
  final VoidCallback? onEditPressed;
  final VoidCallback? onBookTicketPressed;
  final String priceAfterDiscount;
  final bool isMyEvent;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('session_price_label'),
                style: Styles.textStyle10,
              ),
              Text(
                priceAfterDiscount,
                style: Styles.textStyle18Bold.copyWith(
                  color: AppColors.kprimaryColor,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (selectedUserType == UserTypeEnum.asConsultant && isMyEvent)
            Row(
              children: [
                CustomBotton(
                  width: context.width * .25,
                  useGradient: true,
                  onPressed: onBoostPressed,
                  title: context.tr('boost_button'),
                ),
                Gap(context.responsiveWidth(12)),
                CustomOutlineButton(
                  height: 50,
                  isSocialLinkButton: true,
                  width: context.width * .25,
                  onTap: onEditPressed,
                  text: context.tr('edit_button'),
                ),
              ],
            ),
          if (selectedUserType == UserTypeEnum.user ||
              selectedUserType == UserTypeEnum.guest ||
              isMyEvent == false)
            CustomBotton(
              title: context.tr('book_ticket'),
              onPressed: () {
                if (isGuest) {
                  CustomshowDialogWithImage(
                    context,
                    title: context.tr('joinUs'),
                    supTitle: context.tr("guest_login_first"),
                    icon: Icons.lock_person_outlined,
                    iconColor: AppColors.kprimaryColor,
                    bottonText: context.tr("login"),
                    showCancelButton: true,
                    cancelText: context.tr('skip'),
                    onPressed: () {
                      CachNetwork.removeData(key: ktoken);
                      context.pushNamedAndRemoveUntil(
                        AppRouter.kRegisrationView,
                        predicate: (_) => false,
                      );
                    },
                    onCancel: () {},
                  );
                } else {
                  onBookTicketPressed?.call();
                }
              },
              width: context.width * .25,
              useGradient: true,
            ),
        ],
      ),
    );
  }
}
