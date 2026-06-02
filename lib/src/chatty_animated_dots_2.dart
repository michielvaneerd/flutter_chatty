import 'package:flutter/material.dart';
import 'package:flutter_chatty/flutter_chatty.dart';

class ChattyAnimatedDots2 extends StatefulWidget {
  const ChattyAnimatedDots2({super.key, required this.style});
  final ChattyWidgetStyle style;

  @override
  State<ChattyAnimatedDots2> createState() => _ChattyAnimatedDots2State();
}

class _ChattyAnimatedDots2State extends State<ChattyAnimatedDots2>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animation1 = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Interval(0, 0.333)));
    _animation2 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.333, 0.666)),
    );
    _animation3 = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.666, 1)));
    _controller.repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _getBubble() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color:
            widget.style.thinkingDotsColor ??
            Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          spacing: ChattyWidget.paddingSmall,
          children: [
            Opacity(opacity: _animation1.value, child: _getBubble()),
            Opacity(opacity: _animation2.value, child: _getBubble()),
            Opacity(opacity: _animation3.value, child: _getBubble()),
          ],
        );
      },
    );
  }
}
