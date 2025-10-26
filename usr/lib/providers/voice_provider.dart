import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';

class Message {
  final String text;
  final bool isUser;

  Message({required this.text, required this.isUser});
}

class VoiceProvider extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController textController = TextEditingController();

  bool _isListening = false;
  String _lastWords = '';
  final List<Message> _messages = [];

  bool get isListening => _isListening;
  String get lastWords => _lastWords;
  List<Message> get messages => _messages;

  VoiceProvider() {
    _initTts();
  }

  void _initTts() {
    _flutterTts.setLanguage('en-US');
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);
  }

  Future<void> startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      _isListening = true;
      notifyListeners();
      _speech.listen(
        onResult: (val) {
          _lastWords = val.recognizedWords;
          textController.text = _lastWords;
          if (val.finalResult) {
            processCommand(_lastWords);
          }
        },
      );
    }
  }

  void stopListening() {
    _speech.stop();
    _isListening = false;
    notifyListeners();
  }

  void processCommand(String command) {
    _messages.add(Message(text: command, isUser: true));
    notifyListeners();

    String response = _handleCommand(command.toLowerCase());
    _messages.add(Message(text: response, isUser: false));
    notifyListeners();

    _speak(response);
    textController.clear();
  }

  String _handleCommand(String command) {
    if (command.contains('open whatsapp')) {
      _openWhatsApp();
      return 'Opening WhatsApp...';
    } else if (command.contains('play music') && command.contains('youtube')) {
      _searchYouTube('music');
      return 'Playing music on YouTube...';
    } else if (command.contains('search') && command.contains('lyrics')) {
      String query = command.replaceAll('search', '').replaceAll('lyrics', '').trim();
      _searchYouTube('$query lyrics');
      return 'Searching for $query lyrics on YouTube...';
    } else if (command.startsWith('text')) {
      // Simple text message handling
      return 'Sending message... (This is a demo - actual messaging requires platform integration)';
    } else {
      return 'I\'m sorry, I didn\'t understand that command. Try saying "Open WhatsApp" or "Play music on YouTube".';
    }
  }

  void _openWhatsApp() {
    // Using url_launcher to open WhatsApp if installed
    launchUrl(Uri.parse('whatsapp://'));
  }

  void _searchYouTube(String query) {
    String url = 'https://www.youtube.com/results?search_query=${Uri.encodeComponent(query)}';
    launchUrl(Uri.parse(url));
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}