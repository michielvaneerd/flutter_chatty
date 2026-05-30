# flutter_chatty — Agent Instructions

Flutter plugin providing a ready-to-use chat UI widget (`ChattyWidget`) designed for LLM integration. See [README.md](README.md) for usage overview.

## Build & Test Commands

```bash
flutter pub get       # fetch dependencies
flutter analyze       # lint (flutter_lints)
flutter test          # run unit/widget tests
cd example && flutter run   # run demo app
```

## Project Structure

| Path | Purpose |
|------|---------|
| `lib/flutter_chatty.dart` | Public API — all exports |
| `lib/src/` | Implementation; all classes prefixed with `Chatty` |
| `example/lib/main.dart` | Demo app; shows all features and usage patterns |
| `test/flutter_chatty_test.dart` | Unit/widget tests |

## Architecture

State management uses **ChangeNotifier + immutable state**:

- `ChattyWidgetController` → wraps `ChattyWidgetChangeNotifier`
- `ChattyWidgetChangeNotifier` (ChangeNotifier) → holds `ChattyWidgetState`
- `ChattyWidgetState` (Equatable) → immutable; holds `items` list + `isBusy` flag
- `ChattyWidget` uses `ListenableBuilder` to rebuild on state changes

Items are stored in **reverse chronological order** (newest at index 0).

## Key Classes

| Class | Role |
|-------|------|
| `ChattyWidget` | Main StatefulWidget; renders list, handles text input |
| `ChattyWidgetController` | External handle for adding/updating items |
| `ChattyItem` | Message model; factory constructors `fromUser()`, `fromAssistant()`, `fromDateSeparator()` |
| `ChattyQuestion` | Structured question (types: `text`, `int`, `email`, `date`, `singleChoice`) |
| `ChattyDocument` | Source reference for RAG (types: `pdf`, `docx`, `url`) |
| `ChattyWidgetStyle` | Immutable styling config; prefer named constructor with override fields |

## Conventions

- **All public types use `Chatty` prefix.** Private helpers use leading `_`.
- **Models extend `Equatable`** — always include all fields in `props`.
- **Immutable state updates:** mutate a copy of the items list, then call `notifyListeners()` via `update()` — never mutate the live state object directly.
- **Constants defined at class level** (e.g., `paddingDefault = 12.0`, `borderRadiusDefault = 18.0`).
- **onPrompt callback** is the integration point for LLM calls; it is `async` and receives `(String prompt, {String? questionName, String? answerValue})`.
- `getFullItems()` injects `ChattyDateSeparator` items at runtime — do not store separators in the items list.

## Common Pitfalls

- When adding a new `ChattyItem` type or `ChattyQuestionType`, update the relevant `switch` statements in `ChattyItemWidget` and `ChattyWidget`.
- The "thinking" bubble is a temporary `fromAssistant("")` item inserted while awaiting `onPrompt`; replace it by index, don't append.
- `ChattyWidget` can accept an external `controller` or auto-create an internal one — do not assume one or the other when reading call sites.
