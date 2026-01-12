// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_messages_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ChatMessagesState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage,
            CubitStates paginationState,
            CubitStates sendMediaState)
        loaded,
    required TResult Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage)
        loadingMore,
    required TResult Function(String message, List<ChatMessage>? cachedMessages)
        failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage,
            CubitStates paginationState,
            CubitStates sendMediaState)?
        loaded,
    TResult? Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage)?
        loadingMore,
    TResult? Function(String message, List<ChatMessage>? cachedMessages)?
        failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage,
            CubitStates paginationState,
            CubitStates sendMediaState)?
        loaded,
    TResult Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage)?
        loadingMore,
    TResult Function(String message, List<ChatMessage>? cachedMessages)?
        failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatMessagesInitial value) initial,
    required TResult Function(ChatMessagesLoading value) loading,
    required TResult Function(ChatMessagesLoaded value) loaded,
    required TResult Function(ChatMessagesLoadingMore value) loadingMore,
    required TResult Function(ChatMessagesFailure value) failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatMessagesInitial value)? initial,
    TResult? Function(ChatMessagesLoading value)? loading,
    TResult? Function(ChatMessagesLoaded value)? loaded,
    TResult? Function(ChatMessagesLoadingMore value)? loadingMore,
    TResult? Function(ChatMessagesFailure value)? failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatMessagesInitial value)? initial,
    TResult Function(ChatMessagesLoading value)? loading,
    TResult Function(ChatMessagesLoaded value)? loaded,
    TResult Function(ChatMessagesLoadingMore value)? loadingMore,
    TResult Function(ChatMessagesFailure value)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessagesStateCopyWith<$Res> {
  factory $ChatMessagesStateCopyWith(
          ChatMessagesState value, $Res Function(ChatMessagesState) then) =
      _$ChatMessagesStateCopyWithImpl<$Res, ChatMessagesState>;
}

/// @nodoc
class _$ChatMessagesStateCopyWithImpl<$Res, $Val extends ChatMessagesState>
    implements $ChatMessagesStateCopyWith<$Res> {
  _$ChatMessagesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$ChatMessagesInitialImplCopyWith<$Res> {
  factory _$$ChatMessagesInitialImplCopyWith(_$ChatMessagesInitialImpl value,
          $Res Function(_$ChatMessagesInitialImpl) then) =
      __$$ChatMessagesInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ChatMessagesInitialImplCopyWithImpl<$Res>
    extends _$ChatMessagesStateCopyWithImpl<$Res, _$ChatMessagesInitialImpl>
    implements _$$ChatMessagesInitialImplCopyWith<$Res> {
  __$$ChatMessagesInitialImplCopyWithImpl(_$ChatMessagesInitialImpl _value,
      $Res Function(_$ChatMessagesInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$ChatMessagesInitialImpl extends ChatMessagesInitial {
  const _$ChatMessagesInitialImpl() : super._();

  @override
  String toString() {
    return 'ChatMessagesState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessagesInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage,
            CubitStates paginationState,
            CubitStates sendMediaState)
        loaded,
    required TResult Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage)
        loadingMore,
    required TResult Function(String message, List<ChatMessage>? cachedMessages)
        failure,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage,
            CubitStates paginationState,
            CubitStates sendMediaState)?
        loaded,
    TResult? Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage)?
        loadingMore,
    TResult? Function(String message, List<ChatMessage>? cachedMessages)?
        failure,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage,
            CubitStates paginationState,
            CubitStates sendMediaState)?
        loaded,
    TResult Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage)?
        loadingMore,
    TResult Function(String message, List<ChatMessage>? cachedMessages)?
        failure,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatMessagesInitial value) initial,
    required TResult Function(ChatMessagesLoading value) loading,
    required TResult Function(ChatMessagesLoaded value) loaded,
    required TResult Function(ChatMessagesLoadingMore value) loadingMore,
    required TResult Function(ChatMessagesFailure value) failure,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatMessagesInitial value)? initial,
    TResult? Function(ChatMessagesLoading value)? loading,
    TResult? Function(ChatMessagesLoaded value)? loaded,
    TResult? Function(ChatMessagesLoadingMore value)? loadingMore,
    TResult? Function(ChatMessagesFailure value)? failure,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatMessagesInitial value)? initial,
    TResult Function(ChatMessagesLoading value)? loading,
    TResult Function(ChatMessagesLoaded value)? loaded,
    TResult Function(ChatMessagesLoadingMore value)? loadingMore,
    TResult Function(ChatMessagesFailure value)? failure,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class ChatMessagesInitial extends ChatMessagesState {
  const factory ChatMessagesInitial() = _$ChatMessagesInitialImpl;
  const ChatMessagesInitial._() : super._();
}

