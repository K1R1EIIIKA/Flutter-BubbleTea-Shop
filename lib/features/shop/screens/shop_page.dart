import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/shop_icon_button.dart';
import '../../../core/shop_theme.dart';
import '../../auth/auth_cubit.dart';
import '../drink.dart';
import '../drink_notes_cubit.dart';
import '../shop_cubit.dart';
import 'drink_detail_page.dart';

const _popularViewportFraction = 0.9;
const _popularCardGap = 10.0;

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  DrinkCategory? _category;
  bool _showFavorites = false;

  Future<void> _refresh() async {
    final refreshed = await context.read<ShopCubit>().refreshDrinks();
    if (!refreshed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось обновить меню.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    final greeting = auth is AuthAuthenticated
        ? 'Привет, ${auth.user.username}!'
        : 'Добро пожаловать!';
    final state = context.watch<ShopCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biba & Boba'),
        actions: [
          ShopIconButton(
            label: 'Профиль',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: switch (state) {
              ShopLoaded() when state.drinks.isNotEmpty => _menu(
                context,
                state.drinks,
                greeting,
              ),
              ShopLoaded() => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('В меню пока нет напитков.'),
                    TextButton(
                      onPressed: _refresh,
                      child: const Text('Обновить'),
                    ),
                  ],
                ),
              ),
              ShopError() => Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        'Не удалось загрузить меню.',
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: _refresh,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
              ),
              _ => const Center(
                child: CircularProgressIndicator(
                  semanticsLabel: 'Загрузка меню',
                ),
              ),
            },
          ),
        ),
      ),
    );
  }

  Widget _menu(BuildContext context, List<Drink> drinks, String greeting) {
    final popular = drinks.where((drink) => drink.popular).toList();
    final categories = DrinkCategory.values.where(
      (category) => drinks.any((drink) => drink.category == category),
    );
    final notes = context.watch<DrinkNotesCubit?>()?.state;
    final visible = drinks
        .where(
          (drink) => _showFavorites
              ? notes?.forDrink(drink.name).favorite == true
              : _category == null || drink.category == _category,
        )
        .toList();
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        key: const PageStorageKey('menu'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Semantics(
            header: true,
            child: Text(
              greeting,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) => Align(
              alignment: Alignment.center,
              child: SizedBox(
                width:
                    constraints.maxWidth * _popularViewportFraction -
                    _popularCardGap,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFDCEBE2),
                    foregroundColor: const Color(0xFF244535),
                    textStyle: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.centerLeft,
                    minimumSize: const Size(0, 56),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/news'),
                  child: const Text('Новости'),
                ),
              ),
            ),
          ),
          if (popular.isNotEmpty && !_showFavorites) ...[
            const SizedBox(height: 14),
            _PopularDrinks(key: ValueKey(popular.length), drinks: popular),
          ],
          const SizedBox(height: 22),
          Semantics(
            header: true,
            child: Text(
              'Каталог',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _filter('Все', null),
              for (final category in categories)
                _filter(category.label, category),
              if (notes?.ready == true)
                ChoiceChip(
                  label: const Text('Избранное'),
                  selected: _showFavorites,
                  selectedColor: shopSurface,
                  onSelected: (_) => setState(() => _showFavorites = true),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_showFavorites && visible.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Сохраняйте любимые напитки в их карточках.'),
            ),
          for (var index = 0; index < visible.length; index += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _CatalogCard(
                      key: ValueKey('menu-${visible[index].name}'),
                      drink: visible[index],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: index + 1 < visible.length
                        ? _CatalogCard(
                            key: ValueKey('menu-${visible[index + 1].name}'),
                            drink: visible[index + 1],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _filter(String label, DrinkCategory? category) => ChoiceChip(
    label: Text(label),
    selected: !_showFavorites && _category == category,
    selectedColor: shopSurface,
    onSelected: (_) => setState(() {
      _showFavorites = false;
      _category = category;
    }),
  );
}

void _openDrink(BuildContext context, Drink drink) => Navigator.push<void>(
  context,
  MaterialPageRoute(
    settings: const RouteSettings(name: '/drink'),
    builder: (_) => DrinkDetailPage(drink: drink),
  ),
);

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({super.key, required this.drink});
  final Drink drink;

  @override
  Widget build(BuildContext context) {
    final price = formatShopPrice(drink.price);
    return Semantics(
      button: true,
      label: 'Подробнее: ${drink.displayName}, $price',
      onTap: () => _openDrink(context, drink),
      excludeSemantics: true,
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: shopDivider),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openDrink(context, drink),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredBox(
                color: shopSurface,
                child: AspectRatio(
                  aspectRatio: 1.25,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Image.asset(
                      drink.imagePath,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drink.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(price, style: const TextStyle(color: shopMuted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopularDrinks extends StatefulWidget {
  const _PopularDrinks({super.key, required this.drinks});
  final List<Drink> drinks;

  @override
  State<_PopularDrinks> createState() => _PopularDrinksState();
}

class _PopularDrinksState extends State<_PopularDrinks> {
  static const _cycleCount = 9;
  static const _middleCycle = _cycleCount ~/ 2;
  static const _colors = [
    Color(0xFFF5E0DE),
    Color(0xFFF5E8D0),
    Color(0xFFDFEAF0),
  ];
  late final _controller = PageController(
    viewportFraction: _popularViewportFraction,
    initialPage: _loops ? _middleCycle * widget.drinks.length : 0,
  );

  bool get _loops => widget.drinks.length > 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _recenterAfterScroll(ScrollEndNotification notification) {
    if (!_loops || notification.depth != 0) return false;
    final count = widget.drinks.length;
    final page = _controller.page?.round();
    if (page == null) return false;
    if (page < count * 2 || page >= count * (_cycleCount - 2)) {
      // Move to the same card in the middle, with identical neighbors.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted ||
            !_controller.hasClients ||
            _controller.position.isScrollingNotifier.value ||
            _controller.page?.round() != page) {
          return;
        }
        _controller.jumpToPage(_middleCycle * count + page % count);
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final textSize = MediaQuery.textScalerOf(context).scale(16);
    return SizedBox(
      height: 200 + (textSize - 16).clamp(0, 28).toDouble() * 6,
      child: NotificationListener<ScrollEndNotification>(
        onNotification: _recenterAfterScroll,
        child: PageView.builder(
          key: PageStorageKey('popular-${widget.drinks.length}'),
          controller: _controller,
          allowImplicitScrolling: true,
          scrollBehavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              ...ScrollConfiguration.of(context).dragDevices,
              PointerDeviceKind.mouse,
            },
          ),
          itemCount: _loops ? widget.drinks.length * _cycleCount : 1,
          itemBuilder: (context, index) {
            final drinkIndex = index % widget.drinks.length;
            final drink = widget.drinks[drinkIndex];
            final price = formatShopPrice(drink.price);
            return Semantics(
              button: true,
              label: 'Популярное: ${drink.displayName}, $price',
              onTap: () => _openDrink(context, drink),
              excludeSemantics: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _popularCardGap / 2,
                ),
                child: Material(
                  color: _colors[drinkIndex % _colors.length],
                  borderRadius: BorderRadius.circular(22),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _openDrink(context, drink),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Популярное',
                                  style: TextStyle(color: shopMuted),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Flexible(
                                  child: Text(
                                    drink.displayName,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  price,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Image.asset(
                              drink.imagePath,
                              fit: BoxFit.contain,
                              excludeFromSemantics: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
