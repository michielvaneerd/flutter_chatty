import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chatty/flutter_chatty.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MaterialApp(home: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// The initialItems can be used for a first assistant message or the previous conversation
  final initialItems = [
    ChattyItem.fromAssistant(
      'I can show a demo of the Flutter Chatty library',
      createdAt: DateTime.now().subtract(Duration(minutes: 3)),
    ),
    ChattyItem.fromUser(
      'What can you do?',
      createdAt: DateTime.now().subtract(Duration(minutes: 4)),
    ),
    ChattyItem.fromAssistant(
      'Hi, I am the demo assistant. How can I help you?',
      createdAt: DateTime.now().subtract(Duration(minutes: 5)),
    ),
  ];

  var messageCounter = 0;
  final now = DateTime.now();

  /// The required callback that receives the user prompt and optionally the answers value.
  /// Here you should implemement your logic, like sending it to the LLM.
  /// The response of this action should be converted to a ChattyItem instance and returned back.
  /// This implementation displays different scenario's, like normale responses, handling questions and errors.
  Future<ChattyItem> onPrompt(
    String prompt, {
    String? questionName,
    String? answerValue,
  }) async {
    await Future.delayed(Duration(milliseconds: Random().nextInt(2000)));

    messageCounter += 1;

    if (questionName != null) {
      print(
        'Received answer for question $questionName: answer = $prompt and value = $answerValue',
      );
    }

    switch (messageCounter) {
      case 1:

        /// Question with input from the prompt textfield
        return ChattyItem.fromAssistant(
          'What\'s your name?',
          question: ChattyQuestion(name: 'name', type: ChattyQuestionType.text),
        );
      case 2:

        /// Question with input from a date picker. Textfield will be disabled.
        return ChattyItem.fromAssistant(
          'Nice to meat you $prompt! What is your birthdate?',
          question: ChattyQuestion(
            name: 'birthdate',
            type: ChattyQuestionType.date,
            min: DateFormat('y-MM-dd').format(DateTime(now.year - 100)),
          ),
        );
      case 3:

        /// Question with input from one of the possible single choice options. Textfield will be disabled.
        return ChattyItem.fromAssistant(
          'Yes or no?',
          question: ChattyQuestion(
            name: 'yes_no',
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
            name: 'yes_no',
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
          style: ChattyWidgetStyle(
            userColor: Colors.limeAccent,
            assistantTextStyle: Theme.of(context).textTheme.bodyLarge,
            userTextStyle: Theme.of(context).textTheme.bodyLarge,
            timeStyle: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: Colors.blue),
            dateStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Colors.yellow,
              fontWeight: FontWeight.bold,
            ),
            borderWidth: 1.0,
            datePadding: EdgeInsets.all(20),
            dateBoxDecoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(20),
              color: Colors.brown,
            ),
          ),
          // themeData: ThemeData(
          //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          // ),
          onPrompt: onPrompt,
          initialItems: initialItems,
          withDateSeparator: true,
          withDocuments: true,
          enterDateString: 'Enter the date!',
          documentsString: 'SOURCES:',
          assistantPersona: Icon(
            Icons.person_2,
            size: 32,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          onDocumentClicked: (doc) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: Text('You clicked on the link: ${doc.uri}'),
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