/// @nodoc
abstract class _$$ChatMessagesLoadingImplCopyWith<$Res> {
  factory _$$ChatMessagesLoadingImplCopyWith(_$ChatMessagesLoadingImpl value,
          $Res Function(_$ChatMessagesLoadingImpl) then) =
      __$$ChatMessagesLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ChatMessagesLoadingImplCopyWithImpl<$Res>
    extends _$ChatMessagesStateCopyWithImpl<$Res, _$ChatMessagesLoadingImpl>
    implements _$$ChatMessagesLoadingImplCopyWith<$Res> {
  __$$ChatMessagesLoadingImplCopyWithImpl(_$ChatMessagesLoadingImpl _value,
      $Res Function(_$ChatMessagesLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$ChatMessagesLoadingImpl extends ChatMessagesLoading {
  const _$ChatMessagesLoadingImpl() : super._();

  @override
  String toString() {
    return 'ChatMessagesState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessagesLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage,
            CubitStates paginationState,
            CubitStates sendMediaState)
        loaded,
    required TResult Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage)
        loadingMore,
    required TResult Function(String message, List<ChatMessage>? cachedMessages)
        failure,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage,
            CubitStates paginationState,
            CubitStates sendMediaState)?
        loaded,
    TResult? Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage)?
        loadingMore,
    TResult? Function(String message, List<ChatMessage>? cachedMessages)?
        failure,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage,
            CubitStates paginationState,
            CubitStates sendMediaState)?
        loaded,
    TResult Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage)?
        loadingMore,
    TResult Function(String message, List<ChatMessage>? cachedMessages)?
        failure,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatMessagesInitial value) initial,
    required TResult Function(ChatMessagesLoading value) loading,
    required TResult Function(ChatMessagesLoaded value) loaded,
    required TResult Function(ChatMessagesLoadingMore value) loadingMore,
    required TResult Function(ChatMessagesFailure value) failure,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatMessagesInitial value)? initial,
    TResult? Function(ChatMessagesLoading value)? loading,
    TResult? Function(ChatMessagesLoaded value)? loaded,
    TResult? Function(ChatMessagesLoadingMore value)? loadingMore,
    TResult? Function(ChatMessagesFailure value)? failure,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatMessagesInitial value)? initial,
    TResult Function(ChatMessagesLoading value)? loading,
    TResult Function(ChatMessagesLoaded value)? loaded,
    TResult Function(ChatMessagesLoadingMore value)? loadingMore,
    TResult Function(ChatMessagesFailure value)? failure,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class ChatMessagesLoading extends ChatMessagesState {
  const factory ChatMessagesLoading() = _$ChatMessagesLoadingImpl;
  const ChatMessagesLoading._() : super._();
}

/// @nodoc
abstract class _$$ChatMessagesLoadedImplCopyWith<$Res> {
  factory _$$ChatMessagesLoadedImplCopyWith(_$ChatMessagesLoadedImpl value,
          $Res Function(_$ChatMessagesLoadedImpl) then) =
      __$$ChatMessagesLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {List<ChatMessage> messages,
      bool hasMoreMessages,
      bool isOnline,
      int pendingCount,
      bool isBlocked,
      bool isUserTyping,
      TypingModel? typingInfo,
      ChatMessage? replyingToMessage,
      CubitStates paginationState,
      CubitStates sendMediaState});
}

