import 'package:flutter/widgets.dart';
import 'package:flutter_chatty/flutter_chatty.dart';
import 'package:flutter_chatty/src/chatty_widget_change_notifier.dart';

/// Controller that mutates the ChattyWidgetState and does action on the GlobalKey and then call the notifyListeners on the ChattyWidgetChangeNotifier.
/// Because it manages the items, it needs to have the animated and withDateSeparator properties, because these impact on how to manage the items.
class ChattyWidgetController {
  ChattyWidgetController({
    List<ChattyItem>? initialItems,
    this.withDateSeparator = defaultWithDateSeparator,
    this.animated = defaultAnimated,
  }) : _notifier = ChattyWidgetChangeNotifier(
         ChattyWidgetState.fromInitialItems(initialItems ?? []),
       );

  static const defaultAnimated = true;
  static const defaultWithDateSeparator = true;

  /// Whether new chat messages should be animated
  bool animated;

  /// Whether the date should be displayed
  bool withDateSeparator;

  // Clean list with only messages and NO extra items like dateSeparator
  final ChattyWidgetChangeNotifier _notifier;

  /// Only needed if animated = true.
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
    if (animated) {
      getAnimatedListKey().currentState?.insertItem(index);
    }
    if (withNotify) {
      _notifier.notify();
    }
  }

  void removeAt(int index, {bool withNotify = true}) {
    _notifier.chattyWidgetState.items.removeAt(index);
    if (animated) {
      getAnimatedListKey().currentState?.removeItem(
        index,
        (context, animation) => SizedBox.shrink(),
      );
    }
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
  void clear({
    List<ChattyItem>? initialItems,
    bool? withDateSeparator,
    bool? animated,
    bool withNotify = true,
  }) {
    if (animated != null) {
      this.animated = animated;
    }
    if (withDateSeparator != null) {
      this.withDateSeparator = withDateSeparator;
    }

    final newChattyWidgetState = ChattyWidgetState.fromInitialItems(
      initialItems ?? [],
      withDateSeparator: this.withDateSeparator,
    );
    if (this.animated) {
      getAnimatedListKey().currentState?.removeAllItems(
        (context, animation) => SizedBox.shrink(),
      );
      getAnimatedListKey().currentState?.insertAllItems(
        0,
        newChattyWidgetState.initialItemCount,
      );
    }
    _notifier.chattyWidgetState = newChattyWidgetState;
    if (withNotify) {
      _notifier.notify();
    }
  }
}
