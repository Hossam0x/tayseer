import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/cache/chat_cache_service.dart';
import 'package:tayseer/core/constant/constans.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/core/utils/api_endpoint.dart';
import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/advisor/chat/data/event_bus/chat_event_bus.dart';
import 'package:tayseer/features/user/my_space/users_chat/data/model/regard_request_model.dart';
import 'package:tayseer/features/user/my_space/users_chat/data/model/user_chat_room_model.dart';
import 'package:tayseer/features/user/my_space/users_chat/data/repo/user_chat_repo.dart';

class UserChatState {
  final CubitStates status;
  final List<UserChatRoomModel> chatRooms;
  final List<RegardRequestModel> requests;
  final int slotLimit;
  final int matchingCount;
  final bool myImageBlur;
  final String? errorMessage;

  const UserChatState({
    this.status = CubitStates.initial,
    this.chatRooms = const [],
    this.requests = const [],
    this.slotLimit = 4,
    this.matchingCount = 0,
    this.myImageBlur = false,
    this.errorMessage,
  });

  UserChatState copyWith({
    CubitStates? status,
    List<UserChatRoomModel>? chatRooms,
    List<RegardRequestModel>? requests,
    int? slotLimit,
    int? matchingCount,
    bool? myImageBlur,
    String? errorMessage,
  }) {
    return UserChatState(
      status: status ?? this.status,
      chatRooms: chatRooms ?? this.chatRooms,
      requests: requests ?? this.requests,
      slotLimit: slotLimit ?? this.slotLimit,
      matchingCount: matchingCount ?? this.matchingCount,
      myImageBlur: myImageBlur ?? this.myImageBlur,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class UserChatCubit extends Cubit<UserChatState> {
  final UserChatRepo _repo;
  final tayseerSocketHelper _socketHelper = getIt<tayseerSocketHelper>();
  final ChatCacheService _cacheService = getIt<ChatCacheService>();
  late final String _listenerId;
  StreamSubscription<ChatUnarchiveEvent>? _unarchiveSubscription;

  UserChatCubit(this._repo) : super(const UserChatState()) {
    _listenerId = 'UserChatCubit_newMessage_${DateTime.now().millisecondsSinceEpoch}';
    _setupSocketListener();
    _setupEventBusListeners();
  }

  void _setupEventBusListeners() {
    // لما يتعمل unarchive لأي غرفة، حدّث الـ list بدون loading
    _unarchiveSubscription = ChatEventBus.instance.onChatUnarchived.listen((event) {
      if (isClosed) return;
      _refreshChatRoomsQuietly();
    });
  }

  /// تحديث الـ chat rooms في الخلفية بدون loading indicator
  Future<void> _refreshChatRoomsQuietly() async {
    final result = await _repo.getUserChatRooms();
    if (isClosed) return;
    result.fold(
      (_) {},
      (response) {
        emit(state.copyWith(chatRooms: response.chatRooms));
        final userId = kCurrentUserData?.id;
        if (userId != null) {
          _saveCacheFromCurrentState(response.chatRooms);
        }
      },
    );
  }

  void _setupSocketListener() {
    _socketHelper.listenWithId('newMessage', _listenerId, (data) {
      if (isClosed) return;
      // لما تيجي رسالة جديدة، حدث الـ last message في الـ list
      try {
        final chatRoomData = data['chatRoom'] as Map<String, dynamic>?;
        if (chatRoomData == null) return;
        final roomId = chatRoomData['id']?.toString() ?? '';
        final lastMsgData = chatRoomData['lastMessage'] as Map<String, dynamic>?;
        if (roomId.isEmpty || lastMsgData == null) return;

        // ✅ حوّل الـ contentType لـ display content مناسب
        // السيرفر بيبعت الـ URL الفعلي في content لو audio/image/video
        // لازم نحوّله لـ 'audio'/'image'/'video' عشان formatLastMessage يعرضه صح
        final rawContent = lastMsgData['content']?.toString() ?? '';
        final contentType = (lastMsgData['contentType'] ?? lastMsgData['messageType'])
            ?.toString()
            .toLowerCase() ?? '';
        final displayContent = _normalizeContentForDisplay(rawContent, contentType);

        final updatedRooms = state.chatRooms.map((room) {
          if (room.id == roomId) {
            return UserChatRoomModel(
              id: room.id,
              otherUser: room.otherUser,
              otherUserType: room.otherUserType,
              lastMessage: UserLastMessageModel(
                content: displayContent,
                sentAt: lastMsgData['sentAt'] != null
                    ? DateTime.tryParse(lastMsgData['sentAt'].toString())
                    : null,
                status: lastMsgData['status']?.toString(),
              ),
              otherUserOnlineStatus: room.otherUserOnlineStatus,
              unreadCount: room.unreadCount + 1,
              blockExists: room.blockExists,
            );
          }
          return room;
        }).toList();

        // رتب الـ rooms بحيث الأحدث فوق
        updatedRooms.sort((a, b) {
          final aTime = a.lastMessage?.sentAt ?? DateTime(0);
          final bTime = b.lastMessage?.sentAt ?? DateTime(0);
          return bTime.compareTo(aTime);
        });

        emit(state.copyWith(chatRooms: updatedRooms));
        _saveCacheFromCurrentState(updatedRooms);
      } catch (_) {}
    });
  }

  /// ✅ يحوّل الـ content الخام لـ display content مناسب للـ chat list
  /// لو الـ contentType يدل على media، يرجع keyword بدل الـ URL
  static String _normalizeContentForDisplay(String rawContent, String contentType) {
    switch (contentType) {
      case 'record':
      case 'audio':
      case 'voice':
        return 'audio';
      case 'image':
      case 'photo':
      case 'media':
      case 'images/videos':
        // تحقق إن الـ content مش URL — لو URL يبقى image/video
        if (_looksLikeUrl(rawContent)) {
          if (rawContent.toLowerCase().contains('.mp4') ||
              rawContent.toLowerCase().contains('.mov') ||
              rawContent.toLowerCase().contains('.avi') ||
              rawContent.toLowerCase().contains('.webm')) {
            return 'video';
          }
          return 'image';
        }
        return rawContent.isEmpty ? 'image' : rawContent;
      case 'video':
        return 'video';
      case 'file':
      case 'document':
        return 'file';
      default:
        // text — ارجع الـ content كما هو
        // لكن لو بدو URL وهو مش text، حوّله
        if (_looksLikeUrl(rawContent)) {
          if (rawContent.contains('.mp3') ||
              rawContent.contains('.m4a') ||
              rawContent.contains('.wav') ||
              rawContent.contains('.ogg') ||
              rawContent.contains('.aac')) {
            return 'audio';
          }
          if (rawContent.contains('.mp4') ||
              rawContent.contains('.mov') ||
              rawContent.contains('.avi')) {
            return 'video';
          }
          if (rawContent.contains('.jpg') ||
              rawContent.contains('.jpeg') ||
              rawContent.contains('.png') ||
              rawContent.contains('.gif') ||
              rawContent.contains('.webp')) {
            return 'image';
          }
        }
        return rawContent;
    }
  }

  static bool _looksLikeUrl(String content) {
    return content.startsWith('http://') || content.startsWith('https://');
  }

  @override
  Future<void> close() {
    _socketHelper.offWithId('newMessage', _listenerId);
    _unarchiveSubscription?.cancel();
    return super.close();
  }

  /// reset الـ unreadCount لغرفة معينة فوراً (بدون API call)
  void resetUnreadCount(String chatRoomId) {
    if (isClosed) return;
    final updatedRooms = state.chatRooms.map((room) {
      if (room.id == chatRoomId && room.unreadCount > 0) {
        return UserChatRoomModel(
          id: room.id,
          otherUser: room.otherUser,
          otherUserType: room.otherUserType,
          lastMessage: room.lastMessage,
          otherUserOnlineStatus: room.otherUserOnlineStatus,
          unreadCount: 0,
          blockExists: room.blockExists,
        );
      }
      return room;
    }).toList();
    emit(state.copyWith(chatRooms: updatedRooms));
    _saveCacheFromCurrentState(updatedRooms);
  }

  /// تحديث آخر رسالة لغرفة معينة بدون إعادة تحميل كامل
  void updateLastMessage({
    required String chatRoomId,
    required String content,
    required DateTime sentAt,
    String? status,
  }) {
    if (isClosed) return;
    final updatedRooms = state.chatRooms.map((room) {
      if (room.id == chatRoomId) {
        return UserChatRoomModel(
          id: room.id,
          otherUser: room.otherUser,
          otherUserType: room.otherUserType,
          lastMessage: UserLastMessageModel(
            content: content,
            sentAt: sentAt,
            status: status,
          ),
          otherUserOnlineStatus: room.otherUserOnlineStatus,
          unreadCount: 0,
          blockExists: room.blockExists,
        );
      }
      return room;
    }).toList();

    updatedRooms.sort((a, b) {
      final aTime = a.lastMessage?.sentAt ?? DateTime(0);
      final bTime = b.lastMessage?.sentAt ?? DateTime(0);
      return bTime.compareTo(aTime);
    });

    emit(state.copyWith(chatRooms: updatedRooms));
    _saveCacheFromCurrentState(updatedRooms);
  }

  /// أرشفة غرفة محادثة (optimistic update)
  Future<bool> archiveChatRoom(String chatRoomId) async {
    final originalRooms = List<UserChatRoomModel>.from(state.chatRooms);

    // Optimistic: اشيل الغرفة فوراً
    final updatedRooms = originalRooms.where((r) => r.id != chatRoomId).toList();
    emit(state.copyWith(chatRooms: updatedRooms));
    _saveCacheFromCurrentState(updatedRooms);

    try {
      final response = await getIt<ApiService>().post(
        endPoint: ApiEndPoint.archiveChatRoom,
        data: {'chatRoomId': chatRoomId},
      );
      if (response['success'] == true) {
        return true;
      }
      // Revert on failure
      emit(state.copyWith(chatRooms: originalRooms));
      _saveCacheFromCurrentState(originalRooms);
      return false;
    } catch (_) {
      // Revert on error
      emit(state.copyWith(chatRooms: originalRooms));
      _saveCacheFromCurrentState(originalRooms);
      return false;
    }
  }

  void _saveCacheFromCurrentState(List<UserChatRoomModel> rooms) {
    final userId = kCurrentUserData?.id;
    if (userId == null) return;
    _cacheService.saveUserChatRoomsSimple(
      userId: userId,
      chatRooms: rooms,
      slotLimit: state.slotLimit,
    );
  }

  Future<void> loadAll() async {
    // ✅ عرض الكاش فوراً لو موجود
    final userId = kCurrentUserData?.id;
    if (userId != null) {
      final cached = _cacheService.getCachedUserChatRoomsSimple(userId: userId);
      if (cached != null && (cached['rooms'] as List).isNotEmpty) {
        emit(state.copyWith(
          status: CubitStates.success,
          chatRooms: cached['rooms'] as List<UserChatRoomModel>,
          slotLimit: (cached['slotLimit'] as int?) ?? state.slotLimit,
        ));
      } else if (state.chatRooms.isEmpty) {
        // ✅ فقط اعرض loading لو مفيش data موجودة في الـ state الحالي
        // ده بيمنع اختفاء الـ system chat لما loadAll بيتنادى بعد الخروج من الشات
        emit(state.copyWith(status: CubitStates.loading));
      }
    } else {
      emit(state.copyWith(status: CubitStates.loading));
    }

    final results = await Future.wait([
      _repo.getUserChatRooms(),
      _repo.getRegardRequests(),
      _repo.getMatchingChatRooms(page: 1, limit: 1),
    ]);

    final roomsResult = results[0] as dynamic;
    final requestsResult = results[1] as dynamic;
    final matchingResult = results[2] as dynamic;

    final rooms = roomsResult.fold((_) => <UserChatRoomModel>[], (r) => r.chatRooms as List<UserChatRoomModel>);
    final requests = requestsResult.fold((_) => <RegardRequestModel>[], (r) => r as List<RegardRequestModel>);
    final slotLimit = roomsResult.fold((_) => 4, (r) => (r as dynamic).slotLimit as int? ?? 4);
    final matchingCount = matchingResult.fold((_) => 0, (r) => (r as dynamic).totalCount as int? ?? 0);
    final myImageBlur = roomsResult.fold((_) => state.myImageBlur, (r) => (r as dynamic).myImageBlur as bool? ?? false);

    emit(state.copyWith(
      status: CubitStates.success,
      chatRooms: rooms,
      requests: requests,
      slotLimit: slotLimit,
      matchingCount: matchingCount,
      myImageBlur: myImageBlur,
    ));

    // ✅ حفظ في الكاش دايماً بعد الـ API (حتى لو فاضي عشان يمسح الـ cache القديم)
    if (userId != null) {
      _cacheService.saveUserChatRoomsSimple(
        userId: userId,
        chatRooms: rooms,
        slotLimit: slotLimit,
      );
    }
  }

  Future<void> loadChatRooms() async {
    final result = await _repo.getUserChatRooms();
    result.fold(
      (failure) => emit(state.copyWith(
        status: CubitStates.failure,
        errorMessage: failure.message,
      )),
      (response) {
        emit(state.copyWith(
          status: CubitStates.success,
          chatRooms: response.chatRooms,
        ));
        final userId = kCurrentUserData?.id;
        if (userId != null) {
          _saveCacheFromCurrentState(response.chatRooms);
        }
      },
    );
  }

  Future<void> acceptRequest(String requestId) async {
    final result = await _repo.acceptRegardRequest(requestId);
    result.fold(
      (_) {},
      (_) {
        final newRequests = state.requests.where((r) => r.id != requestId).toList();
        emit(state.copyWith(requests: newRequests));
        loadChatRooms();
      },
    );
  }

  Future<void> rejectRequest(String requestId) async {
    await _repo.rejectRegardRequest(requestId);
    final newRequests = state.requests.where((r) => r.id != requestId).toList();
    emit(state.copyWith(requests: newRequests));
  }
}
