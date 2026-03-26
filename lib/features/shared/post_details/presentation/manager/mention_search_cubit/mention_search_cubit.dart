import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/shared/post_details/data/models/mention_search_model.dart';
import 'package:tayseer/features/shared/post_details/data/repos/mention_search_repo.dart';
import 'dart:async';

part 'mention_search_state.dart';

class MentionSearchCubit extends Cubit<MentionSearchState> {
  final MentionSearchRepository mentionSearchRepo;
  Timer? _debounce;
  String? _lastQuery; // ✅ خليها nullable

  MentionSearchCubit(this.mentionSearchRepo)
    : super(const MentionSearchState());

  void searchMentions(String query) {
    if (query == _lastQuery) return;
    _lastQuery = query;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      _executeSearch('');
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 200), () {
      _executeSearch(query);
    });
  }

  Future<void> _executeSearch(String query) async {
    // ✅ لو فيه نتائج قديمة → خليها ظاهرة ومتعملش loading
    // ✅ لو مفيش نتائج قديمة → اعرض shimmer loading
    if (state.mentions.isEmpty) {
      emit(state.copyWith(state: CubitStates.loading));
    }

    final result = await mentionSearchRepo.searchMentions(query);

    result.fold(
      (failure) {
        // ✅ لو فشل وفيه نتائج قديمة، خليها كما هي
        if (state.mentions.isNotEmpty) {
          return; // متعملش حاجة، خلي القديمين ظاهرين
        }
        emit(
          state.copyWith(
            state: CubitStates.failure,
            errorMessage: failure.message,
            mentions: [],
          ),
        );
      },
      (mentions) {
        emit(state.copyWith(state: CubitStates.success, mentions: mentions));
      },
    );
  }

  void clearSearch() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _lastQuery = null; // ✅ الحل: null مش '' عشان لما يضغط @ تاني يشتغل
    emit(state.copyWith(state: CubitStates.initial, mentions: []));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
