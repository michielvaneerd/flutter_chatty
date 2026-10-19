import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chatty/flutter_chatty.dart';
import 'package:flutter_chatty/src/chatty_item_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildQuestion(void Function(String, {String? answerValue}) onPrompt) {
    return MaterialApp(
      home: Scaffold(
        body: ChattyItemWidget(
          item: ChattyItem.fromAssistant(
            'Please log in',
            question: const ChattyQuestion(
              name: 'login',
              type: ChattyQuestionType.emailAndPassword,
            ),
          ),
          onPrompt: onPrompt,
          documentsString: 'Sources:',
          enterDateString: 'Enter date',
          okString: 'OK',
          emailString: 'Email',
          passwordString: 'Password',
          enterEmailString: 'Enter email',
          enterPasswordString: 'Enter password',
          enterEmailAndPasswordString: '',
        ),
      ),
    );
  }

  testWidgets(
    'Login validates and submits credentials separately from chat text',
    (tester) async {
      String? prompt;
      String? answer;
      await tester.pumpWidget(
        buildQuestion((value, {answerValue}) {
          prompt = value;
          answer = answerValue;
        }),
      );
      expect(
        ChattyItemWidget.hasEmbeddedInput(ChattyQuestionType.emailAndPassword),
        isTrue,
      );
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      expect(find.byType(AutofillGroup), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Login').last);
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
      expect(prompt, isNull);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.first, ' person@example.com ');
      await tester.enterText(fields.last, ' secret password ');
      expect(
        tester.widget<TextField>(find.byType(TextField).last).obscureText,
        isTrue,
      );
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField).last).obscureText,
        isFalse,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Login').last);
      await tester.pumpAndSettle();
      expect(prompt, 'person@example.com');
      expect(jsonDecode(answer!), {
        'email': 'person@example.com',
        'password': ' secret password ',
      });
      expect(find.byType(TextFormField), findsNothing);
    },
  );

  testWidgets('Closing Login does not submit an answer', (tester) async {
    var submitted = false;
    await tester.pumpWidget(
      buildQuestion((_, {answerValue}) {
        submitted = true;
      }),
    );
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(submitted, isFalse);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('Login'), findsOneWidget);
  });
}
