// core/config/nav_bar_config.dart
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/utils/assets.dart';

class NavBarItem {
  final String icon;
  final String activeIcon;
  final String labelKey;

  const NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.labelKey,
  });
}

class NavBarConfig {
  static List<NavBarItem> getNavItems(UserTypeEnum userType) {
    switch (userType) {
      case UserTypeEnum.asConsultant:
        return _consultantNavItems;
      case UserTypeEnum.user:
      case UserTypeEnum.guest:
        return _guestUserNavItems;
    }
  }

  static const List<NavBarItem> _consultantNavItems = [
    NavBarItem(
      icon: AssetsData.homeIcon,
      activeIcon: AssetsData.selectedHomeIcon,
      labelKey: "home",
    ),
    NavBarItem(
      icon: AssetsData.graySessionIcon,
      activeIcon: AssetsData.selectedSessionIcon,
      labelKey: "sessions",
    ),

    NavBarItem(
      icon: AssetsData.eventIcon,
      activeIcon: AssetsData.selectedEventIcon,
      labelKey: "event",
    ),
    NavBarItem(
      icon: AssetsData.profileIcon,
      activeIcon: AssetsData.selectedProfileIcon,
      labelKey: "profile",
    ),
  ];

  static const List<NavBarItem> _guestUserNavItems = [
    NavBarItem(
      icon: AssetsData.socialIcon,
      activeIcon: AssetsData.selectedSocialIcon,
      labelKey: "social",
    ),
    NavBarItem(
      icon: AssetsData.marriageIcon,
      activeIcon: AssetsData.selectedMarriageIcon,
      labelKey: "marriage",
    ),
    NavBarItem(
      icon: AssetsData.mySpaceIcon,
      activeIcon: AssetsData.selectedMySpaceIcon,
      labelKey: "mySpace",
    ),
    NavBarItem(
      icon: AssetsData.reactionsIcon,
      activeIcon: AssetsData.selectedReactionsIcon,
      labelKey: "reactions",
    ),

    NavBarItem(
      icon: AssetsData.profileIcon,
      activeIcon: AssetsData.selectedProfileIcon,
      labelKey: "profile",
    ),
  ];
}
