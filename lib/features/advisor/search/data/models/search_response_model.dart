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
          (data['posts'] as List?)
              ?.map(
                (e) => PostModel(
                  postId: e['id'] ?? '',
                  content: e['content'] ?? '',
                  images: e['image'] != null ? [e['image']] : [],
                  name: e['advisor']?['name'] ?? '',
                  avatar: e['advisor']?['image'] ?? '',
                  advisorId: e['advisor']?['id'] ?? '',
                  userName: '', // Not in the summary response
                  isFollowing: false,
                  category: '',
                  timeAgo: '',
                  commentsCount: 0,
                  sharesCount: 0,
                  likesCount: 0,
                  topReactions: [],
                ),
              )
              .toList() ??
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
          (data['postsDto'] as List?)
              ?.map((e) => PostModel.fromJson(e))
              .toList() ??
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
}
