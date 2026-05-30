import 'dart:async';

import 'package:flutter/material.dart';

class ChattyAnimatedDots extends StatefulWidget {
  const ChattyAnimatedDots({super.key, this.textStyle});
  final TextStyle? textStyle;

  @override
  State<ChattyAnimatedDots> createState() => _ChattyAnimatedDotsState();
}

class _ChattyAnimatedDotsState extends State<ChattyAnimatedDots> {
  late Timer _timer;
  int counter = 0;
  static const maxCount = 4;

  @override
  void initState() {
    _timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        if (counter == maxCount) {
          counter = 0;
        } else {
          counter += 1;
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.5,
      alignment: Alignment.centerLeft,
      child: Text(List.filled(counter, '.').join(' '), style: widget.textStyle),
    );
  }
}
