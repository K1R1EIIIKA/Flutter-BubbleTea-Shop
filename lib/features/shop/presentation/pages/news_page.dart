import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/shop_icon_button.dart';
import '../../../../core/shop_theme.dart';

const _headline = 'Что нового в Biba & Boba';
const _articles = [
  (
    title: 'Сохраняйте любимые вкусы',
    body:
        'Нажмите на сердечко в карточке напитка, чтобы он появился в фильтре '
        '«Избранное». Там же можно прикрепить личное фото напитка.',
  ),
  (
    title: 'Соберите напиток по своему вкусу',
    body:
        'В карточке можно выбрать объём, количество льда, сладость и топпинг. '
        'Состав можно поменять и после добавления напитка в корзину.',
  ),
];

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  static const _channel = MethodChannel('bubble_tea/news');
  WebViewController? _controller;
  bool _webViewReady = false;

  @override
  void initState() {
    super.initState();
    _openWebView();
  }

  Future<bool> _canUseWebView() async {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _channel.invokeMethod<bool>('canUseWebView') ?? false;
    }
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  Future<void> _openWebView() async {
    try {
      if (!await _canUseWebView() || !mounted) return;
      final controller = WebViewController();
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted && _controller == controller) {
              setState(() => _webViewReady = true);
            }
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame != false) _showArticles();
          },
        ),
      );
      if (!mounted) return;
      setState(() => _controller = controller);
      await controller.loadHtmlString(_newsHtml());
    } catch (_) {
      _showArticles();
    }
  }

  void _showArticles() {
    if (mounted && _controller != null) {
      setState(() {
        _controller = null;
        _webViewReady = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      appBar: AppBar(leading: const ShopBackButton(), title: const Text('Новости')),
      body: SafeArea(
        child: controller == null
            ? const _NewsArticles()
            : Stack(
                fit: StackFit.expand,
                children: [
                  WebViewWidget(controller: controller),
                  if (!_webViewReady)
                    const ColoredBox(
                      color: shopBackground,
                      child: _NewsArticles(),
                    ),
                ],
              ),
      ),
    );
  }
}

class _NewsArticles extends StatelessWidget {
  const _NewsArticles();

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).textTheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            Semantics(
              header: true,
              child: Text(
                _headline,
                style: typography.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            for (final article in _articles) ...[
              const SizedBox(height: 24),
              Semantics(
                header: true,
                child: Text(
                  article.title,
                  style: typography.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(article.body, style: typography.bodyLarge),
              const SizedBox(height: 16),
              const Divider(height: 1),
            ],
          ],
        ),
      ),
    );
  }
}

String _newsHtml() {
  const escape = HtmlEscape();
  final articles = _articles
      .map(
        (article) =>
            '<article><h2>${escape.convert(article.title)}</h2>'
            '<p>${escape.convert(article.body)}</p></article>',
      )
      .join();
  return '''
<!doctype html>
<html lang="ru">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Новости Biba &amp; Boba</title>
<style>
  body { max-width: 40rem; margin: 24px auto; padding: 0 24px; color: #26211e;
         background: #fffdfc; font: 17px/1.55 system-ui, sans-serif; }
  h1 { margin: 0; font-size: 1.6rem; line-height: 1.2; }
  article { padding: 16px 0; border-bottom: 1px solid #e1d8d1; }
  h2 { font-size: 1.2rem; line-height: 1.3; }
  p { margin-bottom: 0; }
</style>
<main><h1>${escape.convert(_headline)}</h1>$articles</main>
</html>
''';
}
