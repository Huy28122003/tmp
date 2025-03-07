import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class TestSpeechToText extends StatefulWidget {
  @override
  _TestSpeechToTextState createState() => _TestSpeechToTextState();
}

class _TestSpeechToTextState extends State<TestSpeechToText> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = 'Flutter is an amazing framework. Flutter allows developers to'
      ' build beautiful Flutter applications efficiently. The power of Flutter '
      'lies in its simplicity and performance';
  String _currentWord = '';
  List<TextRange> _occurrences = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  void _initializeSpeech() async {
    await _speech.initialize();
    setState(() {});
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) => _processSpeech(result.recognizedWords),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _processSpeech(String words) {
    if (words.isEmpty) return;

    setState(() {
      String targetWord = words.trim().split(' ').last;
      _updateBoldWord(targetWord);
    });
  }

  void _updateBoldWord(String word) {
    if (word == _currentWord) {
      if (_occurrences.isNotEmpty) {
        _currentIndex = (_currentIndex + 1) % _occurrences.length;
      }
    } else {
      _currentWord = word;
      _occurrences = _findOccurrences(word);
      _currentIndex = 0;
    }
  }

  List<TextRange> _findOccurrences(String word) {
    List<TextRange> ranges = [];
    if (word.isEmpty) return ranges;

    RegExp regExp = RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false);
    Iterable<Match> matches = regExp.allMatches(_text);

    for (var match in matches) {
      ranges.add(TextRange(start: match.start, end: match.end));
    }

    return ranges;
  }


  List<TextSpan> _buildTextSpans() {
    List<TextSpan> spans = [];
    int lastPos = 0;

    for (int i = 0; i < _occurrences.length; i++) {
      final range = _occurrences[i];
      if (range.start > lastPos) {
        spans.add(TextSpan(text: _text.substring(lastPos, range.start)));
      }
      spans.add(TextSpan(
        text: _text.substring(range.start, range.end),
        style: i == _currentIndex ? TextStyle(color: Colors.red) : null,
      ));

      lastPos = range.end;
    }
    if (lastPos < _text.length) {
      spans.add(TextSpan(text: _text.substring(lastPos)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bold Spoken Words')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 20, color: Colors.black),
            children: _buildTextSpans(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _listen,
        child: Icon(_isListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}


