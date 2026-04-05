// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ChatRequestsResponse {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  ChatRequestsData get data => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ChatRequestsResponseCopyWith<ChatRequestsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatRequestsResponseCopyWith<$Res> {
  factory $ChatRequestsResponseCopyWith(ChatRequestsResponse value,
          $Res Function(ChatRequestsResponse) then) =
      _$ChatRequestsResponseCopyWithImpl<$Res, ChatRequestsResponse>;
  @useResult
  $Res call({bool success, String message, ChatRequestsData data});

  $ChatRequestsDataCopyWith<$Res> get data;
}

/// @nodoc
class _$ChatRequestsResponseCopyWithImpl<$Res,
        $Val extends ChatRequestsResponse>
    implements $ChatRequestsResponseCopyWith<$Res> {
  _$ChatRequestsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as ChatRequestsData,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ChatRequestsDataCopyWith<$Res> get data {
    return $ChatRequestsDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChatRequestsResponseImplCopyWith<$Res>
    implements $ChatRequestsResponseCopyWith<$Res> {
  factory _$$ChatRequestsResponseImplCopyWith(_$ChatRequestsResponseImpl value,
          $Res Function(_$ChatRequestsResponseImpl) then) =
      __$$ChatRequestsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, String message, ChatRequestsData data});

  @override
  $ChatRequestsDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$ChatRequestsResponseImplCopyWithImpl<$Res>
    extends _$ChatRequestsResponseCopyWithImpl<$Res, _$ChatRequestsResponseImpl>
    implements _$$ChatRequestsResponseImplCopyWith<$Res> {
  __$$ChatRequestsResponseImplCopyWithImpl(_$ChatRequestsResponseImpl _value,
      $Res Function(_$ChatRequestsResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = null,
  }) {
    return _then(_$ChatRequestsResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as ChatRequestsData,
    ));
  }
}

/// @nodoc

class _$ChatRequestsResponseImpl implements _ChatRequestsResponse {
  const _$ChatRequestsResponseImpl(
      {required this.success, required this.message, required this.data});

  @override
  final bool success;
  @override
  final String message;
  @override
  final ChatRequestsData data;

  @override
  String toString() {
    return 'ChatRequestsResponse(success: $success, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatRequestsResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, success, message, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatRequestsResponseImplCopyWith<_$ChatRequestsResponseImpl>
      get copyWith =>
          __$$ChatRequestsResponseImplCopyWithImpl<_$ChatRequestsResponseImpl>(
              this, _$identity);
}

abstract class _ChatRequestsResponse implements ChatRequestsResponse {
  const factory _ChatRequestsResponse(
      {required final bool success,
      required final String message,
      required final ChatRequestsData data}) = _$ChatRequestsResponseImpl;

