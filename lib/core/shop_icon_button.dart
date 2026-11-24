import 'package:flutter/material.dart';

class ShopIconButton extends StatelessWidget {
  const ShopIconButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    excludeFromSemantics: true,
    child: IconButton(
      icon: Semantics(label: label, child: icon),
      onPressed: onPressed,
    ),
  );
}

class ShopBackButton extends StatelessWidget {
  const ShopBackButton({super.key});

  @override
  Widget build(BuildContext context) => ShopIconButton(
    label: MaterialLocalizations.of(context).backButtonTooltip,
    icon: const BackButtonIcon(),
    onPressed: () => Navigator.maybePop(context),
  );
}
