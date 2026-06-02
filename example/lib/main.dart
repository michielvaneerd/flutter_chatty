import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chatty/flutter_chatty.dart';
import 'package:intl/intl.dart';

/// Some predefined styles
enum ChattyWidgetStyles { empty, playfully, business }

/// Some predefined animations
enum ChattyWidgetAnimations { fade, scale, rotate }

/// Object that is returned from the MyStyleScreen
class ConfigScreenObject {
  ChattyWidgetStyles styles;
  bool animated;
  bool withDateSeparator;
  ChattyWidgetAnimations animation;
  ConfigScreenObject({
    required this.animated,
    required this.styles,
    required this.withDateSeparator,
    required this.animation,
  });
}

void main() {
  runApp(MaterialApp(home: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Item that will receive an extra widget in the onItemExtraWidget callback of the ChattyWidget
  final itemWithExtraWidget = ChattyItem.fromAssistant(
    'I can show a demo of the Flutter Chatty library.\n\nThis message has a custom extra Widget in it.',
    createdAt: DateTime.now().subtract(Duration(minutes: 3)),
  );

  /// The initialItems can be used for a first assistant message or the previous conversation
  late final List<ChattyItem> initialItems;

  /// Return a transition based in the current ChattyWidgetAnimations value
  Widget getAnimationByAnimation(Widget child, Animation<double> animation) {
    switch (_animation) {
      case ChattyWidgetAnimations.fade:
        return FadeTransition(opacity: animation, child: child);
      case ChattyWidgetAnimations.scale:
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeIn),
          child: child,
        );
      case ChattyWidgetAnimations.rotate:
        return RotationTransition(turns: animation, child: child);
    }
  }

  /// Return a ChattyWidgetStyle based on the current ChattyWidgetStyles value
  ChattyWidgetStyle getStyleByStyles() {
    switch (_style) {
      case ChattyWidgetStyles.empty:
        return ChattyWidgetStyle();
      case ChattyWidgetStyles.playfully:
        return ChattyWidgetStyle(
          userColor: Colors.amber,
          assistantColor: Colors.deepOrangeAccent,
          userBorderColor: Colors.blueGrey,
          assistantBorderColor: Colors.purple,
          assistantTextStyle: Theme.of(context).textTheme.bodyLarge,
          userTextStyle: Theme.of(context).textTheme.bodyLarge,
          timeStyle: Theme.of(
            context,
          ).textTheme.bodySmall!.copyWith(color: Colors.brown),
          dateStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          borderWidth: 4.0,
          datePadding: EdgeInsets.all(2),
          dateBoxDecoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(2),
            color: Colors.pink,
          ),
        );
      case ChattyWidgetStyles.business:
        return ChattyWidgetStyle(
          userColor: Colors.white,
          assistantColor: Colors.grey.shade100,
          userBorderColor: Colors.black,
          assistantBorderColor: Colors.black,
          assistantTextStyle: Theme.of(context).textTheme.bodyLarge,
          userTextStyle: Theme.of(context).textTheme.bodyLarge,
          timeStyle: Theme.of(
            context,
          ).textTheme.bodySmall!.copyWith(color: Colors.blue),
          // dateStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
          //   color: Colors.yellow,
          //   fontWeight: FontWeight.bold,
          // ),
          borderWidth: 1.0,
          //datePadding: EdgeInsets.all(10),
          // dateBoxDecoration: BoxDecoration(
          //   border: Border.all(color: Colors.black),
          //   borderRadius: BorderRadius.circular(20),
          //   color: Colors.brown,
          // ),
        );
    }
  }

  final controller = ChattyWidgetController();

  // State for the widget
  var _withDateSeparator = ChattyWidgetController.defaultWithDateSeparator;
  var _animated = ChattyWidgetController.defaultAnimated;
  var _animation = ChattyWidgetAnimations.fade;
  var _style = ChattyWidgetStyles.empty;

  // Some variables needed for this demo
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
      debugPrint(
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
              ChattyAnswer(
                value: 'yes',
                content: 'Yes',
                actionBefore: () async {
                  // An action for this answer. Can be used to do something like opening another screen.
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Text('This is an action from the YES answer'),
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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initialItems = [
      itemWithExtraWidget,
      ChattyItem.fromUser(
        'What can you do?',
        createdAt: DateTime.now().subtract(Duration(minutes: 4)),
      ),
      ChattyItem.fromAssistant(
        'Hi, I am the demo assistant. How can I help you?',
        createdAt: DateTime.now().subtract(Duration(minutes: 5)),
      ),
    ];
    init();
  }

  void init() async {
    // Imitate an asynchronous update of the controller.
    controller.clear(
      initialItems: initialItems,
      withDateSeparator: _withDateSeparator,
      animated: _animated,
      withNotify: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example'),
        actions: [
          // Clear all items
          IconButton(
            onPressed: () async {
              showDialog<bool?>(
                context: context,
                builder: (context) => AlertDialog(
                  content: Text(
                    'Are you sure you want to remove all messages?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                    FilledButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.error,
                        ),
                      ),
                      onPressed: () {
                        controller.clear();
                        Navigator.of(context).pop();
                      },
                      child: Text('Remove all items!'),
                    ),
                  ],
                ),
              );
            },
            icon: Icon(Icons.delete),
          ),
          // Make configuration or style changes
          IconButton(
            onPressed: () async {
              final newConfigScreenObject = await Navigator.of(context)
                  .push<ConfigScreenObject?>(
                    MaterialPageRoute(
                      builder: (context) => MyStyleScreen(
                        styles: _style,
                        animated: _animated,
                        withDateSeparator: _withDateSeparator,
                        animation: _animation,
                      ),
                    ),
                  );
              if (newConfigScreenObject != null) {
                final hasConfigChange =
                    _withDateSeparator !=
                        newConfigScreenObject.withDateSeparator ||
                    _animated != newConfigScreenObject.animated;
                setState(() {
                  _style = newConfigScreenObject.styles;
                  _animated = newConfigScreenObject.animated;
                  _withDateSeparator = newConfigScreenObject.withDateSeparator;
                  _animation = newConfigScreenObject.animation;
                });
                // Note that when the config changes, you MUST call controller.clear, otherwise the item count is not correct anymore
                if (hasConfigChange) {
                  controller.clear(
                    withDateSeparator: _withDateSeparator,
                    animated: _animated,
                    initialItems: initialItems,
                  );
                }
              }
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(
        minimum: EdgeInsets.all(12),
        child: ChattyWidget(
          animationTransition: (item, animation) {
            return getAnimationByAnimation(item, animation);
          },
          onItemExtraWidget: (item) {
            if (item == itemWithExtraWidget) {
              return Column(
                children: [
                  Image.asset('assets/flower.png', width: 140, height: 140),
                ],
              );
            }
            return null;
          },
          style: getStyleByStyles(),
          // themeData: ThemeData(
          //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          // ),
          onPrompt: onPrompt,
          controller: controller,
          withDocuments: true,
          enterDateString: 'Enter the date!',
          documentsString: 'SOURCES:',
          assistantPersona: Image.asset(
            'assets/buddy1.png',
            width: 40,
            height: 40,
          ),
          // assistantPersona: Icon(
          //   Icons.person_2,
          //   size: 40,
          //   color: Theme.of(context).colorScheme.inversePrimary,
          // ),
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

/// Screen with some configurations for the ChattyWidget.
class MyStyleScreen extends StatefulWidget {
  const MyStyleScreen({
    super.key,
    required this.styles,
    required this.animated,
    required this.withDateSeparator,
    required this.animation,
  });
  final ChattyWidgetStyles styles;
  final bool animated;
  final bool withDateSeparator;
  final ChattyWidgetAnimations animation;

  @override
  State<MyStyleScreen> createState() => _MyStyleScreenState();
}

class _MyStyleScreenState extends State<MyStyleScreen> {
  late ChattyWidgetStyles styles;
  late bool animated;
  late bool withDateSeparator;
  late ChattyWidgetAnimations animation;

  @override
  void initState() {
    styles = widget.styles;
    animated = widget.animated;
    withDateSeparator = widget.withDateSeparator;
    animation = widget.animation;
    super.initState();
  }

  static const animationMapper = {
    ChattyWidgetAnimations.fade: 'Fade',
    ChattyWidgetAnimations.scale: 'Scale',
    ChattyWidgetAnimations.rotate: 'Rotate',
  };

  static const stylesMapper = {
    ChattyWidgetStyles.empty: 'No style',
    ChattyWidgetStyles.playfully: 'Playful',
    ChattyWidgetStyles.business: 'Business',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Style and configuration'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop<ConfigScreenObject>(
                ConfigScreenObject(
                  animated: animated,
                  styles: styles,
                  withDateSeparator: withDateSeparator,
                  animation: animation,
                ),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Animate new messages'),
            trailing: animated ? Icon(Icons.check) : null,
            onTap: () {
              setState(() {
                animated = !animated;
              });
            },
          ),
          if (animated)
            ListTile(
              title: Text(
                'Animations',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          if (animated)
            ...animationMapper.entries.map(
              (e) => ListTile(
                title: Text(e.value),
                trailing: animation == e.key ? Icon(Icons.check) : null,
                onTap: () {
                  setState(() {
                    animation = e.key;
                  });
                },
              ),
            ),
          ListTile(
            title: Text(
              'Styles',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          ...stylesMapper.entries.map(
            (e) => ListTile(
              title: Text(e.value),
              trailing: styles == e.key ? Icon(Icons.check) : null,
              onTap: () {
                setState(() {
                  styles = e.key;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
