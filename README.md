# flutter_chatty

A ready-to-use Flutter chat UI widget designed for LLM integration. Drop in `ChattyWidget` to get a full-featured conversational interface with support for questions, document references, animations, and custom styling.

## Features

- Message bubbles for user and assistant with timestamps
- Animated "thinking" indicator while awaiting responses
- Structured questions (text, int, email, date picker, single choice)
- Document/source references (PDF, DOCX, URL) for RAG applications
- Date separators between messages from different days
- Fade-in animations with customizable transitions
- Fully styleable via `ChattyWidgetStyle` and `ThemeData`
- External controller for programmatic state management
- Rich text support (HTML subset: `<p>`, `<b>`, `<strong>`, `<i>`, `<em>`)

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_chatty: ^0.0.2
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:flutter_chatty/flutter_chatty.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChattyWidget(
        onPrompt: (prompt, {questionName, answerValue}) async {
          // Send prompt to your LLM and return the response
          final response = await myLlmService.chat(prompt);
          return ChattyItem.fromAssistant(response);
        },
      ),
    );
  }
}
```

## Usage

### The `onPrompt` Callback

The `onPrompt` callback is the integration point for your LLM. It receives the user's text and must return a `ChattyItem`:

```dart
Future<ChattyItem> onPrompt(
  String prompt, {
  String? questionName,  // Set when this is an answer to a question
  String? answerValue,   // The structured value of the answer
}) async {
  final response = await yourLlmCall(prompt);
  return ChattyItem.fromAssistant(response);
}
```

When this callback is called from an answer to a question, then the `questionName` parameter contains the name of the question and the `answerValue` parameter contains the value of the answer (for single choice questions).

### Using a Controller

Use `ChattyWidgetController` to manage chat state externally (e.g., pre-populate with history or clear the conversation):

```dart
final controller = ChattyWidgetController(
  initialItems: [
    ChattyItem.fromAssistant(
      'Hello! How can I help you?',
      createdAt: DateTime.now(),
    ),
  ],
);

// In your widget tree:
ChattyWidget(
  onPrompt: onPrompt,
  controller: controller,
);

// Clear conversation:
controller.update(items: []);

// Don't forget to dispose when done:
controller.dispose();
```

### Asking Questions

Return a `ChattyItem` with a `ChattyQuestion` to prompt the user with structured input:

```dart
// Text input question
ChattyItem.fromAssistant(
  'What is your name?',
  question: ChattyQuestion(name: 'name', type: ChattyQuestionType.text),
);

// Date picker question
ChattyItem.fromAssistant(
  'What is your birthdate?',
  question: ChattyQuestion(
    name: 'birthdate',
    type: ChattyQuestionType.date,
    min: '1920-01-01',  // Optional min date (y-MM-dd format)
  ),
);

