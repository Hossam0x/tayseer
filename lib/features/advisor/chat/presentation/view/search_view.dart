import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/features/advisor/chat/data/repo/chat_repo_simple.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_search_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/search_view_body.dart';

class ChatSearchView extends StatelessWidget {
  const ChatSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatSearchCubit(getIt<ChatRepoSimple>()),
      child: const Scaffold(body: ChatSearchViewBody()),
    );
  }
}
