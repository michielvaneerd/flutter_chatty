import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chatty/flutter_chatty.dart';
import 'package:flutter_chatty/src/chatty_animated_dots.dart';
import 'package:flutter_chatty/src/chatty_date_separator.dart';
import 'package:flutter_chatty/src/chatty_helpers.dart';
import 'package:flutter_chatty/src/chatty_item_widget.dart';

/// ChattyWidget is the main widget that contains the ChattyItemWidget items and the textfield for the prompt
class ChattyWidget extends StatefulWidget {
  const ChattyWidget({
    super.key,
    required this.onPrompt,
    this.withDocuments = false,
    this.withDateSeparator = false,
    this.themeData,
    this.onDocumentClicked,
    this.promptPlaceHolder,
    this.assistantPersona,
    this.documentsString = 'Sources:',
    this.enterDateString = 'Enter date',
    this.style = const ChattyWidgetStyle(),
    this.controller,
  });

  static const paddingDefault = 12.0;
  static const paddingSmall = 6.0;
  static const paddingBig = 24.0;
  static const borderRadiusDefault = 18.0;

  final ChattyWidgetController? controller;

  /// Required callback that is called when the user enters a new prompt and optionaly a value of an answer.
  /// This is the place to send this prompt to the LLM and returns the response as a ChattyItem.
  final Future<ChattyItem> Function(
    String prompt, {
    String? questionName,
    String? answerValue,
  })
  onPrompt;

  final bool withDateSeparator;

  /// The style for this ChattyWidget and ChattyItemWidget items.
  final ChattyWidgetStyle style;

  /// Whether the documents that are attached to an assistant message should be displayed, for example for a RAG application.
  final bool withDocuments;

  /// Optional ThemeData to make the ChattyWidget blend into your ThemeData.
  final ThemeData? themeData;

  /// Callback that is called when a document is clicked
  final void Function(ChattyDocument)? onDocumentClicked;

  /// Text to display in the textfield as the prompt placeholder
  final String? promptPlaceHolder;

  /// The text for the 'Enter date' button
  final String enterDateString;

  /// The text for the 'Sources' text
  final String documentsString;

  /// Assistant persona icon
  final Widget? assistantPersona;

  @override
  State<ChattyWidget> createState() => _ChattyWidgetState();
}

class _ChattyWidgetState extends State<ChattyWidget> {
  final promptController = TextEditingController();
  final _listKey = GlobalKey<AnimatedListState>();
  var _previousItemCount = 0;
  late final ChattyWidgetController _controller;

  @override
  void initState() {
    if (widget.controller == null) {
      _controller = ChattyWidgetController();
    } else {
      _controller = widget
          .controller!; // This one can have some initialItems and withDateSeparator
    }
    _previousItemCount = getFullItems().length;
    super.initState();
  }

