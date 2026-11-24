import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/shop_icon_button.dart';
import '../../../../core/shop_theme.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../domain/entities/drink_entity.dart';
import '../bloc/shop_cubit.dart';
import 'drink_detail_page.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  DrinkCategory? _category;

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
              ShopLoaded() => const Center(
                child: Text('В меню пока нет напитков.'),
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
                        onPressed: context.read<ShopCubit>().loadDrinks,
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

  Widget _menu(
    BuildContext context,
    List<DrinkEntity> drinks,
    String greeting,
  ) {
    final popular = drinks.where((drink) => drink.popular).toList();
    final categories = DrinkCategory.values.where(
      (category) => drinks.any((drink) => drink.category == category),
    );
    final visible = drinks
        .where((drink) => _category == null || drink.category == _category)
        .toList();
    return ListView(
      key: const PageStorageKey('menu'),
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
        if (popular.isNotEmpty) ...[
          const SizedBox(height: 14),
          _PopularDrinks(drinks: popular),
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
          ],
        ),
        const SizedBox(height: 8),
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
    );
  }

  Widget _filter(String label, DrinkCategory? category) => ChoiceChip(
    label: Text(label),
    selected: _category == category,
    selectedColor: shopSurface,
    onSelected: (_) => setState(() => _category = category),
  );
}

void _openDrink(BuildContext context, DrinkEntity drink) =>
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => DrinkDetailPage(drink: drink)),
    );

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({super.key, required this.drink});
  final DrinkEntity drink;

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
  const _PopularDrinks({required this.drinks});
  final List<DrinkEntity> drinks;

  @override
  State<_PopularDrinks> createState() => _PopularDrinksState();
}

class _PopularDrinksState extends State<_PopularDrinks> {
  final _controller = PageController();
  int _page = 0;
  static const _colors = [
    Color(0xFFF5E0DE),
    Color(0xFFF5E8D0),
    Color(0xFFDFEAF0),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) => _controller.animateToPage(
    page,
    duration: const Duration(milliseconds: 280),
    curve: Curves.easeOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    final textSize = MediaQuery.textScalerOf(context).scale(16);
    return Column(
      children: [
        SizedBox(
          height: 200 + (textSize - 16).clamp(0, 28).toDouble() * 6,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.drinks.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) {
              final drink = widget.drinks[index];
              final price = formatShopPrice(drink.price);
              return Semantics(
                button: true,
                label: 'Популярное: ${drink.displayName}, $price',
                onTap: () => _openDrink(context, drink),
                excludeSemantics: true,
                child: Material(
                  color: _colors[index % _colors.length],
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
              );
            },
          ),
        ),
        if (widget.drinks.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShopIconButton(
                label: 'Предыдущий популярный напиток',
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _goTo((_page - 1) % widget.drinks.length),
              ),
              Semantics(
                label: 'Слайд ${_page + 1} из ${widget.drinks.length}',
                excludeSemantics: true,
                child: Text('${_page + 1} / ${widget.drinks.length}'),
              ),
              ShopIconButton(
                label: 'Следующий популярный напиток',
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _goTo((_page + 1) % widget.drinks.length),
              ),
            ],
          ),
      ],
    );
  }
}
