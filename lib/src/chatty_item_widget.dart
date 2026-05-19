import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatty/src/chatty_rich_text.dart';
import 'package:flutter_chatty/src/chatty_widget.dart';
import 'package:flutter_chatty/src/chatty_widget_cubit.dart';
import 'package:flutter_chatty/src/models.dart';
import 'package:intl/intl.dart';

class ChattyItemWidget extends StatelessWidget {
  const ChattyItemWidget({
    super.key,
    required this.item,
    this.extraWidget,
    this.withDocuments = false,
    this.onDocumentClicked,
    this.assistantPersona,
    required this.documentsString,
    required this.enterDateString,
  });
  final ChattyItem item;
  final Widget? extraWidget;
  final bool withDocuments;
  final void Function(ChattyDocument)? onDocumentClicked;
  final Widget? assistantPersona;
  final String documentsString;
  final String enterDateString;

  static final dateFormat = DateFormat('y-MM-dd');

  static const _embeddedInputQuestionTypes = [
    ChattyQuestionType.date,
    ChattyQuestionType.singleChoice,
  ];

  static bool hasEmbeddedInput(ChattyQuestionType type) {
    return _embeddedInputQuestionTypes.contains(type);
  }

  Column? getAnswers(BuildContext context) {
    if (item.question == null) {
      return null;
    }
    switch (item.question!.type) {
      case ChattyQuestionType.date:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilledButton(
              onPressed: () async {
                final minDate = item.question?.min != null
                    ? dateFormat.parse(item.question!.min!)
                    : DateTime.now();
                final maxDate = item.question?.max != null
                    ? dateFormat.parse(item.question!.max!)
                    : DateTime.now();

                final date = await showDatePicker(
                  context: context,
                  firstDate: minDate,
                  lastDate: maxDate,
                );

                if (date != null && context.mounted) {
                  BlocProvider.of<ChattyWidgetCubit>(context).prompt(
                    DateFormat.yMd().format(date),
                    value: dateFormat.format(date),
                  );
                }
              },
              child: Text(enterDateString),
            ),
          ],
        );
      case ChattyQuestionType.singleChoice:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: item.question!.answers!
              .map(
                (e) => FilledButton(
                  onPressed: () {
                    BlocProvider.of<ChattyWidgetCubit>(
                      context,
                    ).prompt(e.content, value: e.value);
                  },
                  child: Text(e.content),
                ),
              )
              .toList(),
        );

      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainText = item.content;
    return Padding(
      padding: EdgeInsets.only(
        left: item.source == ChattyItemSource.assistant
            ? 0
            : ChattyWidget.paddingBig * 2,
        right: item.source == ChattyItemSource.user
            ? 0
            : ChattyWidget.paddingBig * 2,
      ),
      child: Row(
        spacing: ChattyWidget.paddingSmall,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (item.source == ChattyItemSource.assistant &&
              assistantPersona != null)
            assistantPersona!,
          Expanded(
            child: Container(
              padding: EdgeInsets.only(
                top: ChattyWidget.paddingDefault,
                left: ChattyWidget.paddingDefault,
                right: ChattyWidget.paddingDefault,
                bottom: ChattyWidget.paddingSmall,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(ChattyWidget.borderRadiusDefault),
                  topLeft: Radius.circular(ChattyWidget.borderRadiusDefault),
                  bottomRight: item.source == ChattyItemSource.assistant
                      ? Radius.circular(ChattyWidget.borderRadiusDefault)
                      : Radius.zero,
                  bottomLeft: item.source == ChattyItemSource.user
                      ? Radius.circular(ChattyWidget.borderRadiusDefault)
                      : Radius.zero,
                ),
                color: item.source == ChattyItemSource.assistant
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerLowest,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    spacing: ChattyWidget.paddingDefault,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (mainText.isNotEmpty) ChattyRichText(text: mainText),
                      ?getAnswers(context),
                      ?extraWidget,
                      if (withDocuments &&
                          item.documents != null &&
                          item.documents!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              documentsString,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...item.documents!.map(
                              (e) => InkWell(
                                onTap: onDocumentClicked != null
                                    ? () {
                                        onDocumentClicked!(e);
                                      }
                                    : null,
                                child: Text(
                                  e.title,
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (item.error != null)
                        Row(
                          spacing: ChattyWidget.paddingDefault,
                          children: [
                            Icon(
                              Icons.warning,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            Flexible(
                              child: Text(
                                item.error!,
                                //style: TextStyle(color: )
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  Align(
                    alignment: AlignmentGeometry.bottomEnd,
                    child: Text(
                      DateFormat.Hm().format(item.createdAt),
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
