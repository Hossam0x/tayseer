import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/chat_list_builder.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/chat_view_header.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/new_chat_floating_button.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';

class ChatViewBody extends StatefulWidget {
  const ChatViewBody({super.key});

  @override
  State<ChatViewBody> createState() => _ChatViewBodyState();
}

class _ChatViewBodyState extends State<ChatViewBody> {
  bool hasChats = true;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isMobile = screenWidth < 600;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AssetsData.homeBackgroundImage),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              ChatViewHeader(
                isChatsSelected: hasChats,
                onChatTap: () {
                  if (!hasChats) {
                    setState(() {
                      hasChats = true;
                    });
                  }
                },
                onSessionTap: () {
                  if (hasChats) {
                    setState(() {
                      hasChats = false;
                    });
                  }
                },
              ),

              // ---------------------------------------------
              // ... داخل ChatViewBody
              Expanded(
                child: hasChats
                    ? const ChatListBuilder()
                    : SharedEmptyState(
                        title: "لا توجد محادثات حتى الآن .",
                        subTitleWidget: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Cairo',
                              fontSize: isMobile ? 12 : 14,
                            ),
                            children: [
                              const TextSpan(
                                text: "اشترك ",
                                style: TextStyle(
                                  color: Color(0xFFE96E88),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(
                                text: "لتظهر في الاعلى ليبادر الاشخاص بمحادثتك",
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: hasChats ? const NewChatFloatingButton() : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
