import 'package:flutter/widgets.dart';
import 'package:flutter_chatty/flutter_chatty.dart';

/// Controller that handles all actions on the items.
class ChattyWidgetController {
  ChattyWidgetController({List<ChattyItem>? initialItems})
    : state = ValueNotifier<ChattyWidgetState>(
        ChattyWidgetState(items: initialItems ?? [], busy: false),
      );

  // Clean list with only messages and NO extra items like dateSeparator
  final ValueNotifier<ChattyWidgetState> state;

  void dispose() {
    state.dispose();
  }
}
