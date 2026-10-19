import 'dart:convert';

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
      final borderEraserPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth!;
      final borderEraserPath = Path();
      if (isAssistant) {
        borderPath.moveTo(size.width, 0);
        borderPath.lineTo(0, size.height); // diagonal
        borderPath.lineTo(size.width, size.height); // horizontal
        borderEraserPath.moveTo(size.width + (borderWidth! / 2), 0);
        borderEraserPath.lineTo(
          size.width + (borderWidth! / 2),
          size.height - borderWidth!,
        );
      } else {
        borderPath.moveTo(0, 0);
        borderPath.lineTo(size.width, size.height); // diagonal
        borderPath.lineTo(0, size.height); // horizontal
        borderEraserPath.moveTo(0 - (borderWidth! / 2), 0);
        borderEraserPath.lineTo(
          0 - (borderWidth! / 2),
          size.height - borderWidth!,
        );
      }
      canvas.drawPath(borderPath, borderPaint);
      canvas.drawPath(borderEraserPath, borderEraserPaint);
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
    required this.enterEmailAndPasswordString,
    required this.okString,
    required this.emailString,
    required this.passwordString,
    required this.enterEmailString,
    required this.enterPasswordString,
    this.onLongPress,
    this.onTap,
    this.style = const ChattyWidgetStyle(),
  });
  final ChattyItem item;
  final Widget? extraWidget;
  final bool withDocuments;
  final void Function(ChattyDocument)? onDocumentClicked;
  final Widget? assistantPersona;
  final String documentsString;
  final String enterDateString;
  final String enterEmailAndPasswordString;
  final String enterEmailString;
  final String enterPasswordString;
  final String okString;
  final String emailString;
  final String passwordString;
  final ChattyWidgetStyle style;
  final void Function(String prompt, {String? answerValue}) onPrompt;
  final void Function(ChattyItem item)? onLongPress;
  final void Function(ChattyItem item)? onTap;

  static final dateFormat = DateFormat('y-MM-dd');

  static const _embeddedInputQuestionTypes = [
    ChattyQuestionType.date,
    ChattyQuestionType.singleChoice,
    ChattyQuestionType.emailAndPassword,
    ChattyQuestionType.email,
    ChattyQuestionType.password,
  ];

  static bool hasEmbeddedInput(ChattyQuestionType type) {
    return _embeddedInputQuestionTypes.contains(type);
  }

  Column? getAnswers(BuildContext context) {
    if (item.question == null) {
      return null;
    }
    switch (item.question!.type) {
      case ChattyQuestionType.password:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilledButton(
              style: style.answerButtonStyle,
              onLongPress:
                  () {}, // Disables the longPress to bubble up to the parent
              onPressed: () async {
                final credentials =
                    await showModalBottomSheet<
                      ({String email, String password})
                    >(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (context) => _EmailAndPasswordInput(
                        enterEmailString: enterEmailString,
                        enterPasswordString: enterPasswordString,
                        chattyQuestionType: item.question!.type,
                        emailString: emailString,
                        passwordString: passwordString,
                        okString: okString,
                      ),
                    );
                if (credentials != null && context.mounted) {
                  onPrompt(
                    credentials.password,
                    answerValue: credentials.password,
                  );
                }
              },
              child: Text(enterPasswordString),
            ),
          ],
        );
      case ChattyQuestionType.email:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilledButton(
              style: style.answerButtonStyle,
              onLongPress:
                  () {}, // Disables the longPress to bubble up to the parent
              onPressed: () async {
                final credentials =
                    await showModalBottomSheet<
                      ({String email, String password})
                    >(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (context) => _EmailAndPasswordInput(
                        chattyQuestionType: item.question!.type,
                        enterEmailString: enterEmailString,
                        enterPasswordString: enterPasswordString,
                        emailString: emailString,
                        passwordString: passwordString,
                        okString: okString,
                      ),
                    );
                if (credentials != null && context.mounted) {
                  onPrompt(credentials.email, answerValue: credentials.email);
                }
              },
              child: Text(enterEmailString),
            ),
          ],
        );
      case ChattyQuestionType.emailAndPassword:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilledButton(
              style: style.answerButtonStyle,
              onLongPress:
                  () {}, // Disables the longPress to bubble up to the parent
              onPressed: () async {
                final credentials =
                    await showModalBottomSheet<
                      ({String email, String password})
                    >(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (context) => _EmailAndPasswordInput(
                        chattyQuestionType: item.question!.type,
                        enterEmailString: enterEmailString,
                        enterPasswordString: enterPasswordString,
                        emailString: emailString,
                        passwordString: passwordString,
                        okString: okString,
                      ),
                    );
                if (credentials != null && context.mounted) {
                  onPrompt(
                    credentials.email,
                    answerValue: jsonEncode({
                      'email': credentials.email,
                      'password': credentials.password,
                    }),
                  );
                }
              },
              child: Text(enterEmailAndPasswordString),
            ),
          ],
        );
      case ChattyQuestionType.date:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilledButton(
              style: style.answerButtonStyle,
              onLongPress:
                  () {}, // Disables the longPress to bubble up to the parent
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
                  style: style.answerButtonStyle,
                  onLongPress:
                      () {}, // Disables the longPress to bubble up to the parent
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
    final mainText = item.obscureContent
        ? ('*' * item.content.length)
        : item.content;
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
                      child: GestureDetector(
                        onLongPress: onLongPress != null
                            ? () {
                                onLongPress!(item);
                              }
                            : null,
                        onTap: onTap != null
                            ? () {
                                onTap!(item);
                              }
                            : null,
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
                                                        decoration:
                                                            TextDecoration
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

class _EmailAndPasswordInput extends StatefulWidget {
  const _EmailAndPasswordInput({
    required this.emailString,
    required this.enterEmailString,
    required this.enterPasswordString,
    required this.okString,
    required this.passwordString,
    required this.chattyQuestionType,
  });

  final String okString;
  final String emailString;
  final String passwordString;
  final String enterEmailString;
  final String enterPasswordString;
  final ChattyQuestionType chattyQuestionType;

  @override
  State<_EmailAndPasswordInput> createState() => _EmailAndPasswordInputState();
}

class _EmailAndPasswordInputState extends State<_EmailAndPasswordInput> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  bool hasEmail() {
    return widget.chattyQuestionType == ChattyQuestionType.email ||
        widget.chattyQuestionType == ChattyQuestionType.emailAndPassword;
  }

  bool hasPassword() {
    return widget.chattyQuestionType == ChattyQuestionType.password ||
        widget.chattyQuestionType == ChattyQuestionType.emailAndPassword;
  }

  void _submit() {
    if (_submitted || !_formKey.currentState!.validate()) {
      return;
    }
    _submitted = true;
    Navigator.of(context).pop((
      email: hasEmail() ? _emailController.text.trim() : '',
      password: hasPassword() ? _passwordController.text : '',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(ChattyWidget.paddingBig),
        child: AutofillGroup(
          onDisposeAction: AutofillContextAction.cancel,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: ChattyWidget.paddingDefault,
              children: [
                if (hasEmail())
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [
                      AutofillHints.username,
                      AutofillHints.email,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return widget.enterEmailString;
                      } else {
                        return null;
                      }
                    },
                    textInputAction: hasPassword()
                        ? TextInputAction.next
                        : TextInputAction.done,
                    decoration: InputDecoration(labelText: widget.emailString),
                    onFieldSubmitted: (_) => hasPassword()
                        ? _passwordFocusNode.requestFocus()
                        : _submit(),
                  ),
                if (hasPassword())
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    obscureText: _obscurePassword,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return widget.enterPasswordString;
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      labelText: widget.passwordString,
                      suffixIcon: IconButton(
                        onPressed: () => setState(() {
                          _obscurePassword = !_obscurePassword;
                        }),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                    onFieldSubmitted: (_) => _submit(),
                  ),
                FilledButton(onPressed: _submit, child: Text(widget.okString)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
