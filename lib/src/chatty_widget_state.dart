import 'package:equatable/equatable.dart';
import 'package:flutter_chatty/flutter_chatty.dart';

class ChattyWidgetState extends Equatable {
  final List<ChattyItem> items;
  final bool busy;
  const ChattyWidgetState({required this.items, this.busy = false});
  @override
  List<Object?> get props => [items, busy];

  ChattyWidgetState copyWith({List<ChattyItem>? items, bool? busy}) {
    return ChattyWidgetState(
      items: items ?? this.items,
      busy: busy ?? this.busy,
    );
  }
}
