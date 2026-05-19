// lib/features/user/questions/view/commitment_screen.dart

import 'package:tayseer/features/shared/auth/view/widget/agreement_text.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_cubit.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_state.dart';
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

  // ✅ Validator للاسم
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.tr('name_required');
    }

    final trimmed = value.trim();

    // حروف فقط (أي لغة) + مسافات — بدون أرقام / رموز / إيموجي
    final validNameRegex = RegExp(r'^[\p{L}\s]+$', unicode: true);
    if (!validNameRegex.hasMatch(trimmed)) {
      return context.tr('invalid_name_characters');
    }

    // لازم كلمتين على الأقل (اسم أول + اسم تاني)
    final words = trimmed
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.length < 2) {
      return context.tr('enter_full_name');
    }

    // كل كلمة لازم تكون حرفين على الأقل
    for (final word in words) {
      if (word.length < 2) {
        return context.tr('name_too_short');
      }
    }

    return null;
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
            if (Navigator.canPop(context)) Navigator.pop(context);
            context.pushReplacementNamed(
              AppRouter.kUserPackagesView,
              arguments: {'fromOnboarding': true},
            );
          } else if (state.answerQuestionsState == CubitStates.failure) {
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
                  _buildBackground(context),
                  _buildMainContent(context),
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
        SizedBox(height: context.height * 0.4),
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
              child: AutofillGroup(
                child: Column(
                  children: [
                    _buildTitle(context),
                    SizedBox(height: context.height * 0.025),
                    _buildCommitments(context),
                    SizedBox(height: context.height * 0.035),
                    _buildNameInput(context),
                    SizedBox(height: context.height * 0.025),
                    _buildSubmitButton(context),
                    SizedBox(height: context.height * 0.015),
                    AgreementText(),
                    SizedBox(height: context.height * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,

      children: [
        Gap(8.w),
        Text(
          context.tr('commitment_title'),
          style: Styles.textStyle22Bold.copyWith(
            color: AppColors.kscandryTextColor,
          ),
          textAlign: TextAlign.start,
        ),
      ],
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

  // ✅ تم إضافة الـ validator هنا
  Widget _buildNameInput(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.width * 0.1),
      child: CustomTextFormField(
        controller: _nameController,
        isName: true,
        textInputAction: TextInputAction.done,
        onChanged: (_) => _onNameChanged(),
        validator: _validateName,
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
