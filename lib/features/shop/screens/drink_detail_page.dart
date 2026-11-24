import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/shop_icon_button.dart';
import '../../../core/shop_theme.dart';
import '../../cart/cart_item.dart';
import '../../cart/cart_cubit.dart';
import '../drink.dart';
import '../drink_options.dart';
import '../drink_notes_cubit.dart';
import '../shop_cubit.dart';
import 'drink_photo_section.dart';

class DrinkDetailPage extends StatefulWidget {
  const DrinkDetailPage({super.key, required this.drink}) : original = null;
  DrinkDetailPage.edit({super.key, required CartItem item})
    : drink = item.drink,
      original = item;

  final Drink drink;
  final CartItem? original;

  @override
  State<DrinkDetailPage> createState() => _DrinkDetailPageState();
}

class _DrinkDetailPageState extends State<DrinkDetailPage> {
  bool _saving = false;
  bool _updatingNote = false;
  String? _status;
  late Drink _drink = widget.drink;
  late DrinkSize _size = widget.original?.options.size ?? DrinkSize.standard;
  late DrinkIce _ice = widget.original?.options.ice ?? DrinkIce.regular;
  late DrinkSweetness _sweetness =
      widget.original?.options.sweetness ?? DrinkSweetness.regular;
  late DrinkTopping _topping =
      widget.original?.options.topping ?? DrinkTopping.none;

  DrinkOptions get _options => DrinkOptions(
    size: _size,
    ice: _ice,
    sweetness: _sweetness,
    topping: _topping,
  );

  void _select(VoidCallback change) => setState(() {
    change();
    _status = null;
  });

  Future<void> _chooseDrink(List<Drink> drinks) async {
    final selected = await showModalBottomSheet<Drink>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: shopBackground,
      constraints: const BoxConstraints(maxWidth: 480),
      builder: (context) => SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.72,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Semantics(
                  header: true,
                  child: Text(
                    'Выберите напиток',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  shrinkWrap: true,
                  itemCount: drinks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final drink = drinks[index];
                    final current = drink.name == _drink.name;
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      selected: current,
                      selectedTileColor: shopSurface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      minVerticalPadding: 8,
                      leading: Container(
                        width: 46,
                        height: 46,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: shopBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: shopDivider),
                        ),
                        child: Image.asset(
                          drink.imagePath,
                          fit: BoxFit.contain,
                          excludeFromSemantics: true,
                        ),
                      ),
                      title: Text(
                        drink.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(formatShopPrice(drink.price)),
                      trailing: current
                          ? const Icon(Icons.check_circle_outline)
                          : null,
                      onTap: () => Navigator.pop(context, drink),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null && mounted) _select(() => _drink = selected);
  }

