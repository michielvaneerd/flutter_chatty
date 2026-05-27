import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chatty/src/chatty_animated_dots.dart';
import 'package:flutter_chatty/src/chatty_date_separator.dart';
import 'package:flutter_chatty/src/chatty_helpers.dart';
import 'package:flutter_chatty/src/chatty_item_widget.dart';
import 'package:flutter_chatty/src/chatty_widget_controller.dart';
import 'package:flutter_chatty/src/chatty_widget_style.dart';
import 'package:flutter_chatty/src/models.dart';

/// ChattyWidget is the main widget that contains the ChattyItemWidget items and the textfield for the prompt
class ChattyWidget extends StatefulWidget {
  const ChattyWidget({
    super.key,
    required this.onPrompt,
    this.initialItems,
    this.withDateSeparator = false,
    this.withDocuments = false,
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

  /// Optional initial ChattyItems, for example to display a first assistant message or the history of a conversation.
  final List<ChattyItem>? initialItems;

  /// Whether to display the date separator widget.
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
  var _busy = false;
  late final ChattyWidgetController _controller;

  @override
  void initState() {
    if (widget.controller == null) {
      _controller = ChattyWidgetController();
    } else {
      _controller = widget
          .controller!; // This one can have some initialItems and withDateSeparator
    }
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
      return _controller.items.value;
    }
    // Items has the most recent item at index 0
    // So instead of ADDING the date separator to the END of the list BEFORE the first message with a new date
    final List<ChattyItem> newItems = [];
    final Map<DateTime, bool> dates = {};
    for (final item in _controller.items.value.reversed) {
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
    List<ChattyItem> newItems = List<ChattyItem>.from(_controller.items.value);

    String? questionName;

    if (newItems.isNotEmpty && newItems.first.question != null) {
      // This is an answer to this question. We remove the question from this item,
      // so then it will be a normal assistant message without answering options anymore.
      questionName = newItems.first.question!.name;
      newItems[0] = newItems.first.copyWith(removeQuestion: true);
    }

    // Add the user answer to the items
    newItems.insert(0, ChattyItem.fromUser(prompt));
    _controller.items.value = newItems;

    await Future.delayed(Duration(milliseconds: Random().nextInt(1000)));

    // Add the "thinking" assistant message
    newItems.insert(
      0,
      ChattyItem.fromAssistant(''),
    ); // Empty assistant message is thinking
    _controller.items.value = List<ChattyItem>.from(newItems);

    setState(() {
      _busy = true;
    });

    final response = await widget.onPrompt(
      prompt,
      questionName: questionName,
      answerValue: answerValue,
    );

    _controller.items.value = List<ChattyItem>.from(
      newItems
        ..removeAt(0)
        ..insert(0, response),
    );

    setState(() {
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.themeData ?? Theme.of(context),
      child: ValueListenableBuilder(
        valueListenable: _controller.items,
        builder: (context, value, child) {
          final currentItemQuestionHasEmbeddedInput =
              _controller.items.value.isNotEmpty &&
              _controller.items.value.first.question != null &&
              ChattyItemWidget.hasEmbeddedInput(
                _controller.items.value.first.question!.type,
              );
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  reverse: true,
                  itemCount: _controller.items.value.length,
                  separatorBuilder: (context, index) {
                    return SizedBox(height: ChattyWidget.paddingDefault);
                  },
                  itemBuilder: (context, index) {
                    final item = _controller.items.value[index];
                    if (item.source == ChattyItemSource.dateSeparator) {
                      return ChattyDateSeparator(
                        date: item.createdAt,
                        style: widget.style,
                      );
                    } else {
                      return ChattyItemWidget(
                        item: item,
                        style: widget.style,
                        onPrompt: prompt,
                        documentsString: widget.documentsString,
                        enterDateString: widget.enterDateString,
                        assistantPersona: widget.assistantPersona,
                        onDocumentClicked: widget.onDocumentClicked,
                        withDocuments: widget.withDocuments,
                        extraWidget: index == 0 && _busy
                            ? ChattyAnimatedDots(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: ChattyWidget.paddingDefault),
              TextField(
                enabled: !currentItemQuestionHasEmbeddedInput,
                decoration: InputDecoration(
                  hintText: widget.promptPlaceHolder,
                  suffixIcon: IconButton(
                    onPressed: _busy || currentItemQuestionHasEmbeddedInput
                        ? null
                        : () {
                            prompt(promptController.text);
                            promptController.clear();
                          },
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: _busy || currentItemQuestionHasEmbeddedInput
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
