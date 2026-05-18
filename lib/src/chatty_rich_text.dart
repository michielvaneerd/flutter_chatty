import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;

class ChattyRichText extends StatefulWidget {
  const ChattyRichText({
    super.key,
    required this.text,
    this.onLinkClicked,
    this.textStyle,
  });
  final String text;
  final Function(String uri)? onLinkClicked;
  final TextStyle? textStyle;

  static final bolds = ['b', 'strong'];
  static final italics = ['i', 'em'];

  @override
  State<ChattyRichText> createState() => _ChattyRichTextState();

  static String getInnerText(String htmlText) {
    final fragment = html_parser.parseFragment(htmlText);
    return fragment.text ?? '';
  }
}

class _ChattyRichTextState extends State<ChattyRichText> {
  List<InlineSpan> _getRichTexts(html_dom.Node node) {
    var newList = <InlineSpan>[];
    for (var node in node.nodes) {
      if (node.nodeType == html_dom.Node.TEXT_NODE) {
        newList.add(TextSpan(text: node.text));
      } else {
        final nodeName = (node as html_dom.Element).localName;
        // Adding decoration to TextSpan doesn't work unfortunately, but WidgetSpan with child GestureDetector does work...
        if (nodeName == 'a') {
          newList.add(
            WidgetSpan(
              child: GestureDetector(
                onTap: () {
                  if (widget.onLinkClicked != null &&
                      node.attributes.containsKey('href') &&
                      node.attributes['href'] != null) {
                    widget.onLinkClicked!(node.attributes['href'].toString());
                  }
                },
                child: Text(
                  node.innerHtml,
                  style: (widget.textStyle ?? TextStyle()).copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          );
        } else {
          newList.add(
            TextSpan(
              children: _getRichTexts(node),
              style: (widget.textStyle ?? TextStyle())
                  .copyWith(
                    fontWeight: (ChattyRichText.bolds.contains(nodeName))
                        ? FontWeight.bold
                        : null,
                  )
                  .copyWith(
                    fontStyle: ChattyRichText.italics.contains(nodeName)
                        ? FontStyle.italic
                        : null,
                  ),
            ),
          );
        }
      }
    }
    return newList;
  }

  @override
  Widget build(BuildContext context) {
    final fragment = html_parser.parseFragment(widget.text);
    return Text.rich(
      TextSpan(children: _getRichTexts(fragment)),
      style: widget.textStyle,
    );
  }
}
