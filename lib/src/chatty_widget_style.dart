import 'package:flutter/material.dart';

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

  final double? borderWidth;

  /// Padding for the assistant responses
  final EdgeInsets? assistantPadding;
  const ChattyWidgetStyle({
    this.userTextStyle,
    this.assistantTextStyle,
    this.documentsLinkStyle,
    this.documentsStringStyle,
    this.timeStyle,
    this.borderWidth,
    this.dateStyle,
    this.dateBoxDecoration,
    this.datePadding,
    this.userColor,
    this.assistantColor,
    this.userPadding,
    this.assistantPadding,
  });
}
