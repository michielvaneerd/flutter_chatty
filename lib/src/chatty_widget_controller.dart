import 'package:flutter_chatty/flutter_chatty.dart';
import 'package:flutter_chatty/src/chatty_widget_change_notifier.dart';

/// Controller that handles all actions on the items.
class ChattyWidgetController {
  ChattyWidgetController({List<ChattyItem>? initialItems})
    : _notifier = ChattyWidgetChangeNotifier(
        ChattyWidgetState(items: initialItems ?? [], busy: false),
      );

  // Clean list with only messages and NO extra items like dateSeparator
  final ChattyWidgetChangeNotifier _notifier;

  void dispose() {
    _notifier.dispose();
  }

  ChattyWidgetChangeNotifier getNotifier() {
    return _notifier;
  }

  List<ChattyItem> getItems() {
    return _notifier.chattyWidgetState.items;
  }

  bool getBusy() {
    return _notifier.chattyWidgetState.busy;
  }

  void update({List<ChattyItem>? items, bool? busy, bool withNotify = true}) {
    _notifier.update(
      _notifier.chattyWidgetState.copyWith(items: items, busy: busy),
      withNotify: withNotify,
    );
  }
}
