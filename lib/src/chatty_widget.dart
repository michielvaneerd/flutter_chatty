import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chatty/flutter_chatty.dart';
import 'package:flutter_chatty/src/chatty_animated_dots_2.dart';
import 'package:flutter_chatty/src/chatty_date_separator.dart';
import 'package:flutter_chatty/src/chatty_item_widget.dart';

/// ChattyWidget is the main widget that contains the ChattyItemWidget items and the textfield for the prompt
class ChattyWidget extends StatefulWidget {
  const ChattyWidget({
    super.key,
    required this.onPrompt,
    this.withDocuments = false,
    this.themeData,
    this.onDocumentClicked,
    this.promptPlaceHolder,
    this.assistantPersona,
    this.promptTextFieldDisabled = false,
    this.documentsString = 'Sources:',
    this.enterDateString = 'Enter date',
    this.style = const ChattyWidgetStyle(),
    this.controller,
    this.onItemExtraWidget,
    this.animationTransition,
    this.onItemLongPress,
    this.onItemTap,
  });

  static const paddingDefault = 12.0;
  static const paddingSmall = 6.0;
  static const paddingBig = 24.0;
  static const borderRadiusDefault = 18.0;

  /// Optional custom transition for animated lists. Make sure to return a transition instance with the item as the child
  final Widget Function(Widget item, Animation<double> animation)?
  animationTransition;

  /// Controls the chat items
  final ChattyWidgetController? controller;

  /// Callback that is called for each chat item and can be used to return a custom extra widget to display.
  final Widget? Function(ChattyItem item)? onItemExtraWidget;

  /// Required callback that is called when the user enters a new prompt and optionaly a value of an answer.
  /// This is the place to send this prompt to the LLM and returns the response as a ChattyItem.
  final Future<ChattyItem> Function(
    String prompt, {
    String? questionName,
    String? answerValue,
  })
  onPrompt;

  /// Whether the textfield should be disabled.
  final bool promptTextFieldDisabled;

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

  final void Function(ChattyItem item)? onItemLongPress;
  final void Function(ChattyItem item)? onItemTap;

  @override
  State<ChattyWidget> createState() => _ChattyWidgetState();
}

class _ChattyWidgetState extends State<ChattyWidget> {
  final promptController = TextEditingController();

  // A ChattyWidgetController can be given by the caller or else it will be created here
  late final ChattyWidgetController _controller;

  @override
  void initState() {
    if (widget.controller == null) {
      _controller = ChattyWidgetController();
    } else {
      _controller = widget.controller!;
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

  /// Handle new user prompt
  void prompt(String prompt, {String? answerValue}) async {
    _controller.setBusy(true);

    ChattyQuestion? question;
    ChattyAnswer? answer;

    var items = _controller.getItems();

    if (items.isNotEmpty && items.first.question != null) {
      // This is an answer to this question. We remove the question from this item,
      // so then it will be a normal assistant message without answering options anymore.
      question = items.first.question!;
      _controller.replaceAt(
        0,
        items.first.copyWith(removeQuestion: true),
        withNotify: false,
      );
      if (question.answers != null) {
        try {
          answer = question.answers?.firstWhere((e) => e.value == answerValue);
        } catch (ex) {
          // Nothing to do.
        }
      }
    }

    // Add the user answer to the items
    _controller.add(ChattyItem.fromUser(prompt));

    // Add some random delay between adding the user prompt and the assistant "thinking" bubble,
    // that way it looks more natural and we can first see the user prompt appear and then the assistant "thinking" bubble.
    await Future.delayed(Duration(milliseconds: Random().nextInt(1000) + 300));

    if (answer?.actionBefore != null) {
      await answer!.actionBefore!();
    }

    _controller.add(ChattyItem.fromAssistant(''));

    // await Future.delayed(Duration(seconds: 2));

    final response = await widget.onPrompt(
      prompt,
      questionName: question?.name,
      answerValue: answerValue,
    );

    _controller.setBusy(false, withNotify: false);
    _controller.replaceAt(0, response);

    if (answer?.actionAfter != null) {
      await answer!.actionAfter!();
    }
  }

  Widget _getListViewChild({
    required BuildContext context,
    required int index,
    required List<ChattyItem> fullItems,
    required bool busy,
  }) {
    final item = fullItems[index];
    if (item.source == ChattyItemSource.dateSeparator) {
      return ChattyDateSeparator(date: item.createdAt, style: widget.style);
    } else {
      final extraWidget = widget.onItemExtraWidget != null
          ? widget.onItemExtraWidget!(item)
          : null;
      return ChattyItemWidget(
        item: item,
        style: widget.style,
        onPrompt: prompt,
        documentsString: widget.documentsString,
        enterDateString: widget.enterDateString,
        assistantPersona: widget.assistantPersona,
        onDocumentClicked: widget.onDocumentClicked,
        withDocuments: widget.withDocuments,
        onLongPress: widget.onItemLongPress,
        onTap: widget.onItemTap,
        extraWidget:
            index == 0 &&
                busy &&
                item.source == ChattyItemSource.assistant &&
                item.content.isEmpty
            ? ChattyAnimatedDots2(style: widget.style)
            : extraWidget,
      );
    }
  }

  Widget _getListView(List<ChattyItem> fullItems, bool busy) {
    if (_controller.animated) {
      return AnimatedList.separated(
        reverse: true,
        key: _controller.getAnimatedListKey(),
        initialItemCount: _controller.getInitialItemCount(),
        itemBuilder: (context, index, animation) {
          final child = _getListViewChild(
            context: context,
            index: index,
            fullItems: fullItems,
            busy: busy,
          );
          return widget.animationTransition != null
              ? widget.animationTransition!(child, animation)
              : FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeIn,
                  ),
                  //turns: CurvedAnimation(parent: animation, curve: Curves.easeIn),
                  //scale: CurvedAnimation(parent: animation, curve: Curves.easeIn),
                  child: child,
                );
        },
        separatorBuilder: (context, index, animation) =>
            SizedBox(height: ChattyWidget.paddingDefault),
        removedSeparatorBuilder: (context, index, animation) =>
            SizedBox(height: ChattyWidget.paddingDefault),
      );
    } else {
      return ListView.separated(
        reverse: true,
        itemBuilder: (context, index) {
          return _getListViewChild(
            context: context,
            index: index,
            fullItems: fullItems,
            busy: busy,
          );
        },
        separatorBuilder: (context, index) =>
            SizedBox(height: ChattyWidget.paddingDefault),
        itemCount: fullItems.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.themeData ?? Theme.of(context),
      child: ListenableBuilder(
        listenable: _controller.getNotifier(),
        builder: (context, child) {
          final fullItems = _controller.getItems();
          final busy = _controller.getBusy();
          final currentItemQuestionHasEmbeddedInput =
              fullItems.isNotEmpty &&
              fullItems.first.question != null &&
              ChattyItemWidget.hasEmbeddedInput(fullItems.first.question!.type);
          return Column(
            children: [
              Expanded(child: _getListView(fullItems, busy)),
              SizedBox(height: ChattyWidget.paddingDefault),
              TextField(
                enabled: !currentItemQuestionHasEmbeddedInput,
                decoration: InputDecoration(
                  hintText: widget.promptPlaceHolder,
                  suffixIcon: IconButton(
                    onPressed:
                        busy ||
                            currentItemQuestionHasEmbeddedInput ||
                            widget.promptTextFieldDisabled
                        ? null
                        : () {
                            if (promptController.text.isNotEmpty) {
                              prompt(promptController.text);
                              promptController.clear();
                            }
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
