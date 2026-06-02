import 'package:flutter_chatty/flutter_chatty.dart';
import 'package:flutter_chatty/src/chatty_helpers.dart';

class ChattyWidgetState {
  /// The complete list of items, also with dateSeparator items
  List<ChattyItem> items;
  bool busy;
  bool withDateSeparator;
  var initialItemCount = 0;
  ChattyWidgetState({
    this.items = const [],
    this.busy = false,
    required this.withDateSeparator,
  });

  factory ChattyWidgetState.fromInitialItems(
    List<ChattyItem> initialItems, {
    bool withDateSeparator = false,
  }) {
    final state = ChattyWidgetState(withDateSeparator: withDateSeparator);
    state.items = state._getFullItems(initialItems);
    state.initialItemCount = state.items.length;
    return state;
  }

  /// Returns the complete list, also with dateSeparator items if needed
  List<ChattyItem> _getFullItems(List<ChattyItem> items) {
    if (!withDateSeparator) {
      return items;
    }
    final List<ChattyItem> newItems = [];
    final Map<DateTime, bool> dates = {};
    for (final item in items.reversed) {
      // We reverse the list, so now the oldest entry is at index 0
      final date = ChattyHelpers.getDate(item.createdAt);
      if (!dates.containsKey(date)) {
        dates[date] = true;
        if (item.source != ChattyItemSource.dateSeparator) {
          newItems.add(ChattyItem.fromDateSeparator(date));
        }
      }
      newItems.add(item);
    }
    if (newItems.isEmpty) {
      newItems.add(ChattyItem.fromDateSeparator(DateTime.now()));
    }
    return newItems.reversed.toList();
  }
}
