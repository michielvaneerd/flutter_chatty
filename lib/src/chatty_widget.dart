import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatty/src/chatty_animated_dots.dart';
import 'package:flutter_chatty/src/chatty_date_separator.dart';
import 'package:flutter_chatty/src/chatty_item_widget.dart';
import 'package:flutter_chatty/src/chatty_widget_cubit.dart';
import 'package:flutter_chatty/src/models.dart';

/// ChattyWidget is the main widget that contains the chat items and the textfield for the prompt.
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
  });

  static const paddingDefault = 12.0;
  static const paddingSmall = 6.0;
  static const paddingBig = 24.0;
  static const borderRadiusDefault = 18.0;

  /// Handle new user prompt: send this prompt to the LLM api and
  /// return the response as a ChattyItem - this is up to the caller.
  final Future<ChattyItem> Function(String prompt, {String? value}) onPrompt;
  final List<ChattyItem>? initialItems;
  final bool withDateSeparator;

  /// Whether the documents that are attached to an assistant message should be displayed, for example for a RAG application.
  final bool withDocuments;
  final ThemeData? themeData;

  /// Action that should be done when a document is clicked
  final void Function(ChattyDocument)? onDocumentClicked;
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

  @override
  void dispose() {
    promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.themeData ?? Theme.of(context),
      child: BlocProvider<ChattyWidgetCubit>(
        create: (context) => ChattyWidgetCubit(
          onPrompt: widget.onPrompt,
          initialItems: widget.initialItems,
          withDateSeparator: widget.withDateSeparator,
        ),
        child: BlocConsumer<ChattyWidgetCubit, ChattyWidgetState>(
          listener: (context, state) {
            // TODO
          },
          builder: (context, state) {
            final cubit = BlocProvider.of<ChattyWidgetCubit>(context);
            final currentItemQuestionHasEmbeddedInput =
                state.items.isNotEmpty &&
                state.items.first.question != null &&
                ChattyItemWidget.hasEmbeddedInput(
                  state.items.first.question!.type,
                );
            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    reverse: true,
                    itemCount: state.items.length,
                    separatorBuilder: (context, index) {
                      return SizedBox(height: ChattyWidget.paddingBig);
                    },
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      if (item.source == ChattyItemSource.dateSeparator) {
                        return ChattyDateSeparator(date: item.createdAt);
                      } else {
                        return ChattyItemWidget(
                          item: item,
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
                              cubit.prompt(promptController.text);
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
