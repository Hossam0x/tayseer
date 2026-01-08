class ChatScrollState {
  final bool isAtBottom;
  final double scrollPosition;
  final String? highlightedMessageId;

  const ChatScrollState({
    this.isAtBottom = true,
    this.scrollPosition = 0.0,
    this.highlightedMessageId,
  });

  ChatScrollState copyWith({
    bool? isAtBottom,
    double? scrollPosition,
    String? highlightedMessageId,
    bool clearHighlightedMessageId = false,
  }) {
    return ChatScrollState(
      isAtBottom: isAtBottom ?? this.isAtBottom,
      scrollPosition: scrollPosition ?? this.scrollPosition,
      highlightedMessageId: clearHighlightedMessageId
          ? null
          : (highlightedMessageId ?? this.highlightedMessageId),
    );
  }
}
