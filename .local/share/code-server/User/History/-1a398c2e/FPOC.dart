import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemini Chat App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
final TextEditingController _controller = TextEditingController();
final List<Map<String, String>> _messages = [];
String _cloudRunHost = '';
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
void initState() {
    super.initState();
    _loadConfig();
}
Future<void> _loadConfig() async {
    final configString = await rootBundle.loadString('assets/config.json');
    final config = json.decode(configString);
    setState(() {
        _cloudRunHost = config['cloudRunHost'];
    });
}
Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) {
        return;
    }

    final message = _controller.text;
    _controller.clear();

    setState(() {
        _messages.add({'sender': 'user', 'text': message});
    });

    if (_cloudRunHost.isEmpty || _cloudRunHost == 'YOUR_CLOUD_RUN_ENDPOINT_URL') {
        setState(() {
            _messages.add({
                'sender': 'bot',
                'text': 'Please configure the Cloud Run endpoint in assets/config.json'
            });
        });
        return;
    }

    try {
        var endpoint_query = Uri.https(_cloudRunHost, '/ask_gemini', {'query': message});
        final response = await http.get(endpoint_query);

        if (response.statusCode == 200) {
            var responseText = utf8.decode(response.bodyBytes);
            responseText = responseText.replaceAll(RegExp(r'\*'), '');
            setState(() {
                _messages.add({'sender': 'bot', 'text': responseText});
            });
        } else {
            setState(() {
                _messages.add({
                    'sender': 'bot',
                    'text': 'Error: ${response.statusCode}'
                });
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
            title: const Text('Gemini Chat App'),
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
                                alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                        color: isUserMessage ? Colors.blue[100] : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Text(message['text']!),
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
                                    ),
                                    onSubmitted: (text) => _sendMessage(),
                                ),
                            ),
                            IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: _sendMessage,
                            ),
                        ],
                    ),
                ),
            ],
        ),
    );
}