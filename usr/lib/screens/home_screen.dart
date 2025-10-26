import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lexa AI'),
        centerTitle: true,
      ),
      body: Consumer<VoiceProvider>(
        builder: (context, voiceProvider, child) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: voiceProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = voiceProvider.messages[index];
                    return Align(
                      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: message.isUser ? Colors.blue : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: message.isUser ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (voiceProvider.isListening)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Listening...',
                    style: TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: voiceProvider.textController,
                        decoration: const InputDecoration(
                          hintText: 'Type a command...',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (text) {
                          voiceProvider.processCommand(text);
                        },
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    FloatingActionButton(
                      onPressed: () {
                        if (voiceProvider.isListening) {
                          voiceProvider.stopListening();
                        } else {
                          voiceProvider.startListening();
                        }
                      },
                      child: Icon(
                        voiceProvider.isListening ? Icons.mic_off : Icons.mic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}