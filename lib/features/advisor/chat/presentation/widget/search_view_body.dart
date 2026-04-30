import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/constant/constans.dart';
import 'package:tayseer/core/enum/chat_room_type.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_search_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/custom_search_bar.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/search/search_result_list.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';

class ChatSearchViewBody extends StatefulWidget {
  const ChatSearchViewBody({super.key});

  @override
  State<ChatSearchViewBody> createState() => _ChatSearchViewBodyState();
}

class _ChatSearchViewBodyState extends State<ChatSearchViewBody> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final searchKey = _searchController.text.trim();

    // Determine chatRoomType based on user type
    final chatRoomType = selectedUserType == UserTypeEnum.asConsultant
        ? ChatRoomType.userAdvisor
        : ChatRoomType.userUser;

    context.read<ChatSearchCubit>().searchChatRooms(
      searchKey: searchKey,
      chatRoomType: chatRoomType,
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetsData.homeBackgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: [
                  SizedBox(
                    width: 40.w,
                    height: 40.h,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                      ),
                      iconSize: 18.sp,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: CustomSearchBar(
                      isReadOnly: false,
                      controller: _searchController,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Directionality(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                child: BlocBuilder<ChatSearchCubit, ChatSearchState>(
                  builder: (context, state) {
                    if (state is ChatSearchInitial) {
                      return Center(
                        child: Text(
                          context.tr('search_chat'),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      );
                    } else if (state is ChatSearchLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ChatSearchSuccess) {
                      return SearchResultsList(rooms: state.rooms);
                    } else if (state is ChatSearchEmpty) {
                      return SharedEmptyState(
                        title: context.tr('no_chat_for_person'),
                      );
                    } else if (state is ChatSearchError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