// Single choice question
ChattyItem.fromAssistant(
  'Do you agree?',
  question: ChattyQuestion(
    name: 'agreement',
    type: ChattyQuestionType.singleChoice,
    answers: [
      ChattyAnswer(value: 'yes', content: 'Yes'),
      ChattyAnswer(value: 'no', content: 'No'),
    ],
  ),
);
```

When the user answers, `onPrompt` is called with `questionName` and `answerValue` set. You can re-ask a question with an error message:

```dart
ChattyItem.fromAssistant(
  'Do you agree?',
  error: 'That answer is not valid.',
  question: ChattyQuestion(
    name: 'agreement',
    type: ChattyQuestionType.singleChoice,
    answers: [
      ChattyAnswer(value: 'yes', content: 'Yes'),
      ChattyAnswer(value: 'no', content: 'No'),
    ],
  ),
);
```

### Document References (RAG)

Attach source documents to assistant responses:

```dart
ChattyItem.fromAssistant(
  'Based on the documentation, here is the answer...',
  documents: [
    ChattyDocument(
      uri: 'https://example.com/docs',
      type: ChattyDocumentType.url,
      title: 'Official Documentation',
    ),
    ChattyDocument(
      uri: '/path/to/file.pdf',
      type: ChattyDocumentType.pdf,
      title: 'Technical Reference',
    ),
  ],
);
```

Enable document display and handle clicks:

```dart
ChattyWidget(
  onPrompt: onPrompt,
  withDocuments: true,
  documentsString: 'Sources:',
  onDocumentClicked: (doc) {
    // Open the document
  },
);
```

### Styling

Customize the appearance with `ChattyWidgetStyle`:

```dart
ChattyWidget(
  onPrompt: onPrompt,
  style: ChattyWidgetStyle(
    userColor: Colors.blue[100],
    assistantColor: Colors.grey[200],
    userTextStyle: TextStyle(fontSize: 16),
    assistantTextStyle: TextStyle(fontSize: 16),
    timeStyle: TextStyle(fontSize: 12, color: Colors.grey),
    dateStyle: TextStyle(fontWeight: FontWeight.bold),
    borderWidth: 1.0,
    userBorderColor: Colors.blue,
    assistantBorderColor: Colors.grey,
    userPadding: EdgeInsets.all(12),
    assistantPadding: EdgeInsets.all(12),
    dateBoxDecoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(12),
    ),
    datePadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  ),
);
```

You can also pass a `ThemeData` to integrate with your app's theme:

```dart
ChattyWidget(
  onPrompt: onPrompt,
  themeData: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  ),
);
```

### Animations

Enable fade-in animations for new messages:

```dart
ChattyWidget(
  onPrompt: onPrompt,
  animated: true,
  // Optional custom transition:
  animationTransition: (item, animation) => ScaleTransition(
    scale: CurvedAnimation(parent: animation, curve: Curves.easeIn),
    child: item,
  ),
);
```

### Assistant Persona

Display a custom icon next to assistant messages:

```dart
ChattyWidget(
  onPrompt: onPrompt,
  assistantPersona: Icon(Icons.smart_toy, size: 40),
);
```

### Custom Extra Widgets

Add custom widgets below any chat item:

```dart
ChattyWidget(
  onPrompt: onPrompt,
  onItemExtraWidget: (item) {
    if (item.source == ChattyItemSource.assistant) {
      return Row(children: [
        IconButton(icon: Icon(Icons.thumb_up), onPressed: () {}),
        IconButton(icon: Icon(Icons.thumb_down), onPressed: () {}),
      ]);
    }
    return null;
  },
);
```

## API Reference

### ChattyWidget

| Parameter | Type | Description |
|-----------|------|-------------|
| `onPrompt` | `Future<ChattyItem> Function(String, {String? questionName, String? answerValue})` | **Required.** Callback for handling user input. |
| `controller` | `ChattyWidgetController?` | External controller for state management. |
| `style` | `ChattyWidgetStyle` | Styling configuration. |
| `themeData` | `ThemeData?` | Optional theme override. |
| `animated` | `bool` | Enable fade-in animations. Default: `false`. |
| `animationTransition` | `Widget Function(Widget, Animation<double>)?` | Custom animation transition. |
| `withDocuments` | `bool` | Show document references. Default: `false`. |
| `withDateSeparator` | `bool` | Show date headers. Default: `false`. |
| `promptTextFieldDisabled` | `bool` | Disable the input field. Default: `false`. |
| `promptPlaceHolder` | `String?` | Placeholder text for the input field. |
| `assistantPersona` | `Widget?` | Icon widget shown next to assistant messages. |
| `documentsString` | `String` | Label for document list. Default: `'Sources:'`. |
| `enterDateString` | `String` | Label for date picker button. Default: `'Enter date'`. |
| `onDocumentClicked` | `void Function(ChattyDocument)?` | Callback when a document is tapped. |
| `onItemExtraWidget` | `Widget? Function(ChattyItem)?` | Custom widget builder per item. |

### ChattyItem

| Factory | Description |
|---------|-------------|
| `ChattyItem.fromUser(String content)` | Creates a user message. |
| `ChattyItem.fromAssistant(String content, {question, error, documents})` | Creates an assistant message. |
| `ChattyItem.fromDateSeparator(DateTime)` | Creates a date separator (used internally). |

### ChattyQuestion

| Property | Type | Description |
|----------|------|-------------|
| `name` | `String` | Identifier returned in `onPrompt` as `questionName`. |
| `type` | `ChattyQuestionType` | One of: `text`, `int`, `email`, `date`, `singleChoice`. |
| `min` | `String?` | Minimum value constraint. |
| `max` | `String?` | Maximum value constraint. |
| `answers` | `List<ChattyAnswer>?` | Options for `singleChoice` type. |

### ChattyDocument

| Property | Type | Description |
|----------|------|-------------|
| `uri` | `String` | Location of the document. |
| `type` | `ChattyDocumentType` | One of: `pdf`, `docx`, `url`. |
| `title` | `String` | Display title. |

## Example

See the [example app](example/lib/main.dart) for a complete demo showcasing all features.

## License

See [LICENSE](LICENSE) for details.
