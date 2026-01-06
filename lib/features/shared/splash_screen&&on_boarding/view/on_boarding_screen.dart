// import 'dart:math' as math;
// import 'package:tayseer/features/shared/splash_screen&&on_boarding/view/widgets/glass_language_picker.dart';

// import '../../../../../my_import.dart';

// class OnBoardingScreen extends StatefulWidget {
//   const OnBoardingScreen({super.key});

//   @override
//   State<OnBoardingScreen> createState() => _OnBoardingScreenState();
// }

// class _OnBoardingScreenState extends State<OnBoardingScreen> {
//   final PageController _pageController = PageController();
//   int currentPage = 0;

//   void _finishOnBoarding() async {
//     await CachNetwork.setBool(key: 'onBoarding', value: true);
//     kShowOnBoarding = true;

//     if (!mounted) return;
//     Navigator.pushReplacementNamed(context, AppRouter.kRegisrationView);
//   }

//   void _nextPage() {
//     if (currentPage < 3) {
//       _pageController.nextPage(
//         duration: const Duration(milliseconds: 400),
//         curve: Curves.easeInOut,
//       );
//     } else {
//       _finishOnBoarding();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final List<_OnBoardingModel> pages = [
//       _OnBoardingModel(
//         image: AssetsData.kOnboarding1,
//         title: context.tr('onBording_text1'),
//         description: context.tr('onBording_desc1'),
//       ),
//       _OnBoardingModel(
//         image: AssetsData.kOnboarding2,
//         title: context.tr('onBording_text2'),
//         description: context.tr('onBording_desc2'),
//       ),
//       _OnBoardingModel(
//         image: AssetsData.kOnboarding3,
//         title: context.tr('onBording_text3'),
//         description: context.tr('onBording_desc3'),
//       ),
//       _OnBoardingModel(
//         image: AssetsData.kOnboarding4,
//         title: context.tr('onBording_text4'),
//         description: context.tr('onBording_desc4'),
//       ),
//     ];

//     return Scaffold(
//       body: Stack(
//         children: [
//           AppImage(
//             fit: BoxFit.fill,
//             AssetsData.kOnboardingBackgroundImage,
//             width: context.width,
//             height: context.height,
//           ),

//           PageView.builder(
//             controller: _pageController,
//             onPageChanged: (index) => setState(() => currentPage = index),
//             itemCount: pages.length,
//             itemBuilder: (context, index) {
//               final page = pages[index];

//               return Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   Align(
//                     alignment: Alignment(0, 10),
//                     child: AppImage(
//                           width: context.width,
//                           height: context.height * 0.98,
//                           page.image,
//                           fit: BoxFit.cover,
//                         )
//                         .animate()
//                         .fadeIn(duration: const Duration(milliseconds: 600))
//                         .scale(
//                           begin: const Offset(0.8, 0.8),
//                           end: const Offset(1.0, 1.0),
//                           duration: const Duration(milliseconds: 600),
//                         ),
//                   ),

//                   Positioned(
//                     top: context.height * 0.6,
//                     left: 30,
//                     right: 30,
//                     child: Column(
//                       children: [
//                         Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   page.title,
//                                   textAlign: TextAlign.center,
//                                   style: Styles.textStyle20.copyWith(
//                                     color: HexColor('ac1a37'),
//                                     fontWeight: FontWeight.bold,
//                                     height: 1.3,
//                                   ),
//                                 ),
//                                 AppImage(
//                                   fit: BoxFit.cover,
//                                   AssetsData.kAppLogo,
//                                   width: context.width * 0.2,
//                                   height: context.height * 0.06,
//                                 ),
//                               ],
//                             )
//                             .animate()
//                             .fadeIn(duration: const Duration(milliseconds: 500))
//                             .slideY(begin: 0.4, end: 0),

//                         const SizedBox(height: 16),

//                         Text(
//                               page.description,
//                               textAlign: TextAlign.center,
//                               style: Styles.textStyle14.copyWith(
//                                 color: Colors.white,
//                                 height: 1.5,
//                               ),
//                             )
//                             .animate()
//                             .fadeIn(duration: const Duration(milliseconds: 700))
//                             .slideY(begin: 0.4, end: 0),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),

