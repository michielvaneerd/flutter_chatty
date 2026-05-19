import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chatty/flutter_chatty.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MaterialApp(home: const MyApp()));
}

/// The initialItems can be used for a first assistant message or the previous conversation
final initialItems = [
  ChattyItem.fromAssistant('Hi, I am the demo assistant. How can I help you?'),
];

var messageCounter = 0;
final now = DateTime.now();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// The required callback that receives the user prompt and optionally the answers value.
  /// Here you should implemement your logic, like sending it to the LLM.
  /// The response of this action should be converted to a ChattyItem instance and returned back.
  /// This implementation displays different scenario's, like normale responses, handling questions and errors.
  Future<ChattyItem> onPrompt(String prompt, {String? value}) async {
    await Future.delayed(Duration(milliseconds: Random().nextInt(2000)));

    messageCounter += 1;

    switch (messageCounter) {
      case 1:

        /// Question with input from the prompt textfield
        return ChattyItem.fromAssistant(
          'What\'s your name?',
          question: ChattyQuestion(type: ChattyQuestionType.text),
        );
      case 2:

        /// Question with input from a date picker. Textfield will be disabled.
        return ChattyItem.fromAssistant(
          'Nice to meat you $prompt! What is your birthdate?',
          question: ChattyQuestion(
            type: ChattyQuestionType.date,
            min: DateFormat('y-MM-dd').format(DateTime(now.year - 100)),
          ),
        );
      case 3:

        /// Question with input from one of the possible single choice options. Textfield will be disabled.
        return ChattyItem.fromAssistant(
          'Yes or no?',
          question: ChattyQuestion(
            type: ChattyQuestionType.singleChoice,
            answers: [
              ChattyAnswer(value: 'yes', content: 'Yes'),
              ChattyAnswer(value: 'no', content: 'No'),
            ],
          ),
        );
      case 4:

        /// The user gave a wrong answer: display question again with the error.
        return ChattyItem.fromAssistant(
          'Yes or no?',
          error: 'Sorry, $prompt is a wrong :-(',
          question: ChattyQuestion(
            type: ChattyQuestionType.singleChoice,
            answers: [
              ChattyAnswer(value: 'yes', content: 'Yes'),
              ChattyAnswer(value: 'no', content: 'No'),
            ],
          ),
        );
      case 5:

        /// Display some documents. Can be used for example in a RAG application to display the sources.
        return ChattyItem.fromAssistant(
          'Thank you, now it\'s the correct answer. I can also display a list of documents, for example in a RAG application.',
          documents: [
            ChattyDocument(
              uri: 'https://docs.flutter.dev',
              type: ChattyDocumentType.url,
              title: 'Flutter website',
            ),
          ],
        );
      case 6:

        /// Normal response.
        return ChattyItem.fromAssistant(
          'This was a small demo of what is possible.',
        );
      default:
        return ChattyItem.fromAssistant('I have nothing more to say...');
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Example')),
      body: SafeArea(
        minimum: EdgeInsets.all(12),
        child: ChattyWidget(
          onPrompt: onPrompt,
          initialItems: initialItems,
          withDateSeparator: true,
          withDocuments: true,
          onDocumentClicked: (p0) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: Text('You clicked on the link: $p0'),
                actions: [
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
