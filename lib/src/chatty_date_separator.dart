import 'package:flutter/material.dart';
import 'package:flutter_chatty/src/chatty_widget.dart';
import 'package:intl/intl.dart';

class ChattyDateSeparator extends StatelessWidget {
  const ChattyDateSeparator({
    super.key,
    required this.date,
    this.style = const ChattyWidgetStyle(),
  });
  final DateTime date;
  final ChattyWidgetStyle style;

  static final dateFormat = DateFormat.yMd();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding:
              style.datePadding ?? EdgeInsets.all(ChattyWidget.paddingSmall),
          decoration:
              style.dateBoxDecoration ??
              BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(
                  ChattyWidget.borderRadiusDefault,
                ),
              ),
          child: Text(
            dateFormat.format(date),
            style:
                style.dateStyle ??
                Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
          ),
        ),
      ],
    );
  }
}
