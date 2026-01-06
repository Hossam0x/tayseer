// import 'package:tayseer/core/widgets/custom_background.dart';
// import 'package:tayseer/core/widgets/custom_show_dialog.dart';
// import 'package:tayseer/features/auth/view_model/auth_cubit.dart';
// import 'package:tayseer/features/auth/view_model/auth_state.dart';

// import 'package:tayseer/features/the_list/view/widget/custom_switch.dart';
// import 'package:tayseer/features/the_list/view_model/language_cubit.dart';
// import 'package:tayseer/my_import.dart';

// class TheListBody extends StatefulWidget {
//   const TheListBody({super.key});

//   @override
//   State<TheListBody> createState() => _TheListBodyState();
// }

// class _TheListBodyState extends State<TheListBody>
//     with TickerProviderStateMixin {
//   bool showLanguages = false;

//   @override
//   Widget build(BuildContext context) {
//     final languageCubit = context.read<LanguageCubit>();

//     return CustomBackground(
//       showBackButton: false,
//       showDrawer: true,
//       child: CustomScrollView(
//         slivers: [
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 2),
//               child: Column(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.all(Radius.circular(50)),
//                     child: AppImage(
//                       kCurrentUserData?.image ??
//                           AssetsData.kUserPlaceholderImage,
//                       width: 100,
//                       height: 100,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     kCurrentUserData?.name ?? "guest",
//                     style: Styles.textStyle14,
//                   ),
//                   Text(
//                     kCurrentUserData?.email ?? "",
//                     style: Styles.textStyle12.copyWith(color: Colors.grey),
//                   ),
//                   const SizedBox(height: 10),
//                   if (kIsUserGuest == false)
//                     CustomBotton(
//                       width: context.width * 0.5,
//                       height: context.height * 0.07,
//                       title: context.tr('edit_profile'),
//                       onPressed:
//                           () => context.pushNamed(AppRouter.kProfileView),
//                     ),
//                 ],
//               ),
//             ),
//           ),

//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//                 decoration: _boxStyle(),
//                 child: Column(
//                   children: [
//                     buildItemRow(
//                       context,
//                       icon: AssetsData.kTermsIcon,
//                       text: "ordar",
//                       onTap: () {
//                         kIsUserGuest == false
//                             ? context.pushNamed(AppRouter.kOrderView)
//                             : CustomshowDialog(context, islogIn: true);
//                       },
//                     ),
//                     Divider(height: 30),

//                     Row(
//                       children: [
//                         AppImage(AssetsData.kNotificationIcon),
//                         SizedBox(width: 10),
//                         Text(
//                           context.tr('notification'),
//                           style: Styles.textStyle12,
//                         ),
//                         Spacer(),
//                         BlocProvider(
//                           create: (context) => NotificationsCubit(),
//                           child: BlocConsumer<
//                             NotificationsCubit,
//                             NotificationsState
//                           >(
//                             listener: (context, state) {
//                               if (state.notificationToggleState ==
//                                   CubitStates.failure) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   CustomSnackBar(
//                                     context,
//                                     text: state.errorMessage,
//                                     isSuccess: false,
//                                   ),
//                                 );
//                               } else if (state.notificationToggleState ==
//                                   CubitStates.success) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   CustomSnackBar(
//                                     context,
//                                     text: context.tr('settings_updated'),
//                                     isSuccess: true,
//                                   ),
//                                 );
//                               }
//                             },
//                             builder: (context, state) {
//                               return CustomSwitchWidget(
//                                 onChanged: (v) {
//                                   context
//                                       .read<NotificationsCubit>()
//                                       .notificationToggle();
//                                 },
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//                 decoration: _boxStyle(),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     GestureDetector(
//                       onTap:
//                           () => setState(() => showLanguages = !showLanguages),
//                       child: Row(
//                         children: [
//                           AppImage(
//                             AssetsData.klanguageIcon,
//                             color: AppColors.kprimaryColor,
//                           ),
//                           SizedBox(width: context.width * 0.03),
//                           Text(
//                             context.tr('language'),
//                             style: Styles.textStyle12,
//                           ),
//                           Spacer(),
//                           AnimatedRotation(
//                             turns: showLanguages ? -0.25 : 0,
//                             duration: Duration(milliseconds: 300),
//                             child: Icon(
//                               Icons.arrow_forward_ios,
//                               size: 18,
//                               color: AppColors.kprimaryColor,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     AnimatedSize(
//                       duration: Duration(milliseconds: 350),
//                       curve: Curves.fastOutSlowIn,
//                       child: ClipRect(
//                         child:
//                             showLanguages
//                                 ? BlocBuilder<LanguageCubit, Locale>(
//                                   builder: (context, state) {
//                                     return Column(
//                                       children: [
//                                         SizedBox(height: 12),
//                                         buildLanguageOption(
//                                           "ar",
//                                           "العربية",
//                                           state.languageCode,
//                                           languageCubit,
//                                         ),
//                                         Divider(height: 30),
//                                         buildLanguageOption(
//                                           "en",
//                                           "English",
//                                           state.languageCode,
//                                           languageCubit,
//                                         ),
//                                         SizedBox(height: 6),
//                                       ],
//                                     );
//                                   },
//                                 )
//                                 : SizedBox(),
//                       ),
//                     ),

