import 'package:tayseer/core/widgets/profile_text_field.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/my_import.dart';

class EmailEditView extends StatefulWidget {
  final String initialEmail;
  const EmailEditView({super.key, this.initialEmail = ""});

  @override
  State<EmailEditView> createState() => _EmailEditViewState();
}

class _EmailEditViewState extends State<EmailEditView> {
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: SafeArea(
          child: Column(
            children: [
              Gap(16.h),
              // الهيدر
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: SimpleAppBar(
                  title: 'البريد الالكترونى',
                  isLargeTitle: true,
                ),
              ),

              Gap(8.h),

              // النص الفرعي
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  'سنرسل لك رمز تحقق علي البريد الالكترونى لتأكيد بريدك الجديد',
                  textAlign: TextAlign.center,
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.primary800,
                  ), // لون مناسب للنص الفرعي
                ),
              ),

              Gap(100.h),

              // حقل الإدخال المستخدم فيه الـ Widget الخاص بك
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: ProfileTextField(
                  controller: emailController,
                  hint: 'ادخل بريدك الالكترونى',
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),

              const Spacer(),

              // زر التأكيد
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 30.h),
                child: CustomBotton(
                  height: 53.h,
                  width: double.infinity,
                  title: 'تأكيد',
                  useGradient: true,
                  onPressed: () {
                    if (emailController.text.isNotEmpty) {
                      Navigator.pop(context, emailController.text);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
