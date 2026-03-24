import 'package:tayseer/core/widgets/full_screen_image_view.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/my_import.dart';

class UserProfileImage extends StatelessWidget {
  final UserProfileModel? userProfile;

  const UserProfileImage({super.key, this.userProfile});

  @override
  Widget build(BuildContext context) {
    final imageUrl = userProfile?.image ?? kCurrentUserData?.image;

    return SizedBox(
      width: 120.w,
      height: 120.w,
      child: GestureDetector(
        onTap: (imageUrl != null && imageUrl.isNotEmpty)
            ? () => FullScreenImageView.show(
                context,
                imageUrl: imageUrl,
                heroTag: 'user_profile_image',
                userName: userProfile?.name ?? kCurrentUserData?.name ?? '',
              )
            : null,
        child: Hero(
          tag: 'user_profile_image',
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary100,
            ),
            child: (imageUrl != null && imageUrl.isNotEmpty)
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      placeholder: (context, url) =>
                          Container(color: AppColors.secondary200),
                      errorWidget: (context, url, error) => Center(
                        child: Icon(
                          Icons.person,
                          size: 48.w,
                          color: AppColors.secondary400,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.person,
                      size: 48.w,
                      color: AppColors.secondary400,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
