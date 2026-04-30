import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/widgets/error_state_widget.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_requests_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_requests_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/request/request_list.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/session_history/empty_session_widget.dart';
import 'package:tayseer/my_import.dart';

class RequestBody extends StatefulWidget {
  const RequestBody({super.key});

  @override
  State<RequestBody> createState() => _RequestBodyState();
}

class _RequestBodyState extends State<RequestBody> {
  @override
  void initState() {
    super.initState();
    context.read<ChatRequestsCubit>().loadChatRequests();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocBuilder<ChatRequestsCubit, ChatRequestsState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          failure: (message) => ErrorStateWidget(
            errorMessage: message,
            onRetry: () => context.read<ChatRequestsCubit>().loadChatRequests(),
          ),
          loaded: (requests) {
            if (requests.isEmpty) {
              return Center(
                child: EmptySessionsState(
                  title: context.tr('no_requests'),
                  subtitle: context.tr('chat_requests_appear_here'),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<ChatRequestsCubit>().loadChatRequests(),
              color: const Color(0xFFE96E88),
              child: ListView.separated(
                padding: EdgeInsetsDirectional.only(
                  bottom: screenHeight * 0.12,
                  start: 16,
                  end: 16,
                  top: 8,
                ),
                itemCount: requests.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey.shade200,
                  height: MediaQuery.of(context).size.width < 600 ? 0.5 : 1,
                ),
                itemBuilder: (context, index) {
                  return RequestListTile(item: requests[index]);
                },
              ),
            );
          },
        );
      },
    );
  }
}
