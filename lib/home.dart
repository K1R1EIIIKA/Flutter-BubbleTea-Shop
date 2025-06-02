import 'package:flutter/material.dart';
import 'web_view_page.dart';

class HomeView extends StatefulWidget {
  final String username;

  const HomeView({super.key, required this.username});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _topicController = TextEditingController();
  List<String> _urls = [];

  void _search() {
    final topic = _topicController.text.toLowerCase();
    setState(() {
      _urls = _generateUrls(topic);
    });
  }

  List<String> _generateUrls(String topic) {
    if (topic.contains('игры')) {
      return [
        'https://store.steampowered.com',
        'https://itch.io',
        'https://www.gog.com',
      ];
    } else if (topic.contains('новости')) {
      return [
        'https://www.bbc.com',
        'https://meduza.io',
        'https://lenta.ru',
      ];
    } else {
      return [
        'https://google.com/search?q=$topic',
        'https://duckduckgo.com/?q=$topic',
        'https://www.wikipedia.org',
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Привет, ${widget.username}!', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Введите тему',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _search,
              child: const Text('Показать сайты'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _urls.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_urls[index]),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WebViewPage(url: _urls[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
