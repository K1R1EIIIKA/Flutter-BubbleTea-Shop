import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'drink.dart';
import 'drink_catalog.dart';

class ShopCubit extends Cubit<ShopState> {
  final DrinkCatalog catalog;
  final Future<void> Function()? refreshCatalog;
  StreamSubscription<void>? _catalogUpdates;
  int _request = 0;

  ShopCubit({
    required this.catalog,
    this.refreshCatalog,
    Stream<void>? catalogChanges,
  }) : super(ShopInitial()) {
    _catalogUpdates = catalogChanges?.listen(
      (_) => loadDrinks(showLoading: false),
      onError: (Object error, StackTrace stackTrace) =>
          addError(error, stackTrace),
    );
  }

  Future<bool> loadDrinks({bool showLoading = true}) async {
    final request = ++_request;
    if (showLoading) emit(ShopLoading());
    try {
      final drinks = await catalog.load();
      if (!isClosed && request == _request) emit(ShopLoaded(drinks));
      return true;
    } catch (e) {
      if (!isClosed && request == _request && state is! ShopLoaded) {
        emit(ShopError(e.toString()));
      }
      return false;
    }
  }

  Future<bool> refreshDrinks() async {
    try {
      await refreshCatalog?.call();
      if (isClosed) return false;
      return loadDrinks(showLoading: false);
    } catch (e) {
      if (!isClosed && state is! ShopLoaded) emit(ShopError(e.toString()));
      return false;
    }
  }

  @override
  Future<void> close() async {
    await _catalogUpdates?.cancel();
    await super.close();
  }
}

abstract class ShopState extends Equatable {
  const ShopState();

  @override
  List<Object?> get props => [];
}

class ShopInitial extends ShopState {}

class ShopLoading extends ShopState {}

class ShopLoaded extends ShopState {
  final List<Drink> drinks;
  const ShopLoaded(this.drinks);

  @override
  List<Object?> get props => [drinks];
}

class ShopError extends ShopState {
  final String message;
  const ShopError(this.message);

  @override
  List<Object?> get props => [message];
}