/// @nodoc
class __$$ChatMessagesLoadedImplCopyWithImpl<$Res>
    extends _$ChatMessagesStateCopyWithImpl<$Res, _$ChatMessagesLoadedImpl>
    implements _$$ChatMessagesLoadedImplCopyWith<$Res> {
  __$$ChatMessagesLoadedImplCopyWithImpl(_$ChatMessagesLoadedImpl _value,
      $Res Function(_$ChatMessagesLoadedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
    Object? hasMoreMessages = null,
    Object? isOnline = null,
    Object? pendingCount = null,
    Object? isBlocked = null,
    Object? isUserTyping = null,
    Object? typingInfo = freezed,
    Object? replyingToMessage = freezed,
    Object? paginationState = null,
    Object? sendMediaState = null,
  }) {
    return _then(_$ChatMessagesLoadedImpl(
      messages: null == messages
          ? _value._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<ChatMessage>,
      hasMoreMessages: null == hasMoreMessages
          ? _value.hasMoreMessages
          : hasMoreMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      pendingCount: null == pendingCount
          ? _value.pendingCount
          : pendingCount // ignore: cast_nullable_to_non_nullable
              as int,
      isBlocked: null == isBlocked
          ? _value.isBlocked
          : isBlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      isUserTyping: null == isUserTyping
          ? _value.isUserTyping
          : isUserTyping // ignore: cast_nullable_to_non_nullable
              as bool,
      typingInfo: freezed == typingInfo
          ? _value.typingInfo
          : typingInfo // ignore: cast_nullable_to_non_nullable
              as TypingModel?,
      replyingToMessage: freezed == replyingToMessage
          ? _value.replyingToMessage
          : replyingToMessage // ignore: cast_nullable_to_non_nullable
              as ChatMessage?,
      paginationState: null == paginationState
          ? _value.paginationState
          : paginationState // ignore: cast_nullable_to_non_nullable
              as CubitStates,
      sendMediaState: null == sendMediaState
          ? _value.sendMediaState
          : sendMediaState // ignore: cast_nullable_to_non_nullable
              as CubitStates,
    ));
  }
}

/// @nodoc

class _$ChatMessagesLoadedImpl extends ChatMessagesLoaded {
  const _$ChatMessagesLoadedImpl(
      {required final List<ChatMessage> messages,
      this.hasMoreMessages = true,
      this.isOnline = true,
      this.pendingCount = 0,
      this.isBlocked = false,
      this.isUserTyping = false,
      this.typingInfo,
      this.replyingToMessage,
      this.paginationState = CubitStates.initial,
      this.sendMediaState = CubitStates.initial})
      : _messages = messages,
        super._();

  /// All messages in the current chat (from local DB)
  final List<ChatMessage> _messages;

  /// All messages in the current chat (from local DB)
  @override
  List<ChatMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  /// Whether there are more older messages to load
  @override
  @JsonKey()
  final bool hasMoreMessages;

  /// Whether the chat is connected/online
  @override
  @JsonKey()
  final bool isOnline;

  /// Number of pending messages (unsent)
  @override
  @JsonKey()
  final int pendingCount;

  /// Whether the other user is blocked
  @override
  @JsonKey()
  final bool isBlocked;

  /// Typing indicator state
  @override
  @JsonKey()
  final bool isUserTyping;

  /// Typing user info
  @override
  final TypingModel? typingInfo;

  /// Message being replied to
  @override
  final ChatMessage? replyingToMessage;

  /// Pagination state for loading older messages
  @override
  @JsonKey()
  final CubitStates paginationState;

  /// Media sending state
  @override
  @JsonKey()
  final CubitStates sendMediaState;

