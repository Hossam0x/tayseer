import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/custom_search_bar.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/search/search_result_list.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';

class ChatSearchViewBody extends StatefulWidget {
  const ChatSearchViewBody({super.key});

  @override
  State<ChatSearchViewBody> createState() => _ChatSearchViewBodyState();
}

class _ChatSearchViewBodyState extends State<ChatSearchViewBody> {
  bool hasResults = true;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final paddingH = isMobile ? 12.0 : 16.0;
    final paddingV = isMobile ? 8.0 : 10.0;
    final iconButtonSize = isMobile ? 40.0 : 48.0;

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
              padding: EdgeInsets.symmetric(
                horizontal: paddingH,
                vertical: paddingV,
              ),
              child: Row(
                children: [
                  // زرار الرجوع
                  SizedBox(
                    width: iconButtonSize,
                    height: iconButtonSize,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                      ),
                      iconSize: isMobile ? 18 : 20,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  SizedBox(width: isMobile ? 4.0 : 8.0),
                  Expanded(
                    child: CustomSearchBar(
                      isReadOnly: false,
                      controller: _searchController,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),

            TextButton(
              onPressed: () {
                setState(() {
                  hasResults = !hasResults;
                });
              },
              child: Text(
                hasResults
                    ? "اضغط لتجربة الحالة الفارغة"
                    : "اضغط لتجربة القائمة",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
            ),

            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: hasResults
                    ? const SearchResultsList()
                    : const SharedEmptyState(
                        title: ". لا يوجد محادثة لهذا الشخص",
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
