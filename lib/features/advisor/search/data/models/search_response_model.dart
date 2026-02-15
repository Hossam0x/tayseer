import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/advisor/search/data/models/search_advisor_model.dart';
import 'package:tayseer/features/advisor/search/data/models/search_event_model.dart';
import 'package:tayseer/features/advisor/search/data/models/search_user_model.dart';

class SearchResponseModel {
  final List<PostModel> posts;
  final List<SearchAdvisor> advisors;
  final List<SearchUser> users;
  final List<SearchEvent> events;

  SearchResponseModel({
    required this.posts,
    required this.advisors,
    required this.users,
    required this.events,
  });

  factory SearchResponseModel.fromJson(Map<String, dynamic> json, String type) {
    List<PostModel> posts = [];
    List<SearchAdvisor> advisors = [];
    List<SearchUser> users = [];
    List<SearchEvent> events = [];

    if (type == 'all') {
      final data = json['data'] ?? {};
      posts =
          (data['posts'] as List?)?.map((e) {
            final Map<String, dynamic> postData = Map<String, dynamic>.from(e);

            final String advisorId =
                e['userId'] ?? e['advisorId'] ?? e['advisor']?['id'] ?? '';
            postData['advisorId'] = advisorId;

            if (e['advisor'] != null) {
              postData['name'] = e['advisor']['name'] ?? postData['name'];
              postData['avatar'] = _fixUrl(
                e['advisor']['image'],
                advisorId,
                'advisor',
              );
              postData['isFollowing'] = e['advisor']['isFollowing'] ?? false;
              postData['isVerified'] = e['advisor']['isVerified'] ?? false;
              postData['userName'] =
                  e['advisor']['username'] ?? e['advisor']['userName'] ?? '';
            }

            if (e['image'] != null) {
              postData['images'] = [
                {
                  'image': _fixUrl(e['image'], advisorId, 'post'),
                  'width': 1,
                  'height': 1,
                },
              ];
            }

            return PostModel.fromJson(postData);
          }).toList() ??
          [];
      advisors =
          (data['advisors'] as List?)
              ?.map((e) => SearchAdvisor.fromJson(e))
              .toList() ??
          [];
      users =
          (data['users'] as List?)
              ?.map((e) => SearchUser.fromJson(e))
              .toList() ??
          [];
      events =
          (data['events'] as List?)
              ?.map((e) => SearchEvent.fromJson(e))
              .toList() ??
          [];
    } else if (type == 'posts') {
      final data = json['data'] ?? {};
      posts =
          (data['postsDto'] as List?)?.map((e) {
            final Map<String, dynamic> postData = Map<String, dynamic>.from(e);
            final String advisorId =
                e['advisorId'] ?? e['advisor']?['id'] ?? '';
            postData['advisorId'] = advisorId;

            if (postData['avatar'] != null) {
              postData['avatar'] = _fixUrl(
                postData['avatar'],
                advisorId,
                'advisor',
              );
            }

            if (postData['images'] != null && postData['images'] is List) {
              postData['images'] = (postData['images'] as List).map((img) {
                if (img is Map) {
                  final Map<String, dynamic> imgData =
                      Map<String, dynamic>.from(img);
                  imgData['image'] = _fixUrl(
                    imgData['image'],
                    advisorId,
                    'post',
                  );
                  return imgData;
                }
                return img;
              }).toList();
            }

            return PostModel.fromJson(postData);
          }).toList() ??
          [];
    } else if (type == 'advisors') {
      final data = json['data'] ?? {};
      advisors =
          (data['advisors'] as List?)
              ?.map((e) => SearchAdvisor.fromJson(e))
              .toList() ??
          [];
    } else if (type == 'users') {
      final data = json['data'] ?? {};
      users =
          (data['users'] as List?)
              ?.map((e) => SearchUser.fromJson(e))
              .toList() ??
          [];
    } else if (type == 'events') {
      final data = json['data'] ?? {};
      events =
          (data['events'] as List?)
              ?.map((e) => SearchEvent.fromJson(e))
              .toList() ??
          [];
    }

    return SearchResponseModel(
      posts: posts,
      advisors: advisors,
      users: users,
      events: events,
    );
  }

  static String _fixUrl(String? path, String advisorId, String type) {
    if (path == null || path.isEmpty || path.startsWith('http')) {
      return path ?? '';
    }
    return 'https://tayser-app.net/uploads/$type/$advisorId/$path';
  }
}