  @override
  String toString() {
    return 'ChatMessagesState.loaded(messages: $messages, hasMoreMessages: $hasMoreMessages, isOnline: $isOnline, pendingCount: $pendingCount, isBlocked: $isBlocked, isUserTyping: $isUserTyping, typingInfo: $typingInfo, replyingToMessage: $replyingToMessage, paginationState: $paginationState, sendMediaState: $sendMediaState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessagesLoadedImpl &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.hasMoreMessages, hasMoreMessages) ||
                other.hasMoreMessages == hasMoreMessages) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.pendingCount, pendingCount) ||
                other.pendingCount == pendingCount) &&
            (identical(other.isBlocked, isBlocked) ||
                other.isBlocked == isBlocked) &&
            (identical(other.isUserTyping, isUserTyping) ||
                other.isUserTyping == isUserTyping) &&
            (identical(other.typingInfo, typingInfo) ||
                other.typingInfo == typingInfo) &&
            (identical(other.replyingToMessage, replyingToMessage) ||
                other.replyingToMessage == replyingToMessage) &&
            (identical(other.paginationState, paginationState) ||
                other.paginationState == paginationState) &&
            (identical(other.sendMediaState, sendMediaState) ||
                other.sendMediaState == sendMediaState));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_messages),
      hasMoreMessages,
      isOnline,
      pendingCount,
      isBlocked,
      isUserTyping,
      typingInfo,
      replyingToMessage,
      paginationState,
      sendMediaState);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessagesLoadedImplCopyWith<_$ChatMessagesLoadedImpl> get copyWith =>
      __$$ChatMessagesLoadedImplCopyWithImpl<_$ChatMessagesLoadedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage,
            CubitStates paginationState,
            CubitStates sendMediaState)
        loaded,
    required TResult Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage)
        loadingMore,
    required TResult Function(String message, List<ChatMessage>? cachedMessages)
        failure,
  }) {
    return loaded(
        messages,
        hasMoreMessages,
        isOnline,
        pendingCount,
        isBlocked,
        isUserTyping,
        typingInfo,
        replyingToMessage,
        paginationState,
        sendMediaState);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage,
            CubitStates paginationState,
            CubitStates sendMediaState)?
        loaded,
    TResult? Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage)?
        loadingMore,
    TResult? Function(String message, List<ChatMessage>? cachedMessages)?
        failure,
  }) {
    return loaded?.call(
        messages,
        hasMoreMessages,
        isOnline,
        pendingCount,
        isBlocked,
        isUserTyping,
        typingInfo,
        replyingToMessage,
        paginationState,
        sendMediaState);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage,
            CubitStates paginationState,
            CubitStates sendMediaState)?
        loaded,
    TResult Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage)?
        loadingMore,
    TResult Function(String message, List<ChatMessage>? cachedMessages)?
        failure,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(
          messages,
          hasMoreMessages,
          isOnline,
          pendingCount,
          isBlocked,
          isUserTyping,
          typingInfo,
          replyingToMessage,
          paginationState,
          sendMediaState);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatMessagesInitial value) initial,
    required TResult Function(ChatMessagesLoading value) loading,
    required TResult Function(ChatMessagesLoaded value) loaded,
    required TResult Function(ChatMessagesLoadingMore value) loadingMore,
    required TResult Function(ChatMessagesFailure value) failure,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatMessagesInitial value)? initial,
    TResult? Function(ChatMessagesLoading value)? loading,
    TResult? Function(ChatMessagesLoaded value)? loaded,
    TResult? Function(ChatMessagesLoadingMore value)? loadingMore,
    TResult? Function(ChatMessagesFailure value)? failure,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatMessagesInitial value)? initial,
    TResult Function(ChatMessagesLoading value)? loading,
    TResult Function(ChatMessagesLoaded value)? loaded,
    TResult Function(ChatMessagesLoadingMore value)? loadingMore,
    TResult Function(ChatMessagesFailure value)? failure,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class ChatMessagesLoaded extends ChatMessagesState {
  const factory ChatMessagesLoaded(
      {required final List<ChatMessage> messages,
      final bool hasMoreMessages,
      final bool isOnline,
      final int pendingCount,
      final bool isBlocked,
      final bool isUserTyping,
      final TypingModel? typingInfo,
      final ChatMessage? replyingToMessage,
      final CubitStates paginationState,
      final CubitStates sendMediaState}) = _$ChatMessagesLoadedImpl;
  const ChatMessagesLoaded._() : super._();

  /// All messages in the current chat (from local DB)
  List<ChatMessage> get messages;

  /// Whether there are more older messages to load
  bool get hasMoreMessages;

  /// Whether the chat is connected/online
  bool get isOnline;

  /// Number of pending messages (unsent)
  int get pendingCount;

  /// Whether the other user is blocked
  bool get isBlocked;

  /// Typing indicator state
  bool get isUserTyping;

  /// Typing user info
  TypingModel? get typingInfo;

  /// Message being replied to
  ChatMessage? get replyingToMessage;

  /// Pagination state for loading older messages
  CubitStates get paginationState;

  /// Media sending state
  CubitStates get sendMediaState;
  @JsonKey(ignore: true)
  _$$ChatMessagesLoadedImplCopyWith<_$ChatMessagesLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ChatMessagesLoadingMoreImplCopyWith<$Res> {
  factory _$$ChatMessagesLoadingMoreImplCopyWith(
          _$ChatMessagesLoadingMoreImpl value,
          $Res Function(_$ChatMessagesLoadingMoreImpl) then) =
      __$$ChatMessagesLoadingMoreImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {List<ChatMessage> messages,
      bool hasMoreMessages,
      bool isOnline,
      int pendingCount,
      bool isBlocked,
      bool isUserTyping,
      TypingModel? typingInfo,
      ChatMessage? replyingToMessage});
}

