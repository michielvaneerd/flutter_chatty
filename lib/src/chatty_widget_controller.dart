import 'package:flutter/widgets.dart';
import 'package:flutter_chatty/flutter_chatty.dart';

/// Controller that handles all actions on the items.
class ChattyWidgetController {
  ChattyWidgetController({List<ChattyItem>? initialItems})
    : items = ValueNotifier<List<ChattyItem>>(initialItems ?? []);

  // Clean list with only messages and NO extra items like dateSeparator
  final ValueNotifier<List<ChattyItem>> items;

  void dispose() {
    items.dispose();
  }
}