  Future<void> _saveDrink() async {
    setState(() {
      _saving = true;
      _status = null;
    });
    final cart = context.read<CartCubit>();
    final original = widget.original;
    final added = original == null
        ? await cart.addDrink(_drink, options: _options)
        : await cart.updateDrink(original, _drink, _options);
    if (!mounted) return;
    if (added && original != null) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _saving = false;
      _status = added
          ? 'Добавлено в корзину'
          : 'Не удалось сохранить напиток. Повторите попытку.';
    });
  }

  Future<void> _updateNote(
    Future<void> Function() change,
    String errorMessage,
  ) async {
    setState(() => _updatingNote = true);
    try {
      await change();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      if (mounted) setState(() => _updatingNote = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final drink = _drink;
    final editing = widget.original != null;
    final notes = editing ? null : context.watch<DrinkNotesCubit?>();
    final note = notes?.state.ready == true
        ? notes!.state.forDrink(drink.name)
        : null;
    final catalog = editing ? context.watch<ShopCubit>().state : null;
    final cartState = context.watch<CartCubit>().state;
    final theme = Theme.of(context);
    final price = formatShopPrice(drink.price + _options.extra);
    final imageHeight = (MediaQuery.sizeOf(context).height * 0.32)
        .clamp(148.0, 272.0)
        .toDouble();
    return Scaffold(
      appBar: AppBar(
        leading: const ShopBackButton(),
        title: editing ? const Text('Изменить напиток') : null,
        scrolledUnderElevation: 0,
        actions: [
          if (note != null)
            ShopIconButton(
              label: note.favorite ? 'Убрать из избранного' : 'В избранное',
              icon: Icon(
                note.favorite ? Icons.favorite : Icons.favorite_border,
              ),
              onPressed: _updatingNote
                  ? null
                  : () => _updateNote(
                      () => notes!.setFavorite(drink.name, !note.favorite),
                      'Не удалось сохранить избранное.',
                    ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
              children: [
                Image.asset(
                  drink.imagePath,
                  height: imageHeight,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
                const SizedBox(height: 16),
                Text(
                  drink.displayName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  drink.displayDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: shopMuted,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (catalog is ShopLoaded && catalog.drinks.length > 1) ...[
                  OutlinedButton(
                    onPressed: _saving
                        ? null
                        : () => _chooseDrink(catalog.drinks),
                    child: const Text('Выбрать другой напиток'),
                  ),
                  const SizedBox(height: 16),
                ],
                _OptionGroup(
                  title: 'Объём',
                  segmented: true,
                  choices: [
                    for (final size in DrinkSize.values)
                      _chip(
                        _priceLabel(size.label, size.extra),
                        _size == size,
                        () => _size = size,
                        segment: true,
                      ),
                  ],
                ),
                _OptionGroup(
                  title: 'Лёд',
                  choices: [
                    for (final ice in DrinkIce.values)
                      _chip(ice.label, _ice == ice, () => _ice = ice),
                  ],
                ),
                _OptionGroup(
                  title: 'Сладость',
                  choices: [
                    for (final sweetness in DrinkSweetness.values)
                      _chip(
                        sweetness.label,
                        _sweetness == sweetness,
                        () => _sweetness = sweetness,
                      ),
                  ],
                ),
                _OptionGroup(
                  title: 'Добавка',
                  choices: [
                    for (final topping in DrinkTopping.values)
                      _chip(
                        _priceLabel(topping.label, topping.extra),
                        _topping == topping,
                        () => _topping = topping,
                      ),
                  ],
                ),
                if (note != null)
                  DrinkPhotoSection(
                    name: note.photoName,
                    readPhoto: notes!.readPhoto,
                    onPick: _updatingNote
                        ? null
                        : () => _updateNote(
                            () => notes.pickPhoto(drink.name),
                            'Не удалось сохранить фото. Выберите изображение до 10 МБ.',
                          ),
                    onRemove: _updatingNote
                        ? null
                        : () => _updateNote(
                            () => notes.removePhoto(drink.name),
                            'Не удалось удалить фото.',
                          ),
                  ),
                if (notes?.state.failed == true)
                  TextButton(
                    onPressed: notes!.load,
                    child: const Text('Повторить загрузку избранного и фото'),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: shopBackground,
          border: Border(top: BorderSide(color: shopDivider)),
        ),
        child: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.center,
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      label: 'Цена: $price',
                      excludeSemantics: true,
                      liveRegion: true,
                      child: Text(
                        price,
                        textAlign: TextAlign.end,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (_status case final status?)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(status, textAlign: TextAlign.center),
                        ),
                      ),
                    if (cartState is CartError)
                      OutlinedButton(
                        onPressed: context.read<CartCubit>().load,
                        child: const Text(
                          'Повторить загрузку корзины',
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      FilledButton(
                        onPressed: !_saving && cartState is CartLoaded
                            ? _saveDrink
                            : null,
                        child: Text(
                          _saving
                              ? 'Сохраняем…'
                              : editing
                              ? 'Сохранить изменения'
                              : 'В корзину',
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _priceLabel(String label, double extra) =>
      extra == 0 ? label : '$label +${formatShopPrice(extra)}';

  Widget _chip(
    String label,
    bool selected,
    VoidCallback change, {
    bool segment = false,
  }) => ChoiceChip(
    label: segment
        ? Align(
            alignment: Alignment.center,
            child: Text(label, textAlign: TextAlign.center),
          )
        : Text(label),
    selected: selected,
    showCheckmark: !segment,
    backgroundColor: segment ? shopSurface : shopBackground,
    selectedColor: segment ? Colors.white : const Color(0xFFF1E9E1),
    side: BorderSide(
      color: segment && !selected ? Colors.transparent : shopDivider,
    ),
    onSelected: _saving ? null : (_) => _select(change),
  );
}

class _OptionGroup extends StatelessWidget {
  const _OptionGroup({
    required this.title,
    required this.choices,
    this.segmented = false,
  });

  final String title;
  final List<Widget> choices;
  final bool segmented;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        const SizedBox(height: 4),
        if (segmented)
          DecoratedBox(
            decoration: BoxDecoration(
              color: shopSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  for (final choice in choices) Expanded(child: choice),
                ],
              ),
            ),
          )
        else
          Wrap(spacing: 8, runSpacing: 4, children: choices),
      ],
    ),
  );
}
