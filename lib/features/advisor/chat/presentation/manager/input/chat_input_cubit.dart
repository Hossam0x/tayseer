import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'chat_input_state.dart';

class ChatInputCubit extends Cubit<ChatInputState> {
  Timer? _typingTimer;
  bool _isTyping = false;
  final VoidCallback? onTypingStart;
  final VoidCallback? onTypingStop;

  ChatInputCubit({this.onTypingStart, this.onTypingStop})
    : super(const ChatInputState());

  void _safeEmit(ChatInputState newState) {
    if (!isClosed) {
      emit(newState);
    }
  }

  void setReplyingToMessage(ChatMessage? message) {
    _safeEmit(
      state.copyWith(
        replyingToMessage: message,
        clearReplyingToMessage: message == null,
      ),
    );
  }

  void cancelReply() {
    _safeEmit(state.copyWith(clearReplyingToMessage: true));
  }

  void setShowEmojiPicker(bool show) {
    _safeEmit(state.copyWith(showEmojiPicker: show));
  }

  void toggleEmojiPicker() {
    _safeEmit(state.copyWith(showEmojiPicker: !state.showEmojiPicker));
  }

  void updateTextDirection(TextDirection direction) {
    if (state.textDirection != direction) {
      _safeEmit(state.copyWith(textDirection: direction));
    }
  }

  void onTextChanged(String text) {
    final newDirection = _getTextDirection(text);
    if (newDirection != state.textDirection) {
      _safeEmit(state.copyWith(textDirection: newDirection));
    }

    if (text.isNotEmpty) {
      if (!_isTyping) {
        _isTyping = true;
        onTypingStart?.call();
        log('⌨️ Started typing...');
      }

      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        if (_isTyping) {
          _isTyping = false;
          onTypingStop?.call();
          log('⌨️ Stopped typing (timeout)');
        }
      });
    } else {
      if (state.textDirection != TextDirection.rtl) {
        _safeEmit(state.copyWith(textDirection: TextDirection.rtl));
      }
      if (_isTyping) {
        _isTyping = false;
        _typingTimer?.cancel();
        onTypingStop?.call();
        log('⌨️ Stopped typing (empty text)');
      }
    }
  }

  void onMessageSent() {
    if (_isTyping) {
      _isTyping = false;
      _typingTimer?.cancel();
      onTypingStop?.call();
    }
    _safeEmit(
      state.copyWith(
        textDirection: TextDirection.rtl,
        clearReplyingToMessage: true,
      ),
    );
  }

  TextDirection _getTextDirection(String text) {
    if (text.isEmpty) return TextDirection.rtl;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final codeUnit = char.codeUnitAt(0);

      if (char == ' ' || codeUnit > 0x1F000) continue;

      if ((codeUnit >= 0x0600 && codeUnit <= 0x06FF) ||
          (codeUnit >= 0x0750 && codeUnit <= 0x077F) ||
          (codeUnit >= 0x08A0 && codeUnit <= 0x08FF) ||
          (codeUnit >= 0xFB50 && codeUnit <= 0xFDFF) ||
          (codeUnit >= 0xFE70 && codeUnit <= 0xFEFF)) {
        return TextDirection.rtl;
      }

      return TextDirection.ltr;
    }

    return TextDirection.rtl;
  }

  @override
  Future<void> close() {
    _typingTimer?.cancel();
    return super.close();
  }
}
