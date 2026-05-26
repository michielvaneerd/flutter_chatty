import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatty/src/chatty_helpers.dart';
import 'package:flutter_chatty/src/models.dart';

/// ChattyWidgetState contains the state for the ChattyWidget
class ChattyWidgetState extends Equatable {
  final bool busy;

  /// This error is only for errors that are not displayed as assistant messages.
  final String? error;
  final List<ChattyItem> items;

  const ChattyWidgetState({this.busy = false, this.error, required this.items});
  @override
  List<Object?> get props => [busy, error, items];

  ChattyWidgetState copyWith({
    List<ChattyItem>? items,
    bool busy = false,
    String? error,
    bool removeError = true,
  }) {
    return ChattyWidgetState(
      items: items ?? this.items,
      busy: busy,
      error: removeError ? null : (error ?? this.error),
    );
  }
}

class ChattyWidgetCubit extends Cubit<ChattyWidgetState> {
  ChattyWidgetCubit({
    required this.onPrompt,
    this.initialItems,
    this.withDateSeparator = false,
  }) : super(
         ChattyWidgetState(
           items: _getFullItems(initialItems ?? [], withDateSeparator),
         ),
       );
  final Future<ChattyItem> Function(String content, {String? value}) onPrompt;
  final List<ChattyItem>? initialItems;
  final bool withDateSeparator;

  static List<ChattyItem> _getFullItems(
    List<ChattyItem> items,
    bool withDateSeparator,
  ) {
    if (!withDateSeparator) {
      return items;
    }
    // Items has the most recent item at index 0
    // So instead of ADDING the date separator to the END of the list BEFORE the first message with a new date
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
    return newItems.reversed.toList();
  }

  /// Handle new user prompt
  void prompt(String prompt, {String? value}) async {
    // First make copy of current items without date separators
    // List<ChattyItem> newItems = state.items
    //     .where((e) => e.source != ChattyItemSource.dateSeparator)
    //     .toList();

    List<ChattyItem> newItems = List<ChattyItem>.from(state.items);

    if (state.items.isNotEmpty && state.items.first.question != null) {
      // This is an answer to this question. We remove the question from this item,
      // so then it will be a normal assistant message without answering options anymore.
      newItems[0] = newItems.first.copyWith(removeQuestion: true);
    }

    // Add the user answer to the items
    newItems.insert(0, ChattyItem.fromUser(prompt));

    emit(
      state.copyWith(
        //busy: true,
        items: _getFullItems(newItems, withDateSeparator),
      ),
    );

    await Future.delayed(Duration(milliseconds: Random().nextInt(600)));

    // Add the "thinking" assistant message
    newItems.insert(
      0,
      ChattyItem.fromAssistant(''),
    ); // Empty assistant message is thinking

    emit(
      state.copyWith(
        busy: true,
        items: _getFullItems(newItems, withDateSeparator),
      ),
    );

    final response = await onPrompt(prompt, value: value);
    emit(
      state.copyWith(
        items: List.from(state.items)
          ..removeAt(0) // Remove the thinking assistant message first
          ..insert(0, response), // Then add the response assistant message
      ),
    );
  }
}
