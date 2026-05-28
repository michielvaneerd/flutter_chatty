import 'package:flutter/material.dart';
import 'package:flutter_chatty/flutter_chatty.dart';

class ChattyWidgetChangeNotifier with ChangeNotifier {
  ChattyWidgetState chattyWidgetState;
  ChattyWidgetChangeNotifier(this.chattyWidgetState);

  void update(ChattyWidgetState newChattyWidgetState) {
    chattyWidgetState = newChattyWidgetState;
    notifyListeners();
  }
}