/// @nodoc
class __$$ChatMessagesLoadingMoreImplCopyWithImpl<$Res>
    extends _$ChatMessagesStateCopyWithImpl<$Res, _$ChatMessagesLoadingMoreImpl>
    implements _$$ChatMessagesLoadingMoreImplCopyWith<$Res> {
  __$$ChatMessagesLoadingMoreImplCopyWithImpl(
      _$ChatMessagesLoadingMoreImpl _value,
      $Res Function(_$ChatMessagesLoadingMoreImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
    Object? hasMoreMessages = null,
    Object? isOnline = null,
    Object? pendingCount = null,
    Object? isBlocked = null,
    Object? isUserTyping = null,
    Object? typingInfo = freezed,
    Object? replyingToMessage = freezed,
  }) {
    return _then(_$ChatMessagesLoadingMoreImpl(
      messages: null == messages
          ? _value._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<ChatMessage>,
      hasMoreMessages: null == hasMoreMessages
          ? _value.hasMoreMessages
          : hasMoreMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      pendingCount: null == pendingCount
          ? _value.pendingCount
          : pendingCount // ignore: cast_nullable_to_non_nullable
              as int,
      isBlocked: null == isBlocked
          ? _value.isBlocked
          : isBlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      isUserTyping: null == isUserTyping
          ? _value.isUserTyping
          : isUserTyping // ignore: cast_nullable_to_non_nullable
              as bool,
      typingInfo: freezed == typingInfo
          ? _value.typingInfo
          : typingInfo // ignore: cast_nullable_to_non_nullable
              as TypingModel?,
      replyingToMessage: freezed == replyingToMessage
          ? _value.replyingToMessage
          : replyingToMessage // ignore: cast_nullable_to_non_nullable
              as ChatMessage?,
    ));
  }
}

/// @nodoc

class _$ChatMessagesLoadingMoreImpl extends ChatMessagesLoadingMore {
  const _$ChatMessagesLoadingMoreImpl(
      {required final List<ChatMessage> messages,
      this.hasMoreMessages = true,
      this.isOnline = true,
      this.pendingCount = 0,
      this.isBlocked = false,
      this.isUserTyping = false,
      this.typingInfo,
      this.replyingToMessage})
      : _messages = messages,
        super._();

  final List<ChatMessage> _messages;
  @override
  List<ChatMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  @JsonKey()
  final bool hasMoreMessages;
  @override
  @JsonKey()
  final bool isOnline;
  @override
  @JsonKey()
  final int pendingCount;
  @override
  @JsonKey()
  final bool isBlocked;
  @override
  @JsonKey()
  final bool isUserTyping;
  @override
  final TypingModel? typingInfo;
  @override
  final ChatMessage? replyingToMessage;