  @override
  void dispose() {
    promptController.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  List<ChattyItem> getFullItems() {
    if (!widget.withDateSeparator) {
      return _controller.notifier.chattyWidgetState.items.toList();
    }
    // Items has the most recent item at index 0
    // So instead of ADDING the date separator to the END of the list BEFORE the first message with a new date
    final List<ChattyItem> newItems = [];
    final Map<DateTime, bool> dates = {};
    for (final item in _controller.notifier.chattyWidgetState.items.reversed) {
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
  void prompt(String prompt, {String? answerValue}) async {
    // We mutate the items here. And the only reason this works in the ListenableBuilder,
    // is that the first thing we do is call getFullItems, which always returns a copy of the list!
    // If we didn't return a copy but the original list, we could get into trouble.

    _controller.notifier.update(
      ChattyWidgetState(
        items: _controller.notifier.chattyWidgetState.items,
        busy: true,
      ),
    );

    String? questionName;

    if (_controller.notifier.chattyWidgetState.items.isNotEmpty &&
        _controller.notifier.chattyWidgetState.items.first.question != null) {
      // This is an answer to this question. We remove the question from this item,
      // so then it will be a normal assistant message without answering options anymore.
      questionName =
          _controller.notifier.chattyWidgetState.items.first.question!.name;
      // Note: NO update(), so NO notifyListeners. But is not needed here, because below we do this already immediately after this.
      _controller.notifier.chattyWidgetState.items[0] = _controller
          .notifier
          .chattyWidgetState
          .items
          .first
          .copyWith(removeQuestion: true);
    }

    // Add the user answer to the items
    _controller.notifier.chattyWidgetState.items.insert(
      0,
      ChattyItem.fromUser(prompt),
    );
    _controller.notifier.update(_controller.notifier.chattyWidgetState);

    await Future.delayed(Duration(milliseconds: Random().nextInt(1000)));

    // Add the "thinking" assistant message
    _controller.notifier.chattyWidgetState.items.insert(
      0,
      ChattyItem.fromAssistant(''),
    ); // Empty assistant message is thinking
    _controller.notifier.update(_controller.notifier.chattyWidgetState);

    final response = await widget.onPrompt(
      prompt,
      questionName: questionName,
      answerValue: answerValue,
    );

    _controller.notifier.update(
      ChattyWidgetState(
        items: _controller.notifier.chattyWidgetState.items
          ..removeAt(0)
          ..insert(0, response),

        busy: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.themeData ?? Theme.of(context),
      child: ListenableBuilder(
        listenable: _controller.notifier,
        builder: (context, child) {
          final fullItems = getFullItems();
          final busy = _controller.notifier.chattyWidgetState.busy;
          final currentItemQuestionHasEmbeddedInput =
              fullItems.isNotEmpty &&
              fullItems.first.question != null &&
              ChattyItemWidget.hasEmbeddedInput(fullItems.first.question!.type);
          // Don't think this is ok...
          final diff = fullItems.length - _previousItemCount;
          for (int i = 0; i < diff; i++) {
            _listKey.currentState?.insertItem(i);
          }
          _previousItemCount = fullItems.length;
          return Column(
            children: [
              Expanded(
                child: AnimatedList(
                  key: _listKey,
                  reverse: true,
                  initialItemCount: _previousItemCount,
                  itemBuilder: (context, index, animation) {
                    if (index >= fullItems.length) {
                      return const SizedBox.shrink();
                    }

                    final item = fullItems[index];
                    final Widget child;
                    if (item.source == ChattyItemSource.dateSeparator) {
                      child = ChattyDateSeparator(
                        date: item.createdAt,
                        style: widget.style,
                      );
                    } else {
                      child = ChattyItemWidget(
                        item: item,
                        style: widget.style,
                        onPrompt: prompt,
                        documentsString: widget.documentsString,
                        enterDateString: widget.enterDateString,
                        assistantPersona: widget.assistantPersona,
                        onDocumentClicked: widget.onDocumentClicked,
                        withDocuments: widget.withDocuments,
                        extraWidget:
                            index == 0 &&
                                busy &&
                                item.source == ChattyItemSource.assistant &&
                                item.content.isEmpty
                            ? ChattyAnimatedDots(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(
                        top: ChattyWidget.paddingBig,
                      ),
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeIn,
                        ),
                        child: child,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: ChattyWidget.paddingDefault),
              TextField(
                enabled: !currentItemQuestionHasEmbeddedInput,
                decoration: InputDecoration(
                  hintText: widget.promptPlaceHolder,
                  suffixIcon: IconButton(
                    onPressed: busy || currentItemQuestionHasEmbeddedInput
                        ? null
                        : () {
                            prompt(promptController.text);
                            promptController.clear();
                          },
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: busy || currentItemQuestionHasEmbeddedInput
                          ? Theme.of(context).colorScheme.inversePrimary
                          : null,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ChattyWidget.borderRadiusDefault,
                    ),
                  ),
                ),
                controller: promptController,
              ),
            ],
          );
        },
      ),
    );
  }
}
