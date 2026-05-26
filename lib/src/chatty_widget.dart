import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatty/src/chatty_animated_dots.dart';
import 'package:flutter_chatty/src/chatty_date_separator.dart';
import 'package:flutter_chatty/src/chatty_item_widget.dart';
import 'package:flutter_chatty/src/chatty_widget_cubit.dart';
import 'package:flutter_chatty/src/models.dart';

/// Class for all style related settings for the ChattyWidget and ChattyItemWidget items
class ChattyWidgetStyle {
  /// TestStyle for user prompts
  final TextStyle? userTextStyle;

  /// TextStyle for assistant reponses
  final TextStyle? assistantTextStyle;

  /// TextStyle for the documents title (only displayed if there are documents or sources)
  final TextStyle? documentsStringStyle;

  /// TextStyle for the document links (only displayed if there are documents or sources)
  final TextStyle? documentsLinkStyle;

  /// TextStyle for the time of the message
  final TextStyle? timeStyle;

  /// TextStyle for the date, displayed above the first message of a new date
  final TextStyle? dateStyle;

  /// BoxDecoration for the date, displayed above the first message of a new date
  final BoxDecoration? dateBoxDecoration;

  /// Padding for the date, displayed above the first message of a new date
  final EdgeInsets? datePadding;

  /// Color for the user prompts
  final Color? userColor;

  /// Color for the assistant responses
  final Color? assistantColor;

  /// Padding for the user prompts
  final EdgeInsets? userPadding;

  /// Padding for the assistant responses
  final EdgeInsets? assistantPadding;
  const ChattyWidgetStyle({
    this.userTextStyle,
    this.assistantTextStyle,
    this.documentsLinkStyle,
    this.documentsStringStyle,
    this.timeStyle,
    this.dateStyle,
    this.dateBoxDecoration,
    this.datePadding,
    this.userColor,
    this.assistantColor,
    this.userPadding,
    this.assistantPadding,
  });
}

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
  });

  static const paddingDefault = 12.0;
  static const paddingSmall = 6.0;
  static const paddingBig = 24.0;
  static const borderRadiusDefault = 18.0;

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
  final _listKey = GlobalKey<AnimatedListState>();
  late final ChattyWidgetCubit _cubit;
  int _previousItemCount = 0;

  @override
  void initState() {
    super.initState();
    _cubit = ChattyWidgetCubit(
      onPrompt: widget.onPrompt,
      initialItems: widget.initialItems,
      withDateSeparator: widget.withDateSeparator,
    );
    _previousItemCount = _cubit.state.items.length;
  }

  @override
  void dispose() {
    promptController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.themeData ?? Theme.of(context),
      child: BlocProvider<ChattyWidgetCubit>.value(
        value: _cubit,
        child: BlocConsumer<ChattyWidgetCubit, ChattyWidgetState>(
          listener: (context, state) {
            final diff = state.items.length - _previousItemCount;
            for (int i = 0; i < diff; i++) {
              _listKey.currentState?.insertItem(i);
            }
            _previousItemCount = state.items.length;
          },
          builder: (context, state) {
            final currentItemQuestionHasEmbeddedInput =
                state.items.isNotEmpty &&
                state.items.first.question != null &&
                ChattyItemWidget.hasEmbeddedInput(
                  state.items.first.question!.type,
                );
            return Column(
              children: [
                Expanded(
                  child: AnimatedList(
                    key: _listKey,
                    reverse: true,
                    initialItemCount: _previousItemCount,
                    itemBuilder: (context, index, animation) {
                      if (index >= state.items.length) {
                        return const SizedBox.shrink();
                      }
                      final item = state.items[index];
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
                          documentsString: widget.documentsString,
                          enterDateString: widget.enterDateString,
                          assistantPersona: widget.assistantPersona,
                          onDocumentClicked: widget.onDocumentClicked,
                          withDocuments: widget.withDocuments,
                          extraWidget: index == 0 && state.busy
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
                      onPressed:
                          state.busy || currentItemQuestionHasEmbeddedInput
                          ? null
                          : () {
                              _cubit.prompt(promptController.text);
                              promptController.clear();
                            },
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: state.busy || currentItemQuestionHasEmbeddedInput
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
      ),
    );
  }
}