//                     Divider(height: 35),

//                     buildItemRow(
//                       context,
//                       icon: AssetsData.kHelpIcon,
//                       text: "asked_questions",
//                       onTap: () {
//                         context.pushNamed(
//                           AppRouter.kFrequentlyAskedQuestionsView,
//                         );
//                       },
//                     ),
//                     Divider(height: 30),
//                     buildItemRow(
//                       context,
//                       icon: AssetsData.kCallUsIcon,
//                       text: "Contact_us",
//                       onTap: () {
//                         kIsUserGuest == false
//                             ? context.pushNamed(AppRouter.kConntactWithUsView)
//                             : CustomshowDialog(context, islogIn: true);
//                       },
//                     ),
//                     Divider(height: 30),
//                     buildItemRow(
//                       context,
//                       icon: AssetsData.kTermsIcon,
//                       text: "Terms_and_Conditions",
//                       onTap: () {
//                         context.pushNamed(AppRouter.kTermsAndConditionsView);
//                       },
//                     ),
//                     Divider(height: 30),
//                     buildItemRow(
//                       context,
//                       icon: AssetsData.kPrivacyIcon,
//                       text: "Privacy_Policy",
//                       onTap: () {
//                         context.pushNamed(AppRouter.kPrivacyPolicyView);
//                       },
//                     ),
//                     Divider(height: 30),

//                     BlocProvider(
//                       create: (context) => AuthCubit(),
//                       child: BlocConsumer<AuthCubit, AuthState>(
//                         listener: (context, state) {
//                           if (state.logoutState == CubitStates.success) {
//                             context.pushNamedAndRemoveUntil(
//                               predicate: (route) => false,
//                               AppRouter.kLoginScreen,
//                             );
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               CustomSnackBar(
//                                 context,
//                                 text: context.tr('logout_success'),
//                                 isSuccess: true,
//                               ),
//                             );
//                           }
//                         },
//                         builder: (context, state) {
//                           return GestureDetector(
//                             onTap: () {
//                               CustomshowDialog(
//                                 context,
//                                 islogIn: false,
//                                 onPressed: () {
//                                   context.read<AuthCubit>().logout();
//                                 },
//                                 trueChoice: context.tr('Logout'),
//                                 subTitle: context.tr('logout_confirmation'),
//                                 title: context.tr('title_logout'),
//                               );
//                             },
//                             child: Row(
//                               children: [
//                                 Icon(Icons.logout, color: Colors.red),
//                                 SizedBox(width: 10),
//                                 Text(
//                                   context.tr('Logout'),
//                                   style: Styles.textStyle12.copyWith(
//                                     color: Colors.red,
//                                   ),
//                                 ),
//                                 Spacer(),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildLanguageOption(
//     String code,
//     String name,
//     String selectedLang,
//     LanguageCubit cubit,
//   ) {
//     return InkWell(
//       onTap: () => cubit.setLanguage(code),
//       child: Row(
//         children: [
//           Text(
//             name,
//             style: Styles.textStyle12.copyWith(
//               color: selectedLang == code ? AppColors.kgreen : Colors.grey,
//               fontWeight:
//                   selectedLang == code ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//           Spacer(),
//           selectedLang == code
//               ? Icon(Icons.check, color: AppColors.kgreen)
//               : SizedBox(width: 20),
//         ],
//       ),
//     );
//   }

//   Widget buildItemRow(
//     BuildContext ctx, {
//     required String icon,
//     required String text,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Row(
//         children: [
//           AppImage(icon, color: AppColors.kprimaryColor),
//           SizedBox(width: ctx.width * 0.03),
//           Text(ctx.tr(text), style: Styles.textStyle12),
//           Spacer(),
//           Icon(
//             Icons.arrow_forward_ios,
//             size: 16,
//             color: AppColors.kprimaryColor,
//           ),
//         ],
//       ),
//     );
//   }

//   BoxDecoration _boxStyle() {
//     return BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.grey.withOpacity(0.2),
//           spreadRadius: 2,
//           blurRadius: 5,
//           offset: Offset(0, 3),
//         ),
//       ],
//     );
//   }
// }