  @override
  bool get success;
  @override
  String get message;
  @override
  ChatRequestsData get data;
  @override
  @JsonKey(ignore: true)
  _$$ChatRequestsResponseImplCopyWith<_$ChatRequestsResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ChatRequestsData {
  List<ChatRequestModel> get requests => throw _privateConstructorUsedError;
  RequestPagination get pagination => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ChatRequestsDataCopyWith<ChatRequestsData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatRequestsDataCopyWith<$Res> {
  factory $ChatRequestsDataCopyWith(
          ChatRequestsData value, $Res Function(ChatRequestsData) then) =
      _$ChatRequestsDataCopyWithImpl<$Res, ChatRequestsData>;
  @useResult
  $Res call({List<ChatRequestModel> requests, RequestPagination pagination});

  $RequestPaginationCopyWith<$Res> get pagination;
}

/// @nodoc
class _$ChatRequestsDataCopyWithImpl<$Res, $Val extends ChatRequestsData>
    implements $ChatRequestsDataCopyWith<$Res> {
  _$ChatRequestsDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requests = null,
    Object? pagination = null,
  }) {
    return _then(_value.copyWith(
      requests: null == requests
          ? _value.requests
          : requests // ignore: cast_nullable_to_non_nullable
              as List<ChatRequestModel>,
      pagination: null == pagination
          ? _value.pagination
          : pagination // ignore: cast_nullable_to_non_nullable
              as RequestPagination,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RequestPaginationCopyWith<$Res> get pagination {
    return $RequestPaginationCopyWith<$Res>(_value.pagination, (value) {
      return _then(_value.copyWith(pagination: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChatRequestsDataImplCopyWith<$Res>
    implements $ChatRequestsDataCopyWith<$Res> {
  factory _$$ChatRequestsDataImplCopyWith(_$ChatRequestsDataImpl value,
          $Res Function(_$ChatRequestsDataImpl) then) =
      __$$ChatRequestsDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<ChatRequestModel> requests, RequestPagination pagination});

  @override
  $RequestPaginationCopyWith<$Res> get pagination;
}

/// @nodoc
class __$$ChatRequestsDataImplCopyWithImpl<$Res>
    extends _$ChatRequestsDataCopyWithImpl<$Res, _$ChatRequestsDataImpl>
    implements _$$ChatRequestsDataImplCopyWith<$Res> {
  __$$ChatRequestsDataImplCopyWithImpl(_$ChatRequestsDataImpl _value,
      $Res Function(_$ChatRequestsDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requests = null,
    Object? pagination = null,
  }) {
    return _then(_$ChatRequestsDataImpl(
      requests: null == requests
          ? _value._requests
          : requests // ignore: cast_nullable_to_non_nullable
              as List<ChatRequestModel>,
      pagination: null == pagination
          ? _value.pagination
          : pagination // ignore: cast_nullable_to_non_nullable
              as RequestPagination,
    ));
  }
}

/// @nodoc

class _$ChatRequestsDataImpl implements _ChatRequestsData {
  const _$ChatRequestsDataImpl(
      {required final List<ChatRequestModel> requests,
      required this.pagination})
      : _requests = requests;

  final List<ChatRequestModel> _requests;
  @override
  List<ChatRequestModel> get requests {
    if (_requests is EqualUnmodifiableListView) return _requests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_requests);
  }

  @override
  final RequestPagination pagination;

  @override
  String toString() {
    return 'ChatRequestsData(requests: $requests, pagination: $pagination)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatRequestsDataImpl &&
            const DeepCollectionEquality().equals(other._requests, _requests) &&
            (identical(other.pagination, pagination) ||
                other.pagination == pagination));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_requests), pagination);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatRequestsDataImplCopyWith<_$ChatRequestsDataImpl> get copyWith =>
      __$$ChatRequestsDataImplCopyWithImpl<_$ChatRequestsDataImpl>(
          this, _$identity);
}

abstract class _ChatRequestsData implements ChatRequestsData {
  const factory _ChatRequestsData(
      {required final List<ChatRequestModel> requests,
      required final RequestPagination pagination}) = _$ChatRequestsDataImpl;

  @override
  List<ChatRequestModel> get requests;
  @override
  RequestPagination get pagination;
  @override
  @JsonKey(ignore: true)
  _$$ChatRequestsDataImplCopyWith<_$ChatRequestsDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ChatRequestModel {
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get image => throw _privateConstructorUsedError;
  String get socialImage => throw _privateConstructorUsedError;
  bool get imageBlur => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ChatRequestModelCopyWith<ChatRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatRequestModelCopyWith<$Res> {
  factory $ChatRequestModelCopyWith(
          ChatRequestModel value, $Res Function(ChatRequestModel) then) =
      _$ChatRequestModelCopyWithImpl<$Res, ChatRequestModel>;
  @useResult
  $Res call(
      {String userId,
      String name,
      String image,
      String socialImage,
      bool imageBlur});
}

/// @nodoc
class _$ChatRequestModelCopyWithImpl<$Res, $Val extends ChatRequestModel>
    implements $ChatRequestModelCopyWith<$Res> {
  _$ChatRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? name = null,
    Object? image = null,
    Object? socialImage = null,
    Object? imageBlur = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String,
      socialImage: null == socialImage
          ? _value.socialImage
          : socialImage // ignore: cast_nullable_to_non_nullable
              as String,
      imageBlur: null == imageBlur
          ? _value.imageBlur
          : imageBlur // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatRequestModelImplCopyWith<$Res>
    implements $ChatRequestModelCopyWith<$Res> {
  factory _$$ChatRequestModelImplCopyWith(_$ChatRequestModelImpl value,
          $Res Function(_$ChatRequestModelImpl) then) =
      __$$ChatRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String name,
      String image,
      String socialImage,
      bool imageBlur});
}

/// @nodoc
class __$$ChatRequestModelImplCopyWithImpl<$Res>
    extends _$ChatRequestModelCopyWithImpl<$Res, _$ChatRequestModelImpl>
    implements _$$ChatRequestModelImplCopyWith<$Res> {
  __$$ChatRequestModelImplCopyWithImpl(_$ChatRequestModelImpl _value,
      $Res Function(_$ChatRequestModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? name = null,
    Object? image = null,
    Object? socialImage = null,
    Object? imageBlur = null,
  }) {
    return _then(_$ChatRequestModelImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String,
      socialImage: null == socialImage
          ? _value.socialImage
          : socialImage // ignore: cast_nullable_to_non_nullable
              as String,
      imageBlur: null == imageBlur
          ? _value.imageBlur
          : imageBlur // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ChatRequestModelImpl implements _ChatRequestModel {
  const _$ChatRequestModelImpl(
      {required this.userId,
      required this.name,
      required this.image,
      required this.socialImage,
      required this.imageBlur});

  @override
  final String userId;
  @override
  final String name;
  @override
  final String image;
  @override
  final String socialImage;
  @override
  final bool imageBlur;

  @override
  String toString() {
    return 'ChatRequestModel(userId: $userId, name: $name, image: $image, socialImage: $socialImage, imageBlur: $imageBlur)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatRequestModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.socialImage, socialImage) ||
                other.socialImage == socialImage) &&
            (identical(other.imageBlur, imageBlur) ||
                other.imageBlur == imageBlur));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, name, image, socialImage, imageBlur);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatRequestModelImplCopyWith<_$ChatRequestModelImpl> get copyWith =>
      __$$ChatRequestModelImplCopyWithImpl<_$ChatRequestModelImpl>(
          this, _$identity);
}

abstract class _ChatRequestModel implements ChatRequestModel {
  const factory _ChatRequestModel(
      {required final String userId,
      required final String name,
      required final String image,
      required final String socialImage,
      required final bool imageBlur}) = _$ChatRequestModelImpl;

  @override
  String get userId;
  @override
  String get name;
  @override
  String get image;
  @override
  String get socialImage;
  @override
  bool get imageBlur;
  @override
  @JsonKey(ignore: true)
  _$$ChatRequestModelImplCopyWith<_$ChatRequestModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RequestPagination {
  int get totalCount => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  int get pageSize => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RequestPaginationCopyWith<RequestPagination> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RequestPaginationCopyWith<$Res> {
  factory $RequestPaginationCopyWith(
          RequestPagination value, $Res Function(RequestPagination) then) =
      _$RequestPaginationCopyWithImpl<$Res, RequestPagination>;
  @useResult
  $Res call({int totalCount, int totalPages, int currentPage, int pageSize});
}

/// @nodoc
class _$RequestPaginationCopyWithImpl<$Res, $Val extends RequestPagination>
    implements $RequestPaginationCopyWith<$Res> {
  _$RequestPaginationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalCount = null,
    Object? totalPages = null,
    Object? currentPage = null,
    Object? pageSize = null,
  }) {
    return _then(_value.copyWith(
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RequestPaginationImplCopyWith<$Res>
    implements $RequestPaginationCopyWith<$Res> {
  factory _$$RequestPaginationImplCopyWith(_$RequestPaginationImpl value,
          $Res Function(_$RequestPaginationImpl) then) =
      __$$RequestPaginationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int totalCount, int totalPages, int currentPage, int pageSize});
}

/// @nodoc
class __$$RequestPaginationImplCopyWithImpl<$Res>
    extends _$RequestPaginationCopyWithImpl<$Res, _$RequestPaginationImpl>
    implements _$$RequestPaginationImplCopyWith<$Res> {
  __$$RequestPaginationImplCopyWithImpl(_$RequestPaginationImpl _value,
      $Res Function(_$RequestPaginationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalCount = null,
    Object? totalPages = null,
    Object? currentPage = null,
    Object? pageSize = null,
  }) {
    return _then(_$RequestPaginationImpl(
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$RequestPaginationImpl implements _RequestPagination {
  const _$RequestPaginationImpl(
      {required this.totalCount,
      required this.totalPages,
      required this.currentPage,
      required this.pageSize});

  @override
  final int totalCount;
  @override
  final int totalPages;
  @override
  final int currentPage;
  @override
  final int pageSize;

  @override
  String toString() {
    return 'RequestPagination(totalCount: $totalCount, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RequestPaginationImpl &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, totalCount, totalPages, currentPage, pageSize);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RequestPaginationImplCopyWith<_$RequestPaginationImpl> get copyWith =>
      __$$RequestPaginationImplCopyWithImpl<_$RequestPaginationImpl>(
          this, _$identity);
}

abstract class _RequestPagination implements RequestPagination {
  const factory _RequestPagination(
      {required final int totalCount,
      required final int totalPages,
      required final int currentPage,
      required final int pageSize}) = _$RequestPaginationImpl;

  @override
  int get totalCount;
  @override
  int get totalPages;
  @override
  int get currentPage;
  @override
  int get pageSize;
  @override
  @JsonKey(ignore: true)
  _$$RequestPaginationImplCopyWith<_$RequestPaginationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
