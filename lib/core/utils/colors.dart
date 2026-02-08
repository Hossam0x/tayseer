import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

abstract class AppColors {
  static final Gradient defaultGradient = LinearGradient(
    colors: [HexColor('e26c83'), HexColor('d95f78'), HexColor('c8455f')],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static final LinearGradient backgroundGradient = LinearGradient(
    colors: [HexColor('EB7A91'), HexColor('AC1A37')],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static final Gradient textGradient = LinearGradient(
    colors: [Color(0xFFAC1A37), Color(0xFFEB7A91)],
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
  );
  static final LinearGradient blueOrangeGradient = LinearGradient(
    colors: [Color(0xff1456A1), Color(0xffF0582A)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static final LinearGradient linearGradientIcon = LinearGradient(
    colors: [HexColor('eb9dac'), HexColor('92263c')],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static List<Color> kGradineSplashColor = [
    kprimaryColor,
    HexColor('4d7bc5'),
    HexColor('9fb8e0'),
    HexColor('ffffff'),
  ];
  static List<Color> kGradineOnbardingColor = [
    // HexColor('ffffff'),
    HexColor('ffffff'),
    HexColor('fdf3f5'),
    HexColor('f9d5dc'),
    kprimaryColor,
  ];
  static List<Color> kGradineContainerColor = [
    HexColor('9fc2ee'),
    HexColor('9ec4f0'),
    HexColor('c0d4f7'),
    HexColor('dae6fe'),
    HexColor('dbe5fe'),
  ];
  static List<Color> kGradineNoteColors = [
    HexColor('f0ffff'),
    HexColor('edfdff'),
    HexColor('e3f6ff'),
    HexColor('afd5ff'),
    HexColor('81b8ff'),
    HexColor('81b8ff'),
  ];
  static List<Color> kGradineYourRequestNoteColors = [
    HexColor('e6f2ff'),
    HexColor('e3f0ff'),
    HexColor('d6e7fa'),
    HexColor('a5c1e3'),
    HexColor('a7c1e1'),
  ];
  static Color kprimaryColor = HexColor('e44e6c');
  static Color kprimaryTextColor = HexColor('ac1a37');
  static Color kscandryTextColor = HexColor('590d1c');
  static Color kScaffoldColor = HexColor('fefcfe');
  static Color ksecondaryColor = HexColor('E7F4F7');
  static Color kLightPurpleColor = HexColor('9D25DC');
  static Color kPinkColor = HexColor('CE56F6');
  static Color kMagentaColor = HexColor('F939E4');
  static Color kBlueColor = HexColor('007aff');
  static Color kLightBlueColor = HexColor('e3e0e8');
  static const Color kGreyColor = Colors.black38;
  static Color kRedColor = Colors.red;
  static Color kWhiteColor = Colors.white;
  static Color kbinkColor = HexColor('f2a6b5');
  static Color kBlueButtonTextColor = HexColor(
    '0C5AF0',
  ); // لون النص الأزرق للأزرار
  static Color kButtonBackgroundColor = HexColor(
    "0F122C",
  ).withOpacity(0.1); // خلفية الزر الشفافة

  static Color kgreyColor = HexColor('999999'); // لون رمادي
  static Color kTextGrey = HexColor('4D4D4D'); // لون رمادي فاتح
  static Color kgreyNormalColor = HexColor('BAC0CA'); // لون رمادي نص نص
  static Color kgreen = HexColor('94CF29'); //لون  الاخضر
  static Color kGreyB3 = HexColor('B3B3B3'); // new color B3B3B3
  static Color kGrey666 = HexColor('666666'); // new color 666666

  // Profile Colors
  static Color primary50 = Color.fromRGBO(252, 233, 237, 1);
  static Color primary100 = Color.fromRGBO(248, 211, 218, 1);
  static Color primary200 = Color.fromRGBO(241, 166, 181, 1);
  static Color primary300 = Color.fromRGBO(235, 122, 145, 1);
  static Color primary400 = Color.fromRGBO(228, 78, 108, 1);
  static Color primary500 = Color.fromRGBO(172, 26, 55, 1);
  static Color primary600 = Color.fromRGBO(177, 27, 57, 1);
  static Color primary800 = Color.fromRGBO(89, 13, 28, 1);
  static Color primary900 = Color.fromRGBO(44, 7, 14, 1);
  static Color cBackground100 = Color.fromRGBO(242, 166, 181, 0.56);
  static Color blueText = Color.fromRGBO(25, 41, 92, 1);
  static Color mentionBlue = Color.fromRGBO(98, 132, 255, 1);
  static Color mentionComment = Color.fromRGBO(75, 184, 249, 1);
  static Color hintText = Color.fromRGBO(153, 161, 190, 1);
  static Color secondary = Color.fromRGBO(60, 60, 67, 0.6);
  static Color secondary50 = Color.fromRGBO(242, 242, 242, 1);
  static Color secondary100 = Color.fromRGBO(230, 230, 230, 1);
  static Color secondary200 = Color.fromRGBO(204, 204, 204, 1);
  static Color secondary300 = Color.fromRGBO(179, 179, 179, 1);
  static Color secondary400 = Color.fromRGBO(153, 153, 153, 1);
  static Color secondary600 = Color.fromRGBO(102, 102, 102, 1);
  static Color secondary700 = Color.fromRGBO(77, 77, 77, 1);
  static Color secondary800 = Color.fromRGBO(51, 51, 51, 1);
  static Color secondary950 = Color.fromRGBO(255, 255, 255, 1);
  static Color primaryText = Color.fromRGBO(59, 59, 59, 1);
  static Color secondaryText = Color.fromRGBO(117, 117, 117, 1);
  static Color text2 = Color.fromRGBO(127, 127, 127, 1);
  static Color infoText = Color.fromRGBO(110, 110, 110, 1);
  static Color blackColor = Color.fromRGBO(0, 0, 0, 1);
  static Color whiteCard2Back = Color.fromRGBO(251, 251, 251, 0.64);
  static Color whiteCardBack = Color.fromRGBO(255, 255, 255, 0.46);
  static Color barGreyColor = Color.fromRGBO(117, 117, 117, 0.1);
  static Color mainColor = Color.fromRGBO(60, 180, 180, 1);
  static Color ageNumber = Color.fromRGBO(255, 80, 105, 1);

  // Boost Colors
  static const Color primaryPink = Color(0xFFE89AB8);
  static const Color darkPink = Color(0xFFD14D68);
  static const Color boostFinishBack = Color.fromRGBO(252, 233, 237, 0.45);
  static const Color boostPackageBack = Color.fromRGBO(177, 27, 57, 0.17);
  static const Color boostUnactive = Color.fromRGBO(128, 128, 128, 1);
  static Color gray2 = Color.fromRGBO(174, 174, 178, 1);
  static Color selectLocationBack = Color.fromRGBO(255, 233, 237, 0.17);

  // Settings Colors
  static Color tabsBack = Color.fromRGBO(249, 248, 236, 1);
  static Color titleCard = Color.fromRGBO(15, 23, 42, 1);
  static Color backCardBaqa = Color.fromRGBO(242, 166, 181, 0.47);
  static Color inactiveColor = Color.fromRGBO(217, 217, 217, 1);
  static Color dropDownArrow = Color.fromRGBO(60, 60, 67, 0.3);

  static Color pendingColor = Color.fromRGBO(246, 181, 81, 1);
  static Color alertColor = Color.fromRGBO(229, 69, 69, 1);

  // Success Colors - تدرجات اللون الأخضر للنجاح
  static Color success50 = Color.fromRGBO(236, 253, 245, 1); // أخضر فاتح جداً
  static Color success100 = Color.fromRGBO(209, 250, 229, 1); // أخضر فاتح
  static Color success200 = Color.fromRGBO(167, 243, 208, 1); // أخضر متوسط فاتح
  static Color success300 = Color.fromRGBO(110, 231, 183, 1); // أخضر متوسط
  static Color success400 = Color.fromRGBO(52, 211, 153, 1); // أخضر
  static Color success500 = Color.fromRGBO(16, 185, 129, 1); // أخضر أساسي
  static Color success600 = Color.fromRGBO(5, 150, 105, 1); // أخضر داكن
  static Color success700 = Color.fromRGBO(4, 120, 87, 1); // أخفر داكن جداً
  static Color success800 = Color.fromRGBO(6, 95, 70, 1); // أخضر غامق
  static Color success900 = Color.fromRGBO(6, 78, 59, 1); // أخضر غامق جداً

  // Error Colors - تدرجات اللون الأحمر للخطأ
  static Color error50 = Color.fromRGBO(254, 242, 242, 1); // أحمر فاتح جداً
  static Color error100 = Color.fromRGBO(254, 226, 226, 1); // أحمر فاتح
  static Color error200 = Color.fromRGBO(254, 202, 202, 1); // أحمر متوسط فاتح
  static Color error300 = Color.fromRGBO(252, 165, 165, 1); // أحمر متوسط
  static Color error400 = Color.fromRGBO(248, 113, 113, 1); // أحمر
  static Color error500 = Color.fromRGBO(239, 68, 68, 1); // أحمر أساسي
  static Color error600 = Color.fromRGBO(220, 38, 38, 1); // أحمر داكن
  static Color errorColor = error600; // إضافة اختصار للون الخطأ الأساسي
  static Color error700 = Color.fromRGBO(185, 28, 28, 1); // أحمر داكن جداً
  static Color error800 = Color.fromRGBO(153, 27, 27, 1); // أحمر غامق
  static Color error900 = Color.fromRGBO(127, 29, 29, 1); // أحمر غامق جداً
}