  @override
  String toString() {
    return 'ChatMessagesState.loadingMore(messages: $messages, hasMoreMessages: $hasMoreMessages, isOnline: $isOnline, pendingCount: $pendingCount, isBlocked: $isBlocked, isUserTyping: $isUserTyping, typingInfo: $typingInfo, replyingToMessage: $replyingToMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessagesLoadingMoreImpl &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.hasMoreMessages, hasMoreMessages) ||
                other.hasMoreMessages == hasMoreMessages) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.pendingCount, pendingCount) ||
                other.pendingCount == pendingCount) &&
            (identical(other.isBlocked, isBlocked) ||
                other.isBlocked == isBlocked) &&
            (identical(other.isUserTyping, isUserTyping) ||
                other.isUserTyping == isUserTyping) &&
            (identical(other.typingInfo, typingInfo) ||
                other.typingInfo == typingInfo) &&
            (identical(other.replyingToMessage, replyingToMessage) ||
                other.replyingToMessage == replyingToMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_messages),
      hasMoreMessages,
      isOnline,
      pendingCount,
      isBlocked,
      isUserTyping,
      typingInfo,
      replyingToMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessagesLoadingMoreImplCopyWith<_$ChatMessagesLoadingMoreImpl>
      get copyWith => __$$ChatMessagesLoadingMoreImplCopyWithImpl<
          _$ChatMessagesLoadingMoreImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage,
            CubitStates paginationState,
            CubitStates sendMediaState)
        loaded,
    required TResult Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage)
        loadingMore,
    required TResult Function(String message, List<ChatMessage>? cachedMessages)
        failure,
  }) {
    return loadingMore(messages, hasMoreMessages, isOnline, pendingCount,
        isBlocked, isUserTyping, typingInfo, replyingToMessage);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage,
            CubitStates paginationState,
            CubitStates sendMediaState)?
        loaded,
    TResult? Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage)?
        loadingMore,
    TResult? Function(String message, List<ChatMessage>? cachedMessages)?
        failure,
  }) {
    return loadingMore?.call(messages, hasMoreMessages, isOnline, pendingCount,
        isBlocked, isUserTyping, typingInfo, replyingToMessage);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage,
            CubitStates paginationState,
            CubitStates sendMediaState)?
        loaded,
    TResult Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage)?
        loadingMore,
    TResult Function(String message, List<ChatMessage>? cachedMessages)?
        failure,
    required TResult orElse(),
  }) {
    if (loadingMore != null) {
      return loadingMore(messages, hasMoreMessages, isOnline, pendingCount,
          isBlocked, isUserTyping, typingInfo, replyingToMessage);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatMessagesInitial value) initial,
    required TResult Function(ChatMessagesLoading value) loading,
    required TResult Function(ChatMessagesLoaded value) loaded,
    required TResult Function(ChatMessagesLoadingMore value) loadingMore,
    required TResult Function(ChatMessagesFailure value) failure,
  }) {
    return loadingMore(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatMessagesInitial value)? initial,
    TResult? Function(ChatMessagesLoading value)? loading,
    TResult? Function(ChatMessagesLoaded value)? loaded,
    TResult? Function(ChatMessagesLoadingMore value)? loadingMore,
    TResult? Function(ChatMessagesFailure value)? failure,
  }) {
    return loadingMore?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatMessagesInitial value)? initial,
    TResult Function(ChatMessagesLoading value)? loading,
    TResult Function(ChatMessagesLoaded value)? loaded,
    TResult Function(ChatMessagesLoadingMore value)? loadingMore,
    TResult Function(ChatMessagesFailure value)? failure,
    required TResult orElse(),
  }) {
    if (loadingMore != null) {
      return loadingMore(this);
    }
    return orElse();
  }
}

abstract class ChatMessagesLoadingMore extends ChatMessagesState {
  const factory ChatMessagesLoadingMore(
      {required final List<ChatMessage> messages,
      final bool hasMoreMessages,
      final bool isOnline,
      final int pendingCount,
      final bool isBlocked,
      final bool isUserTyping,
      final TypingModel? typingInfo,
      final ChatMessage? replyingToMessage}) = _$ChatMessagesLoadingMoreImpl;
  const ChatMessagesLoadingMore._() : super._();

  List<ChatMessage> get messages;
  bool get hasMoreMessages;
  bool get isOnline;
  int get pendingCount;
  bool get isBlocked;
  bool get isUserTyping;
  TypingModel? get typingInfo;
  ChatMessage? get replyingToMessage;
  @JsonKey(ignore: true)
  _$$ChatMessagesLoadingMoreImplCopyWith<_$ChatMessagesLoadingMoreImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ChatMessagesFailureImplCopyWith<$Res> {
  factory _$$ChatMessagesFailureImplCopyWith(_$ChatMessagesFailureImpl value,
          $Res Function(_$ChatMessagesFailureImpl) then) =
      __$$ChatMessagesFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message, List<ChatMessage>? cachedMessages});
}

