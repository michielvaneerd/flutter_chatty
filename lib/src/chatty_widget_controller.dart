import 'package:flutter/widgets.dart';
import 'package:flutter_chatty/flutter_chatty.dart';
import 'package:flutter_chatty/src/chatty_widget_change_notifier.dart';

/// Controller that mutates the ChattyWidgetState and does action on the GlobalKey and then call the notifyListeners on the ChattyWidgetChangeNotifier
class ChattyWidgetController {
  ChattyWidgetController({
    List<ChattyItem>? initialItems,
    bool withDateseparator = false,
  }) : _notifier = ChattyWidgetChangeNotifier(
         ChattyWidgetState.fromInitialItems(
           initialItems ?? [],
           withDateSeparator: withDateseparator,
         ),
       );

  // Clean list with only messages and NO extra items like dateSeparator
  final ChattyWidgetChangeNotifier _notifier;

  /// Only needed if you have animated = true.
  GlobalKey<AnimatedListState>? _animatedListKey;

  GlobalKey<AnimatedListState> getAnimatedListKey() {
    _animatedListKey ??= GlobalKey<AnimatedListState>();
    return _animatedListKey!;
  }

  void dispose() {
    _notifier.dispose();
  }

  int getInitialItemCount() {
    return _notifier.chattyWidgetState.initialItemCount;
  }

  ChattyWidgetChangeNotifier getNotifier() {
    return _notifier;
  }

  void replaceAt(int index, ChattyItem item, {bool withNotify = true}) {
    _notifier.chattyWidgetState.items[index] = item;
    if (withNotify) {
      _notifier.notify();
    }
  }

  void insertAt(int index, ChattyItem item, {bool withNotify = true}) {
    _notifier.chattyWidgetState.items.insert(index, item);
    getAnimatedListKey().currentState?.insertItem(index);
    if (withNotify) {
      _notifier.notify();
    }
  }

  void removeAt(int index, {bool withNotify = true}) {
    _notifier.chattyWidgetState.items.removeAt(index);
    getAnimatedListKey().currentState?.removeItem(
      index,
      (context, animation) => SizedBox.shrink(),
    );
    if (withNotify) {
      _notifier.notify();
    }
  }

  /// Returns the full list, including dateSeparator items
  List<ChattyItem> getItems() {
    return _notifier.chattyWidgetState.items;
  }

  /// Returns the list with only user and assistant message items
  List<ChattyItem> getMessageItems() {
    return _notifier.chattyWidgetState.items
        .where((e) => e.source != ChattyItemSource.dateSeparator)
        .toList();
  }

  void setBusy(bool busy, {bool withNotify = true}) {
    _notifier.chattyWidgetState.busy = busy;
    if (withNotify) {
      _notifier.notify();
    }
  }

  bool getBusy() {
    return _notifier.chattyWidgetState.busy;
  }

  /// Clears all items and optionally sets a new list of items
  /// This is also the only place to change the withDateseparator property
  void clear({
    List<ChattyItem>? initialItems,
    bool withDateseparator = false,
    bool withNotify = true,
  }) {
    final newChattyWidgetState = ChattyWidgetState.fromInitialItems(
      initialItems ?? [],
      withDateSeparator: withDateseparator,
    );
    getAnimatedListKey().currentState?.removeAllItems(
      (context, animation) => SizedBox.shrink(),
    );
    getAnimatedListKey().currentState?.insertAllItems(
      0,
      newChattyWidgetState.initialItemCount,
    );
    _notifier.chattyWidgetState = newChattyWidgetState;
    if (withNotify) {
      _notifier.notify();
    }
  }
}
