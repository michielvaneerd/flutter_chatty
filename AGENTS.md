# Flutter Chatty Package Agent Instructions

This package provides a Flutter chat UI component with support for user/assistant messages, questions, document references, date separators, and customizable styling.

## Project Structure

- `lib/flutter_chatty.dart` - Main entry point
- `lib/src/` - Core implementation files:
  - `chatty_widget.dart` - Main chat widget
  - `chatty_item_widget.dart` - Individual message item widget
  - `chatty_widget_cubit.dart` - State management
  - `models.dart` - Data models for chat items, questions, documents
  - `chatty_helpers.dart` - Helper functions
  - `chatty_rich_text.dart` - Rich text rendering
  - `chatty_animated_dots.dart` - Animated typing indicator
  - `chatty_date_separator.dart` - Date separator widget

## Key Concepts

### Chat Items
- `ChattyItem` represents a single message with content, source, and metadata
- Sources: `user`, `assistant`, `dateSeparator`
- Supports questions with different types: `text`, `int`, `email`, `date`, `singleChoice`
- Supports document references for RAG applications

### State Management
- Uses `flutter_bloc` for state management
- `ChattyWidgetCubit` handles the chat state and user interactions

### Styling
- Customizable via `ChattyWidgetStyle` class
- Supports colors, text styles, and paddings for different message types
- Theme override support via `themeData` parameter

## Core Functions

### ChattyWidget
The main widget that displays the chat interface. Key parameters:
- `onPrompt`: Callback that receives user prompts and returns assistant responses
- `initialItems`: Pre-populated messages
- `withDateSeparator`: Show date headers between days
- `withDocuments`: Show document references
- `style`: Visual customization options
- `themeData`: Theme override

### Message Creation
- `ChattyItem.fromUser(content)` - Create a user message
- `ChattyItem.fromAssistant(content)` - Create an assistant message
- `ChattyItem.fromAssistant(content, question: ChattyQuestion(...))` - Create a question
- `ChattyItem.fromAssistant(content, documents: [ChattyDocument(...)])` - Create with documents

## Usage Patterns

### Basic Chat
```dart
ChattyWidget(
  onPrompt: (String prompt, {String? value}) async {
    // Send to backend and return ChattyItem
    return ChattyItem.fromAssistant('Response to: $prompt');
  },
)
```

### With Questions
```dart
ChattyItem.fromAssistant(
  'What is your name?',
  question: ChattyQuestion(type: ChattyQuestionType.text),
)
```

### With Documents
```dart
ChattyItem.fromAssistant(
  'Here are the sources:',
  documents: [
    ChattyDocument(uri: 'https://example.com', type: ChattyDocumentType.url, title: 'Example'),
  ],
)
```

## Development Guidelines

1. All widgets are stateless for better performance
2. Uses `flutter_bloc` for state management
3. Supports rich text with HTML tags: `<p>`, `<b>`, `<strong>`, `<i>`, `<em>`
4. Follows Flutter best practices for widget composition
5. Uses `equatable` for proper object equality in models
6. Implements proper date formatting with `intl` package
7. Supports localization through string parameters

## Testing

The package includes unit tests in `test/` directory. Tests cover:
- Widget rendering
- State management
- Message creation
- Question handling
- Document display