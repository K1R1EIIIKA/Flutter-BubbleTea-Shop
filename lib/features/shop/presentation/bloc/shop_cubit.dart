import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/drink_entity.dart';
import '../../domain/usecases/get_all_drinks_usecase.dart';

part 'shop_state.dart';

class ShopCubit extends Cubit<ShopState> {
  final GetAllDrinksUseCase getAllDrinksUseCase;

  ShopCubit({required this.getAllDrinksUseCase}) : super(ShopInitial());

  Future<void> loadDrinks() async {
    emit(ShopLoading());
    try {
      final drinks = await getAllDrinksUseCase.execute();
      emit(ShopLoaded(drinks));
    } catch (e) {
      emit(ShopError(e.toString()));
    }
  }
}
