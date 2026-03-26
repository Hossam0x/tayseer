import 'package:tayseer/features/advisor/profille/views/cubit/certificates/certificates_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates/certificates_state.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/boost/boost_button_sliver.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/certificates/certificates_error_section.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/certificates/certificates_header.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/certificates/certificates_list.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/certificates/certificates_load_more_button.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/certificates/certificates_skeleton.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/certificates/certificates_video_section.dart';
import 'package:tayseer/my_import.dart';

class ProfileCertificatesSection extends StatefulWidget {
  final String advisorId;
  final bool isMe;

  const ProfileCertificatesSection({
    super.key,
    required this.advisorId,
    required this.isMe,
  });

  @override
  State<ProfileCertificatesSection> createState() =>
      _ProfileCertificatesSectionState();
}

class _ProfileCertificatesSectionState extends State<ProfileCertificatesSection>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<CertificatesCubit, CertificatesState>(
      builder: (context, state) {
        if (state.state == CubitStates.loading) {
          return const CertificatesSkeleton();
        }

        if (state.state == CubitStates.failure && state.certificates.isEmpty) {
          return CertificatesErrorSection(advisorId: widget.advisorId);
        }

        return _CertificatesContent(
          advisorId: widget.advisorId,
          isMe: widget.isMe,
          state: state,
        );
      },
    );
  }
}

class _CertificatesContent extends StatelessWidget {
  final String advisorId;
  final bool isMe;
  final CertificatesState state;

  const _CertificatesContent({
    required this.advisorId,
    required this.isMe,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () =>
          context.read<CertificatesCubit>().refresh(advisorId: advisorId),
      child: Column(
        children: [
          _CertificatesBody(advisorId: advisorId, isMe: isMe, state: state),
          if (state.hasMore) CertificatesLoadMoreButton(state: state),
          Gap(20.h),
        ],
      ),
    );
  }
}

class _CertificatesBody extends StatelessWidget {
  final String advisorId;
  final bool isMe;
  final CertificatesState state;

  const _CertificatesBody({
    required this.advisorId,
    required this.isMe,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.hasVideo) ...[
            CertificatesVideoSection(videoUrl: state.videoUrl!),
            Gap(24.h),
          ],
          if (isMe) CertificatesHeader(advisorId: advisorId),
          CertificatesList(
            certificates: state.certificates,
            isMe: isMe,
            advisorId: advisorId,
          ),
          Gap(24.h),
          if (isMe)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 35.w),
              child: BoostButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRouter.kPackagesView),
                text: context.tr('boost_button'),
              ),
            ),
        ],
      ),
    );
  }
}
