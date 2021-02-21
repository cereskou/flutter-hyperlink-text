import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TextPart {
  final String text;
  final String url;

  const TextPart(this.text, {this.url});
}

class LinkedText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextStyle linkStyle;
  final ValueChanged<String> onPressed;

  const LinkedText({
    Key key,
    @required this.text,
    this.style,
    this.linkStyle = const TextStyle(color: Colors.blue),
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RegExp exp = new RegExp(r"(?:__|[*#])|\[(.*?)\]\(.*?\)");
    Iterable<Match> matches = exp.allMatches(text);
    int pos = 0;
    List<TextPart> texts = [];
    RegExp mdexp = new RegExp(r"(?<=\[).*(?=\])|(?<=\().*(?=\))");
    matches.forEach((m) {
      if (m.start > -1) {
        texts.add(TextPart(text.substring(pos, m.start)));
        var link = text.substring(m.start, m.end);
        Iterable<Match> md = mdexp.allMatches(link);
        if (md.length == 2) {
          var t = link.substring(md.first.start, md.first.end);
          var l = link.substring(md.last.start, md.last.end);
          texts.add(TextPart(t, url: l));
        }
        pos = m.end;
      }
    });
    if (pos > -1) {
      texts.add(TextPart(text.substring(pos)));
    }
    return Container(
      child: Text.rich(
        TextSpan(
            children: List.generate(texts.length, (index) {
          var t = texts[index];
          return TextSpan(
            text: t.text,
            style: t.url == null ? style : linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                if (onPressed == null) {
                  if (await canLaunch(t.url)) {
                    await launch(t.url);
                  } else {
                    throw 'Could not launch ${t.url}';
                  }
                } else {
                  onPressed(t.url);
                }
              },
          );
        })),
      ),
    );
  }
}
