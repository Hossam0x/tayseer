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
  static Color primary50 = Color.fromRGBO(252, 235, 238, 1);
  static Color primary100 = Color.fromRGBO(248, 211, 218, 1);
  static Color primary200 = Color.fromRGBO(241, 166, 181, 1);
  static Color primary300 = Color.fromRGBO(235, 122, 145, 1);
  static Color primary400 = Color.fromRGBO(228, 78, 108, 1);
  static Color primary500 = Color.fromRGBO(172, 26, 55, 1);
  static Color primary600 = Color.fromRGBO(177, 27, 57, 1);
  static Color primary900 = Color.fromRGBO(44, 7, 14, 1);
  static Color cBackground100 = Color.fromRGBO(242, 166, 181, 0.56);
  static Color blueText = Color.fromRGBO(25, 41, 92, 1);
  static Color mentionBlue = Color.fromRGBO(98, 132, 255, 1);
  static Color mentionComment = Color.fromRGBO(75, 184, 249, 1);
  static Color hintText = Color.fromRGBO(153, 161, 190, 1);
  static Color secondary = Color.fromRGBO(60, 60, 67, 0.6);
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

  // Boost Colors
  static const Color primaryPink = Color(0xFFE89AB8);
  static const Color darkPink = Color(0xFFD14D68);
  static const Color boostFinishBack = Color.fromRGBO(252, 233, 237, 0.45);
  static const Color boostPackageBack = Color.fromRGBO(177, 27, 57, 0.17);
  static const Color boostUnactive = Color.fromRGBO(128, 128, 128, 1);
}
