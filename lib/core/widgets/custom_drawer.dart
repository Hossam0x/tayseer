// import 'package:tayseer/core/utils/router/route_observers.dart';
// import 'package:tayseer/core/widgets/custom_show_dialog.dart';
// import 'package:tayseer/features/auth/view_model/auth_cubit.dart';
// import 'package:tayseer/features/auth/view_model/auth_state.dart';

// import '../../my_import.dart';

// class CustomDrawer extends StatelessWidget {
//   const CustomDrawer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: Colors.white,
//       width: context.width * 0.7,
//       elevation: 0,
//       child: SafeArea(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 20),
//               child: Column(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.all(Radius.circular(50)),
//                     child: AppImage(
//                       kCurrentUserData?.image ??
//                           AssetsData.kUserPlaceholderImage,
//                       width: 80,
//                       height: 80,
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
//                       onPressed: () {
//                         context.pushNamed(AppRouter.kProfileView);
//                       },
//                     ),
//                 ],
//               ),
//             ),

//             divider(context),

//             Directionality(
//               textDirection: TextDirection.rtl,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 5),
//                 child: Column(
//                   children: [
//                     buildItem(
//                       context,
//                       AssetsData.kProfileIcon,
//                       context.tr('profile'),
//                       AppRouter.kProfileView,
//                     ),
//                     divider(context),

//                     buildItem(
//                       context,
//                       AssetsData.kMessagesIcon,
//                       context.tr('messges'),
//                       AppRouter.kChatView,
//                     ),
//                     divider(context),

//                     buildItem(
//                       context,
//                       AssetsData.kCallUsIcon,
//                       context.tr('Contact_us'),
//                       AppRouter.kConntactWithUsView,
//                     ),
//                     divider(context),

//                     buildItem(
//                       context,
//                       AssetsData.kTermsIcon,
//                       context.tr('Terms_and_Conditions'),
//                       AppRouter.kTermsAndConditionsView,
//                     ),
//                     divider(context),

//                     buildItem(
//                       context,
//                       AssetsData.kPrivacyIcon,
//                       context.tr('Privacy_Policy'),
//                       AppRouter.kPrivacyPolicyView,
//                     ),
//                     divider(context),

//                     buildItem(
//                       context,
//                       AssetsData.kHelpIcon,
//                       context.tr('Help_and_Support'),
//                       AppRouter.kFrequentlyAskedQuestionsView,
//                     ),
//                     divider(context),
//                   ],
//                 ),
//               ),
//             ),

//             BlocProvider(
//               create: (context) => AuthCubit(),
//               child: BlocConsumer<AuthCubit, AuthState>(
//                 listener: (context, state) {
//                   if (state.logoutState == CubitStates.success) {
//                     context.pushNamedAndRemoveUntil(
//                       predicate: (route) => false,
//                       AppRouter.kLoginScreen,
//                     );
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       CustomSnackBar(
//                         context,
//                         text: context.tr('logout_success'),
//                         isSuccess: true,
//                       ),
//                     );
//                   }
//                 },
//                 builder: (context, state) {
//                   return ListTile(
//                     onTap: () {
//                       CustomshowDialog(
//                         context,
//                         islogIn: false,
//                         onPressed: () {
//                           context.read<AuthCubit>().logout();
//                         },
//                         trueChoice: context.tr('Logout'),
//                         subTitle: context.tr('logout_confirmation'),
//                         title: context.tr('title_logout'),
//                       );
//                     },
//                     leading: const Icon(
//                       Icons.logout,
//                       color: Colors.red,
//                       size: 20,
//                     ),
//                     title: Text(
//                       context.tr('Logout'),
//                       style: Styles.textStyle12.copyWith(color: Colors.red),
//                       textAlign: TextAlign.right,
//                     ),
//                     trailing: const SizedBox(width: 10),
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 10),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildItem(
//     BuildContext context,
//     String icon,
//     String text,
//     String route,
//   ) {
//     final isSelected = DrawerRouteObserver.currentRoute == route;

//     return GestureDetector(
//       onTap: () {
//         if (!isSelected) {
//           Navigator.pop(context);
//           kIsUserGuest == false
//               ? context.pushNamed(route)
//               : CustomshowDialog(context, islogIn: true);
//         } else {
//           Navigator.pop(context);
//         }
//       },

//       child: Row(
//         children: [
//           ColorFiltered(
//             colorFilter: ColorFilter.mode(
//               isSelected ? AppColors.kprimaryColor : const Color(0XFF7A7A7A),
//               BlendMode.srcIn,
//             ),
//             child: AppImage(icon),
//           ),
//           SizedBox(width: context.width * 0.03),

//           Text(
//             text,
//             style: Styles.textStyle12.copyWith(
//               color: isSelected ? AppColors.kprimaryColor : Colors.black,
//             ),
//           ),

//           const Spacer(),

//           Icon(
//             Icons.arrow_forward_ios,
//             size: 14,
//             color: isSelected ? AppColors.kprimaryColor : Colors.black,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget divider(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: context.height * 0.02),
//       child: Container(
//         height: 0.75,
//         width: double.infinity,
//         color: const Color(0XFFEDEDED),
//       ),
//     );
//   }
// }
