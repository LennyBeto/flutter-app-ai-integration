import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemini Chat App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Gemini Chat'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  String _cloudRunHost = '';

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final configString = await rootBundle.loadString('assets/config.json');
      final config = json.decode(configString);
      setState(() {
        _cloudRunHost = config['cloudRunHost'];
      });
    } catch (e) {
      debugPrint("Error loading config: $e");
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final message = _controller.text;
    _controller.clear();

    setState(() {
      _messages.add({'sender': 'user', 'text': message});
    });

    if (_cloudRunHost.isEmpty ||
        _cloudRunHost == 'YOUR_CLOUD_RUN_ENDPOINT_URL') {
      setState(() {
        _messages.add({
          'sender': 'bot',
          'text':
              'Please configure the Cloud Run endpoint in assets/config.json'
        });
      });
      return;
    }

    try {
      var endpointQuery =
          Uri.https(_cloudRunHost, '/ask_gemini', {'query': message});
      final response = await http.get(endpointQuery);

      if (response.statusCode == 200) {
        var responseText = utf8.decode(response.bodyBytes);
        responseText = responseText.replaceAll(RegExp(r'\*'), '');
        setState(() {
          _messages.add({'sender': 'bot', 'text': responseText});
        });
      } else {
        setState(() {
          _messages
              .add({'sender': 'bot', 'text': 'Error: ${response.statusCode}'});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'sender': 'bot', 'text': 'Error: $e'});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUserMessage = message['sender'] == 'user';
                return Align(
                  alignment: isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color:
                          isUserMessage ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(message['text'] ?? ''),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter a message',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (text) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} // Properly closed class