class EmojiHelper {
  EmojiHelper._();

  static final _emojiRegex = RegExp(
    r'\p{Extended_Pictographic}',
    unicode: true,
  );

  static final _nonEmojiRegex = RegExp(
    r'[^\p{Extended_Pictographic}\u{1F3FB}-\u{1F3FF}\u{1F1E6}-\u{1F1FF}\u{E0020}-\u{E007F}\u200d\ufe0f\u20e3\s]',
    unicode: true,
  );

  /// Check if text contains only emoji characters (and modifiers/whitespace)
  static bool isOnlyEmojis(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    if (!_emojiRegex.hasMatch(trimmed)) return false;
    return !_nonEmojiRegex.hasMatch(trimmed);
  }

  /// Count the number of base emoji pictographics in text
  static int emojiCount(String text) {
    return _emojiRegex.allMatches(text.trim()).length;
  }

  /// Check if text is a single emoji (possibly with modifiers like skin tone)
  static bool isSingleEmoji(String text) {
    return isOnlyEmojis(text) && emojiCount(text) == 1;
  }
}
