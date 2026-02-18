import 'package:tayseer/core/widgets/custom_click.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/models/post_model.dart';

class PostPollView extends StatelessWidget {
  final PostModel post;
  final void Function(String choice)? onVote;

  const PostPollView({super.key, required this.post, this.onVote});

  PollModel get _poll => post.pollModel!;
  List<PollChoice> get _choices => _poll.pollChoices;
  int get _totalVotes => _poll.totalPollVotes;
  PollChoice? get _selectedChoice =>
      _choices.where((e) => e.isSelected).firstOrNull;
  bool get _hasVoted => _selectedChoice != null;

  @override
  Widget build(BuildContext context) {
    if (_choices.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ..._choices.map((choice) => _buildOption(context, choice)),
        Gap(context.responsiveHeight(12)),
        _buildFooter(context),
      ],
    );
  }

  Widget _buildOption(BuildContext context, PollChoice choice) {
    final isSelected = _selectedChoice?.choice == choice.choice;
    final percentage = (choice.percentage / 100).clamp(0.0, 1.0);

    return Padding(
      padding: EdgeInsets.only(bottom: context.responsiveHeight(10)),
      child: CustomClick(
        onTap: () {
          onVote?.call(choice.choice);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: context.responsiveHeight(48),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.kprimaryColor
                  : AppColors.secondary100,
              width: isSelected ? 1.5 : 1,
            ),
            color: Colors.white,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [
              // Progress Bar
              if (_hasVoted)
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  widthFactor: percentage,
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    color: isSelected
                        ? AppColors.kprimaryColor.withOpacity(0.15)
                        : AppColors.secondary100,
                  ),
                ),
              // Content
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveWidth(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        choice.choice,
                        style: Styles.textStyle14.copyWith(
                          color: _hasVoted && isSelected
                              ? AppColors.kprimaryColor
                              : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildAvatars(context, choice.votersAvatars),
                    if (_hasVoted) ...[
                      Gap(context.responsiveWidth(8)),
                      Text(
                        '${choice.percentage}%',
                        style: Styles.textStyle14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.kprimaryColor
                              : Colors.black54,
                        ),
                      ),
                      if (isSelected) ...[
                        Gap(context.responsiveWidth(8)),
                        Icon(
                          Icons.check_circle,
                          color: AppColors.kprimaryColor,
                          size: 20.sp,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatars(BuildContext context, List<String> avatars) {
    final displayAvatars = avatars.take(3).toList();
    return Padding(
      padding: EdgeInsets.only(left: context.responsiveWidth(8)),
      child: SizedBox(
        width: (displayAvatars.length * 16 + 8).w,
        height: 24.w,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < displayAvatars.length; i++)
              Positioned(
                left: (i * 16).w,
                child: Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: AppImage(
                      displayAvatars[i],
                      width: 24.w,
                      height: 24.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        Text(
          '$_totalVotes ${context.tr(AppStrings.votes)}',
          style: Styles.textStyle12.copyWith(color: AppColors.kGreyB3),
        ),
      ],
    );
  }
}
