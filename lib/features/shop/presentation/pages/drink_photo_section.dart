import 'dart:typed_data';

import 'package:flutter/material.dart';

class DrinkPhotoSection extends StatefulWidget {
  const DrinkPhotoSection({
    super.key,
    required this.name,
    required this.readPhoto,
    required this.onPick,
    required this.onRemove,
  });

  final String? name;
  final Future<Uint8List> Function(String) readPhoto;
  final VoidCallback? onPick;
  final VoidCallback? onRemove;

  @override
  State<DrinkPhotoSection> createState() => _DrinkPhotoSectionState();
}

class _DrinkPhotoSectionState extends State<DrinkPhotoSection> {
  Future<Uint8List>? _photo;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant DrinkPhotoSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.name != oldWidget.name) _load();
  }

  void _load() {
    final name = widget.name;
    _photo = name == null ? null : widget.readPhoto(name);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Моё фото', style: Theme.of(context).textTheme.titleMedium),
        if (_photo case final photo?)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: FutureBuilder(
              key: ValueKey(widget.name),
              future: photo,
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Text('Фото недоступно.');
                final bytes = snapshot.data;
                if (bytes == null) return const LinearProgressIndicator();
                return Image.memory(
                  bytes,
                  height: 200,
                  fit: BoxFit.contain,
                  cacheWidth: 800,
                  semanticLabel: 'Личное фото напитка',
                  errorBuilder: (_, _, _) => const Text('Фото недоступно.'),
                );
              },
            ),
          ),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: widget.onPick,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                widget.name == null ? 'Добавить фото' : 'Заменить фото',
              ),
            ),
            if (widget.name != null)
              TextButton(
                onPressed: widget.onRemove,
                child: const Text('Удалить фото'),
              ),
          ],
        ),
      ],
    );
  }
}
