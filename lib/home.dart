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

  final Map<String, List<String>> topicUrls = {
    'игры': [
      'https://store.steampowered.com',
      'https://itch.io',
      'https://www.gog.com',
    ],
    'новости': [
      'https://www.bbc.com',
      'https://meduza.io',
      'https://lenta.ru',
    ],
    'фильмы': [
      'https://www.kinopoisk.ru',
      'https://www.imdb.com',
      'https://www.netflix.com',
    ],
    'музыка': [
      'https://www.last.fm',
      'https://music.yandex.ru',
      'https://www.spotify.com',
    ],
    'книги': [
      'https://www.litres.ru',
      'https://www.ozon.ru',
      'https://www.amazon.com/books',
    ],
    'спорт': [
      'https://www.sports.ru',
      'https://www.espn.com',
      'https://www.olympic.org',
    ],
    'технологии': [
      'https://www.techcrunch.com',
      'https://www.theverge.com',
      'https://www.wired.com',
    ],
    'еда': [
      'https://www.foodnetwork.com',
      'https://www.allrecipes.com',
      'https://www.bbcgoodfood.com',
    ],
    'путешествия': [
      'https://www.tripadvisor.com',
      'https://www.booking.com',
      'https://www.airbnb.com',
    ],
    'искусство': [
      'https://www.artstation.com',
      'https://www.deviantart.com',
      'https://www.behance.net',
    ],
    'наука': [
      'https://www.nature.com',
      'https://www.sciencemag.org',
      'https://www.sciencedirect.com',
    ],
    'финансы': [
      'https://www.forbes.com',
      'https://www.investopedia.com',
      'https://www.moneycontrol.com',
    ],
    'здоровье': [
      'https://www.webmd.com',
      'https://www.healthline.com',
      'https://www.mayoclinic.org',
    ],
    'образование': [
      'https://www.khanacademy.org',
      'https://www.coursera.org',
      'https://www.edx.org',
    ],
    'животные': [
      'https://www.nationalgeographic.com/animals',
      'https://www.worldwildlife.org',
      'https://www.animalplanet.com',
    ],
  };

  List<String> _generateUrls(String topic) {
    for (final entry in topicUrls.entries) {
      if (topic.contains(entry.key)) {
        return entry.value;
      }
    }
    return [
      'https://google.com/search?q=$topic',
      'https://duckduckgo.com/?q=$topic',
      'https://yandex.ru/search/?text=$topic',
    ];
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