//           Positioned(
//             top: context.height * 0.07,
//             right: context.width * 0.06,
//             child: InkWell(
//               onTap: _finishOnBoarding,
//               child: Text(
//                 context.tr('skip'),
//                 style: Styles.textStyle18.copyWith(
//                   color: AppColors.kWhiteColor,
//                   fontWeight: FontWeight.normal,
//                   decoration: TextDecoration.underline,
//                   decorationColor: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: context.height * 0.013,
//             right: -context.width * 0.6,
//             left: 0,
//             child: Column(
//               children: [
//                 GestureDetector(
//                   onTap: _nextPage,
//                   child: SizedBox(
//                         width: 90,
//                         height: 90,
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             // الدائرة الخارجية مع Progress
//                             TweenAnimationBuilder<double>(
//                               tween: Tween(
//                                 begin: 0,
//                                 end: (currentPage + 1) / pages.length,
//                               ),
//                               duration: const Duration(milliseconds: 500),
//                               builder: (context, value, child) {
//                                 return CustomPaint(
//                                   size: Size(80, 80),
//                                   painter: _CircularProgressPainter(
//                                     progress: value,
//                                     color: AppColors.kprimaryColor,
//                                   ),
//                                 );
//                               },
//                             ),

//                             // الدائرة البيضاء الداخلية
//                             Container(
//                               width: 70,
//                               height: 70,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 gradient: RadialGradient(
//                                   center: Alignment.center,
//                                   radius: 1.0,
//                                   colors: AppColors.kGradineOnbardingColor,
//                                 ),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: AppColors.kprimaryColor.withOpacity(
//                                       0.3,
//                                     ),
//                                     blurRadius: 15,
//                                     spreadRadius: 2,
//                                   ),
//                                 ],
//                               ),
//                               child: Directionality(
//                                 textDirection: TextDirection.ltr,
//                                 child: Icon(
//                                   Icons.arrow_forward_ios,
//                                   color: AppColors.kprimaryColor,
//                                   size: 28,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                       .animate(onPlay: (controller) => controller.repeat())
//                       .shimmer(
//                         duration: const Duration(seconds: 2),
//                         color: Colors.white.withOpacity(0.3),
//                       ),
//                 ),
//               ],
//             ),
//           ),
//           Positioned(
//             left: context.width * 0.06,
//             top: context.height * 0.07,
//             child: GlassLanguagePicker(),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
// }

// class _OnBoardingModel {
//   final String image;
//   final String title;
//   final String description;

//   _OnBoardingModel({
//     required this.image,
//     required this.title,
//     required this.description,
//   });
// }

// class _CircularProgressPainter extends CustomPainter {
//   final double progress;
//   final Color color;

//   _CircularProgressPainter({required this.progress, required this.color});

//   @override
//   void paint(Canvas canvas, Size size) {
//     double strokeWidth = 4;
//     double radius = (size.width / 2) - strokeWidth / 2;
//     Offset center = Offset(size.width / 2, size.height / 2);

//     // رسم الخلفية
//     Paint backgroundPaint =
//         Paint()
//           ..color = color.withOpacity(0.2)
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = strokeWidth;

//     canvas.drawCircle(center, radius, backgroundPaint);

//     // رسم Progress
//     Paint progressPaint =
//         Paint()
//           ..color = color
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = strokeWidth
//           ..strokeCap = StrokeCap.round;

//     double startAngle = -math.pi / 2;
//     double sweepAngle = 2 * math.pi * progress;

//     canvas.drawArc(
//       Rect.fromCircle(center: center, radius: radius),
//       startAngle,
//       sweepAngle,
//       false,
//       progressPaint,
//     );
//   }

//   @override
//   bool shouldRepaint(_CircularProgressPainter oldDelegate) =>
//       oldDelegate.progress != progress || oldDelegate.color != color;
// }
