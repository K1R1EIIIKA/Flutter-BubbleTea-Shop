import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/drink_entity.dart';
import '../../domain/usecases/get_all_drinks_usecase.dart';

part 'shop_state.dart';

class ShopCubit extends Cubit<ShopState> {
  final GetAllDrinksUseCase getAllDrinksUseCase;
  final Future<void> Function()? refreshCatalog;
  StreamSubscription<void>? _catalogUpdates;
  int _request = 0;

  ShopCubit({
    required this.getAllDrinksUseCase,
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
      final drinks = await getAllDrinksUseCase.execute();
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