/// @nodoc
class __$$ChatMessagesFailureImplCopyWithImpl<$Res>
    extends _$ChatMessagesStateCopyWithImpl<$Res, _$ChatMessagesFailureImpl>
    implements _$$ChatMessagesFailureImplCopyWith<$Res> {
  __$$ChatMessagesFailureImplCopyWithImpl(_$ChatMessagesFailureImpl _value,
      $Res Function(_$ChatMessagesFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? cachedMessages = freezed,
  }) {
    return _then(_$ChatMessagesFailureImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      cachedMessages: freezed == cachedMessages
          ? _value._cachedMessages
          : cachedMessages // ignore: cast_nullable_to_non_nullable
              as List<ChatMessage>?,
    ));
  }
}

/// @nodoc

class _$ChatMessagesFailureImpl extends ChatMessagesFailure {
  const _$ChatMessagesFailureImpl(
      {required this.message, final List<ChatMessage>? cachedMessages})
      : _cachedMessages = cachedMessages,
        super._();

  @override
  final String message;

  /// Cached messages to show while in error state
  final List<ChatMessage>? _cachedMessages;

  /// Cached messages to show while in error state
  @override
  List<ChatMessage>? get cachedMessages {
    final value = _cachedMessages;
    if (value == null) return null;
    if (_cachedMessages is EqualUnmodifiableListView) return _cachedMessages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ChatMessagesState.failure(message: $message, cachedMessages: $cachedMessages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessagesFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality()
                .equals(other._cachedMessages, _cachedMessages));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message,
      const DeepCollectionEquality().hash(_cachedMessages));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessagesFailureImplCopyWith<_$ChatMessagesFailureImpl> get copyWith =>
      __$$ChatMessagesFailureImplCopyWithImpl<_$ChatMessagesFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage,
            CubitStates paginationState,
            CubitStates sendMediaState)
        loaded,
    required TResult Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage)
        loadingMore,
    required TResult Function(String message, List<ChatMessage>? cachedMessages)
        failure,
  }) {
    return failure(message, cachedMessages);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage,
            CubitStates paginationState,
            CubitStates sendMediaState)?
        loaded,
    TResult? Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage)?
        loadingMore,
    TResult? Function(String message, List<ChatMessage>? cachedMessages)?
        failure,
  }) {
    return failure?.call(message, cachedMessages);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage,
            CubitStates paginationState,
            CubitStates sendMediaState)?
        loaded,
    TResult Function(
            List<ChatMessage> messages,
            bool hasMoreMessages,
            bool isOnline,
            int pendingCount,
            bool isBlocked,
            bool isUserTyping,
            TypingModel? typingInfo,
            ChatMessage? replyingToMessage)?
        loadingMore,
    TResult Function(String message, List<ChatMessage>? cachedMessages)?
        failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(message, cachedMessages);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatMessagesInitial value) initial,
    required TResult Function(ChatMessagesLoading value) loading,
    required TResult Function(ChatMessagesLoaded value) loaded,
    required TResult Function(ChatMessagesLoadingMore value) loadingMore,
    required TResult Function(ChatMessagesFailure value) failure,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatMessagesInitial value)? initial,
    TResult? Function(ChatMessagesLoading value)? loading,
    TResult? Function(ChatMessagesLoaded value)? loaded,
    TResult? Function(ChatMessagesLoadingMore value)? loadingMore,
    TResult? Function(ChatMessagesFailure value)? failure,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatMessagesInitial value)? initial,
    TResult Function(ChatMessagesLoading value)? loading,
    TResult Function(ChatMessagesLoaded value)? loaded,
    TResult Function(ChatMessagesLoadingMore value)? loadingMore,
    TResult Function(ChatMessagesFailure value)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class ChatMessagesFailure extends ChatMessagesState {
  const factory ChatMessagesFailure(
      {required final String message,
      final List<ChatMessage>? cachedMessages}) = _$ChatMessagesFailureImpl;
  const ChatMessagesFailure._() : super._();

  String get message;

  /// Cached messages to show while in error state
  List<ChatMessage>? get cachedMessages;
  @JsonKey(ignore: true)
  _$$ChatMessagesFailureImplCopyWith<_$ChatMessagesFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
