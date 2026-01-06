import 'dart:ui';

import 'package:tayseer/features/advisor/add_post/view_model/add_post_cubit.dart';
import 'package:tayseer/features/advisor/add_post/view_model/add_post_state.dart';
import 'package:tayseer/my_import.dart';

class GifBottomSheet extends StatefulWidget {
  const GifBottomSheet({super.key, required this.cubit});
  final AddPostCubit cubit;

  @override
  State<GifBottomSheet> createState() => _GifBottomSheetState();
}

class _GifBottomSheetState extends State<GifBottomSheet> {
  late final Set<String> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = Set<String>.from(widget.cubit.state.selectedGifs);
  }

  void _toggleTemp(String url) {
    setState(() {
      if (_tempSelected.contains(url)) {
        _tempSelected.remove(url);
      } else {
        _tempSelected.add(url);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = widget.cubit;

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<AddPostCubit, AddPostState>(
        builder: (context, state) {
          final gifs = state.availableGifs;
          return Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: SafeArea(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                  child: Container(
                    height: context.height * 0.9,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey.withOpacity(0.1),
                          Colors.grey.withOpacity(0.10),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Center(
                            child: Text(
                              context.tr('select_gif'),
                              style: Styles.textStyle16,
                            ),
                          ),
                        ),

                        // HEADER
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  cubit.commitSelectedGifs(
                                    _tempSelected.toList(),
                                  );
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  context.tr('lode'),
                                  style: Styles.textStyle18SemiBold.copyWith(
                                    color: AppColors.kBlueColor,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.pop(),
                                child: Text(
                                  context.tr('close'),
                                  style: Styles.textStyle18SemiBold.copyWith(
                                    color: AppColors.kBlueColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // GIF grid
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.all(8),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                ),
                            itemCount: gifs.length,
                            itemBuilder: (_, index) {
                              final gif = gifs[index];
                              final isSelected = _tempSelected.contains(gif);
                              return GestureDetector(
                                onTap: () => _toggleTemp(gif),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: AppImage(gif, fit: BoxFit.cover),
                                    ),
                                    if (isSelected)
                                      Container(
                                        color: Colors.black.withOpacity(0.35),
                                        alignment: Alignment.topRight,
                                        padding: const EdgeInsets.all(6),
                                        child: Icon(
                                          Icons.check_circle,
                                          color: AppColors.kBlueColor,
                                          size: 22,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
