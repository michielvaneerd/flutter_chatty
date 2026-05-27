import 'package:flutter/material.dart';
import 'package:flutter_chatty/src/chatty_rich_text.dart';
import 'package:flutter_chatty/src/chatty_widget.dart';
import 'package:flutter_chatty/src/chatty_widget_style.dart';
import 'package:flutter_chatty/src/models.dart';
import 'package:intl/intl.dart';

class _BubbleTail extends StatelessWidget {
  const _BubbleTail({
    required this.color,
    required this.isAssistant,
    required this.borderColor,
    this.borderWidth,
  });
  final Color color;
  final Color borderColor;
  final bool isAssistant;
  final double? borderWidth;

  static const tailWidth = 8.0;
  static const tailHeight = 12.0;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(tailWidth, tailHeight),
      painter: _TailPainter(
        color: color,
        isAssistant: isAssistant,
        borderColor: borderColor,
        borderWidth: borderWidth,
      ),
    );
  }
}

class _TailPainter extends CustomPainter {
  const _TailPainter({
    required this.color,
    required this.isAssistant,
    required this.borderColor,
    this.borderWidth,
  });
  final Color color;
  final Color borderColor;
  final bool isAssistant;
  final double? borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // Fill
    final paint = Paint()..color = color;
    final path = Path();
    if (isAssistant) {
      path.moveTo(size.width, 0);
      path.lineTo(0, size.height); // tip at bottom-left
      path.lineTo(size.width, size.height); // horizontal bottom back to base
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, size.height); // tip at bottom-right
      path.lineTo(0, size.height); // horizontal bottom back to base
    }
    path.close();
    canvas.drawPath(path, paint);

    if (borderWidth != null) {
      // Border on diagonal and horizontal sides only
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth!;
      final borderPath = Path();
      if (isAssistant) {
        borderPath.moveTo(size.width, 0);
        borderPath.lineTo(0, size.height); // diagonal
        borderPath.lineTo(size.width, size.height); // horizontal
      } else {
        borderPath.moveTo(0, 0);
        borderPath.lineTo(size.width, size.height); // diagonal
        borderPath.lineTo(0, size.height); // horizontal
      }
      canvas.drawPath(borderPath, borderPaint);
    }
  }

  @override
  bool shouldRepaint(_TailPainter old) =>
      old.color != color || old.borderColor != borderColor;
}

class ChattyItemWidget extends StatelessWidget {
  const ChattyItemWidget({
    super.key,
    required this.item,
    required this.onPrompt,
    this.extraWidget,
    this.withDocuments = false,
    this.onDocumentClicked,
    this.assistantPersona,
    required this.documentsString,
    required this.enterDateString,
    this.style = const ChattyWidgetStyle(),
  });
  final ChattyItem item;
  final Widget? extraWidget;
  final bool withDocuments;
  final void Function(ChattyDocument)? onDocumentClicked;
  final Widget? assistantPersona;
  final String documentsString;
  final String enterDateString;
  final ChattyWidgetStyle style;
  final void Function(String prompt, {String? answerValue}) onPrompt;

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
                  onPrompt(
                    DateFormat.yMd().format(date),
                    answerValue: dateFormat.format(date),
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
                    onPrompt(e.content, answerValue: e.value);
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
    final isAssistant = item.source == ChattyItemSource.assistant;
    final padding = isAssistant ? style.assistantPadding : style.userPadding;
    final userColor =
        style.userColor ?? Theme.of(context).colorScheme.surfaceContainerLowest;
    final assistantColor =
        style.assistantColor ?? Theme.of(context).colorScheme.primaryContainer;
    final userBorderColor =
        style.userBorderColor ?? Theme.of(context).colorScheme.outlineVariant;
    final assistantBorderColor =
        style.assistantBorderColor ??
        Theme.of(context).colorScheme.outlineVariant;
    return Padding(
      padding: EdgeInsets.only(
        left: isAssistant ? 0 : ChattyWidget.paddingBig * 2,
        right: !isAssistant ? 0 : ChattyWidget.paddingBig * 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isAssistant && assistantPersona != null) assistantPersona!,
          Expanded(
            child: Stack(
              children: [
                Row(
                  children: [
                    SizedBox(width: _BubbleTail.tailWidth),
                    Expanded(
                      child: Container(
                        padding:
                            padding ??
                            EdgeInsets.only(
                              top: ChattyWidget.paddingDefault,
                              left: ChattyWidget.paddingDefault,
                              right: ChattyWidget.paddingDefault,
                              bottom: ChattyWidget.paddingSmall,
                            ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(
                              ChattyWidget.borderRadiusDefault,
                            ),
                            topLeft: Radius.circular(
                              ChattyWidget.borderRadiusDefault,
                            ),
                            bottomRight: isAssistant
                                ? Radius.circular(
                                    ChattyWidget.borderRadiusDefault,
                                  )
                                : Radius.zero,
                            bottomLeft: !isAssistant
                                ? Radius.circular(
                                    ChattyWidget.borderRadiusDefault,
                                  )
                                : Radius.zero,
                          ),
                          color: isAssistant ? assistantColor : userColor,
                          border: style.borderWidth != null
                              ? Border.all(
                                  width: style.borderWidth!,
                                  color: isAssistant
                                      ? assistantBorderColor
                                      : userBorderColor,
                                )
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              spacing: ChattyWidget.paddingDefault,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (mainText.isNotEmpty)
                                  ChattyRichText(
                                    text: mainText,
                                    textStyle: isAssistant
                                        ? style.assistantTextStyle
                                        : style.userTextStyle,
                                  ),
                                ?getAnswers(context),
                                ?extraWidget,
                                if (withDocuments &&
                                    item.documents != null &&
                                    item.documents!.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        documentsString,
                                        style:
                                            style.documentsStringStyle ??
                                            (style.assistantTextStyle ??
                                                    TextStyle())
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
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
                                            style:
                                                style.documentsLinkStyle ??
                                                (style.assistantTextStyle ??
                                                        TextStyle())
                                                    .copyWith(
                                                      decoration: TextDecoration
                                                          .underline,
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
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
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
                                style:
                                    style.timeStyle ??
                                    (style.assistantTextStyle ?? TextStyle())
                                        .copyWith(
                                          fontSize: Theme.of(
                                            context,
                                          ).textTheme.labelSmall!.fontSize,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: _BubbleTail.tailWidth),
                  ],
                ),
                if (isAssistant)
                  Positioned(
                    bottom: style.borderWidth != null
                        ? (style.borderWidth! / 2)
                        : 0,
                    left: style.borderWidth,
                    child: _BubbleTail(
                      color: assistantColor,
                      isAssistant: isAssistant,
                      borderColor: isAssistant
                          ? assistantBorderColor
                          : userBorderColor,
                      borderWidth: style.borderWidth,
                    ),
                  ),
                if (!isAssistant)
                  Positioned(
                    bottom: style.borderWidth != null
                        ? (style.borderWidth! / 2)
                        : 0,
                    right: style.borderWidth,
                    child: _BubbleTail(
                      color: userColor,
                      isAssistant: isAssistant,
                      borderColor: isAssistant
                          ? assistantBorderColor
                          : userBorderColor,
                      borderWidth: style.borderWidth,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
