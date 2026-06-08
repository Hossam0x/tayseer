// lib/core/widgets/ads/ad_context.dart
//
// AdContext enum — each value maps to:
//   • a NativeAdFactory ID registered on both native platforms
//   • a matching Dart widget wrapper
//
// AdService.buildContextualAd(AdContext) returns a Widget that looks
// exactly like real content in that placement.

enum AdContext {
  /// Full PostCard-style ad in the home / profile feed.
  post,

  /// Story circle with "Sponsored" label — appears in the stories row.
  story,

  /// ProfileCard-style — appears in the marriage / advisor list.
  profileCard,

  /// Generic list tile — compact, used in any scrollable list.
  listItem,
}

extension AdContextX on AdContext {
  /// The factory ID that MUST match the native registration on both platforms.
  String get factoryId {
    switch (this) {
      case AdContext.post:
        return 'postCard';
      case AdContext.story:
        return 'storyCircle';
      case AdContext.profileCard:
        return 'profileCard';
      case AdContext.listItem:
        return 'listTile';
    }
  }

  /// Default content height for the AdMob view area (not including chrome).
  double get defaultHeight {
    switch (this) {
      case AdContext.post:
        return 320;
      case AdContext.story:
        return 80;
      case AdContext.profileCard:
        return 200;
      case AdContext.listItem:
        return 72;
    }
  }
}
