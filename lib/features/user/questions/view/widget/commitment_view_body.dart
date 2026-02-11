// lib/features/user/questions/view/commitment_screen.dart

import 'package:tayseer/features/user/questions/view_model/questions_cubit.dart';
import 'package:tayseer/features/user/questions/view_model/questions_state.dart';
import 'package:tayseer/my_import.dart';

class CommitmentViewBody extends StatefulWidget {
  const CommitmentViewBody({super.key});

  @override
  State<CommitmentViewBody> createState() => _CommitmentViewBodyState();
}

class _CommitmentViewBodyState extends State<CommitmentViewBody> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    final isEnabled = _nameController.text.trim().isNotEmpty;
    if (isEnabled != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isEnabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocConsumer<QuestionsCubit, QuestionsState>(
        listenWhen: (previous, current) =>
            previous.answerQuestionsState != current.answerQuestionsState,
        listener: (context, state) {
          if (state.answerQuestionsState == CubitStates.loading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CustomloadingApp()),
            );
          } else if (state.answerQuestionsState == CubitStates.success) {
            // close loading dialog only (don't pop the current route)
            if (Navigator.canPop(context)) Navigator.pop(context);
            context.pushReplacementNamed(AppRouter.kAccountReviewUserView);
          } else if (state.answerQuestionsState == CubitStates.failure) {
            // close loading dialog only (don't pop the current route)
            if (Navigator.canPop(context)) Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              CustomSnackBar(
                context,
                text: state.errorMessage ?? context.tr("submit_failed"),
                isSuccess: false,
              ),
            );
          }
        },
        builder: (context, state) {
          return CustomBackground(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Stack(
                children: [
                  // ✅ الخلفية
                  _buildBackground(context),

                  // ✅ المحتوى
                  _buildMainContent(context),

                  // ✅ زر الرجوع
                  _buildBackButton(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    return Column(
      children: [
        // الصورة العلوية
        AppImage(
          width: context.width,
          height: context.height * 0.4,
          AssetsData.kCommitmentBackgroundImage,
          fit: BoxFit.cover,
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      top: context.height * 0.03,
      right: context.width * 0.04,
      child: SafeArea(
        child: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            padding: EdgeInsets.all(context.width * 0.025),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: context.width * 0.05,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Column(
      children: [
        // مساحة للصورة
        SizedBox(height: context.height * 0.4),

        // المحتوى
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: context.height * 0.03,
              bottom: context.height * 0.02,
              right: context.width * 0.01,
              left: context.width * 0.01,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // العنوان
                  _buildTitle(context),

                  SizedBox(height: context.height * 0.025),

                  // قائمة التعهدات
                  _buildCommitments(context),

                  SizedBox(height: context.height * 0.035),

                  // حقل الاسم باستخدام CustomTextFormField
                  _buildNameInput(context),

                  SizedBox(height: context.height * 0.025),

                  // زر التالي
                  _buildSubmitButton(context),

                  SizedBox(height: context.height * 0.015),

                  // نص الموافقة
                  _buildTermsText(context),

                  SizedBox(height: context.height * 0.02),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        context.tr('commitment_title'),
        style: Styles.textStyle22Bold.copyWith(
          color: AppColors.kscandryTextColor,
        ),
      ),
    );
  }

  Widget _buildCommitments(BuildContext context) {
    final List<String> commitmentKeys = [
      'commitment_respect',
      'commitment_not_married',
      'commitment_guidelines',
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.width * 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: commitmentKeys.map((key) {
          return Padding(
            padding: EdgeInsets.only(bottom: context.height * 0.01),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: context.height * 0.005),
                  child: Text('•  ', style: Styles.textStyle14Bold),
                ),
                Expanded(
                  child: Text(
                    context.tr(key),
                    style: Styles.textStyle14.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNameInput(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.width * 0.1),
      child: CustomTextFormField(
        controller: _nameController,
        isName: true,
        textInputAction: TextInputAction.done,
        onChanged: (_) => _onNameChanged(),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.width * 0.1),
      child: CustomBotton(
        width: context.width,
        title: context.tr('next'),
        useGradient: _isButtonEnabled,
        backGroundcolor: AppColors.kgreyColor,
        onPressed: _isButtonEnabled ? _onSubmit : null,
      ),
    );
  }

  Widget _buildTermsText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.width * 0.08),
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            fontSize: context.width * 0.028,
            color: Colors.grey[600],
            height: 1.6,
          ),
          children: [
            TextSpan(text: context.tr('agreement_prefix')),
            TextSpan(
              text: context.tr('terms_of_use'),
              style: TextStyle(
                color: AppColors.kprimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: ' ${context.tr('and')} '),
            TextSpan(
              text: context.tr('privacy_policy'),
              style: TextStyle(
                color: AppColors.kprimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      context.read<QuestionsCubit>().sendAnswerQuestions(
        question: "commitment",
        questionCategoryEnum: "commitment",
        questionNumber: 29,
        answers: [
          {'answer': _nameController.text.trim()},
        ],
      );
    }
  }
}
