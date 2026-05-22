# flutter_chatty

A Flutter Chat UI package that provides a ready-to-use chat widget with support for user/assistant messages, questions, document references, date separators, and customizable styling.

## Features

- Chat bubble UI with user and assistant messages
- Animated typing indicator while waiting for responses
- Built-in question types: text, integer, email, date (with date picker), and single choice
- Document/source references (useful for RAG applications)
- Date separators between messages from different days
- Rich text support (HTML tags: `<p>`, `<b>`, `<strong>`, `<i>`, `<em>`)
- Fully customizable styling via `ChattyWidgetStyle`
- Optional `ThemeData` override
- Assistant persona icon

## Installation

Add `flutter_chatty` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_chatty:
    git:
      url: https://github.com/michielvaneerd/flutter_chatty
```

## Usage

### Basic setup

```dart
import 'package:flutter_chatty/flutter_chatty.dart';

ChattyWidget(
  onPrompt: (String prompt, {String? value}) async {
    // Send the prompt to your LLM / backend and return a ChattyItem
    final response = await myApi.sendMessage(prompt);
    return ChattyItem.fromAssistant(response.text);
  },
)
```

### With initial messages and options

```dart
ChattyWidget(
  onPrompt: onPrompt,
  initialItems: [
    ChattyItem.fromAssistant('Hi! How can I help you?'),
  ],
  withDateSeparator: true,
  withDocuments: true,
  promptPlaceHolder: 'Type a message...',
  assistantPersona: Icon(Icons.smart_toy),
  onDocumentClicked: (doc) {
    // Handle document tap
  },
)
```

## The `onPrompt` callback

The `onPrompt` callback is the core of the widget. It is called when the user submits a message or answers a question. You receive the prompt text and an optional `value` (for structured answers like single choice selections). Return a `ChattyItem` representing the assistant's response.

```dart
Future<ChattyItem> onPrompt(String prompt, {String? value}) async {
  final response = await myBackend.chat(prompt);
  return ChattyItem.fromAssistant(response.text);
}
```

## Creating messages

### Assistant messages

```dart
ChattyItem.fromAssistant('Hello!')
```

### User messages

```dart
ChattyItem.fromUser('What is Flutter?')
```

### Messages with errors

```dart
ChattyItem.fromAssistant(
  'Please try again.',
  error: 'Something went wrong',
)
```

## Questions

Return a `ChattyItem` with a `ChattyQuestion` to prompt the user for structured input.

### Text question

The user answers via the text field:

```dart
ChattyItem.fromAssistant(
  'What is your name?',
  question: ChattyQuestion(type: ChattyQuestionType.text),
)
```

### Date question

A date picker button replaces the text field. Use `min` and `max` to constrain the date range (format: `y-MM-dd`):

```dart
ChattyItem.fromAssistant(
  'When were you born?',
  question: ChattyQuestion(
    type: ChattyQuestionType.date,
    min: '1920-01-01',
    max: '2010-12-31',
  ),
)
```

### Single choice question

Displays choice buttons. The text field is disabled:

```dart
ChattyItem.fromAssistant(
  'Do you agree?',
  question: ChattyQuestion(
    type: ChattyQuestionType.singleChoice,
    answers: [
      ChattyAnswer(value: 'yes', content: 'Yes'),
      ChattyAnswer(value: 'no', content: 'No'),
    ],
  ),
)
```

When the user selects an answer, `onPrompt` is called with `prompt` set to the answer's `content` and `value` set to the answer's `value`.

### Validating answers

To reject an answer, return the same question again with an `error`:

```dart
ChattyItem.fromAssistant(
  'Do you agree?',
  error: 'That answer is not valid.',
  question: ChattyQuestion(
    type: ChattyQuestionType.singleChoice,
    answers: [
      ChattyAnswer(value: 'yes', content: 'Yes'),
      ChattyAnswer(value: 'no', content: 'No'),
    ],
  ),
)
```

## Documents

Attach source documents to assistant messages (e.g. for RAG applications). Set `withDocuments: true` on the widget to display them.

```dart
ChattyItem.fromAssistant(
  'Here is what I found.',
  documents: [
    ChattyDocument(
      uri: 'https://docs.flutter.dev',
      type: ChattyDocumentType.url,
      title: 'Flutter docs',
    ),
    ChattyDocument(
      uri: '/path/to/file.pdf',
      type: ChattyDocumentType.pdf,
      title: 'Report',
    ),
  ],
)
```

Handle taps with the `onDocumentClicked` callback:

```dart
ChattyWidget(
  onDocumentClicked: (ChattyDocument doc) {
    // Open the document
  },
  // ...
)
```

## Styling

Use `ChattyWidgetStyle` to customize colors, text styles, and paddings:

```dart
ChattyWidget(
  style: ChattyWidgetStyle(
    userColor: Colors.limeAccent,
    assistantColor: Colors.grey.shade200,
    userTextStyle: TextStyle(fontSize: 14),
    assistantTextStyle: TextStyle(fontSize: 16),
    timeStyle: TextStyle(fontSize: 10, color: Colors.grey),
    dateStyle: TextStyle(fontWeight: FontWeight.bold),
    datePadding: EdgeInsets.symmetric(vertical: 8),
    dateBoxDecoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
    ),
    userPadding: EdgeInsets.all(12),
    assistantPadding: EdgeInsets.all(12),
    documentsStringStyle: TextStyle(fontWeight: FontWeight.bold),
    documentsLinkStyle: TextStyle(color: Colors.blue),
  ),
  // ...
)
```

You can also pass a `themeData` to override the inherited theme:

```dart
ChattyWidget(
  themeData: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
  ),
  // ...
)
```

## Localization

The following strings can be customized:

| Parameter | Default | Description |
|-----------|---------|-------------|
| `promptPlaceHolder` | `null` | Hint text in the input field |
| `documentsString` | `'Sources:'` | Label above the document list |
| `enterDateString` | `'Enter date'` | Text on the date picker button |

## API Reference

### ChattyWidget parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `onPrompt` | `Future<ChattyItem> Function(String, {String? value})` | Yes | Callback when user sends a message |
| `initialItems` | `List<ChattyItem>?` | No | Pre-populated messages |
| `withDateSeparator` | `bool` | No | Show date headers between days |
| `withDocuments` | `bool` | No | Show document references |
| `style` | `ChattyWidgetStyle` | No | Visual customization |
| `themeData` | `ThemeData?` | No | Theme override |
| `onDocumentClicked` | `void Function(ChattyDocument)?` | No | Document tap handler |
| `promptPlaceHolder` | `String?` | No | Input field hint |
| `assistantPersona` | `Widget?` | No | Icon next to assistant messages |
| `documentsString` | `String` | No | Label for documents section |
| `enterDateString` | `String` | No | Date picker button text |

### Models

- **`ChattyItem`** — A single chat message (user, assistant, or date separator)
- **`ChattyQuestion`** — Defines a question type and constraints
- **`ChattyAnswer`** — A selectable answer for single choice questions
- **`ChattyDocument`** — A document reference attached to a message

### Enums

- **`ChattyItemSource`** — `user`, `assistant`, `dateSeparator`
- **`ChattyQuestionType`** — `none`, `text`, `int`, `email`, `date`, `singleChoice`
- **`ChattyDocumentType`** — `pdf`, `docx`, `url`

## License

See [LICENSE](LICENSE) for details.
