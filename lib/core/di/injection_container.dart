import 'package:get_it/get_it.dart';
import 'package:labs/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:labs/features/auth/data/datasources/auth_local_data_source_impl.dart';
import 'package:labs/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:labs/features/auth/domain/repositories/auth_repository.dart';
import 'package:labs/features/auth/domain/usecases/login_usecase.dart';
import 'package:labs/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:labs/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:labs/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:labs/features/cart/data/datasources/cart_local_data_source_impl.dart';
import 'package:labs/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:labs/features/cart/domain/repositories/cart_repository.dart';
import 'package:labs/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:labs/features/cart/domain/usecases/get_cart_items_usecase.dart';
import 'package:labs/features/cart/domain/usecases/get_total_price_usecase.dart';
import 'package:labs/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:labs/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:labs/features/shop/data/datasources/drink_local_data_source.dart';
import 'package:labs/features/shop/data/repositories/drink_repository_impl.dart';
import 'package:labs/features/shop/domain/repositories/drink_repository.dart';
import 'package:labs/features/shop/domain/usecases/get_all_drinks_usecase.dart';
import 'package:labs/features/shop/presentation/bloc/shop_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  /// === External / Библиотеки ===
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Для примера: если вы в других фичах используете rootBundle, то ничего регистрировать не нужно

  /// === DataSource для напитков ===
  sl.registerLazySingleton<DrinkLocalDataSource>(
    () => DrinkLocalDataSourceImpl(assetPath: 'assets/data/drinks.json'),
  );

  /// === Репозиторий напитков ===
  sl.registerLazySingleton<DrinkRepository>(
    () => DrinkRepositoryImpl(localDataSource: sl()),
  );

  /// === DataSource (локальный) для корзины ===
  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(sharedPreferences: sl()),
  );

  /// === Репозиторий корзины ===
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(
      localDataSource: sl(),
      drinkRepository: sl(), // <-- уже зарегистрирован выше
    ),
  );

  /// === Use Cases для корзины ===
  sl.registerLazySingleton<GetCartItemsUseCase>(
    () => GetCartItemsUseCase(sl()),
  );
  sl.registerLazySingleton<AddToCartUseCase>(() => AddToCartUseCase(sl()));
  sl.registerLazySingleton<RemoveFromCartUseCase>(
    () => RemoveFromCartUseCase(sl()),
  );
  sl.registerLazySingleton<GetTotalPriceUseCase>(
    () => GetTotalPriceUseCase(sl()),
  );

  sl.registerLazySingleton<GetAllDrinksUseCase>(
        () => GetAllDrinksUseCase(sl()),
  );
  sl.registerFactory<ShopCubit>(
        () => ShopCubit(getAllDrinksUseCase: sl()),
  );

  /// === Cubit (Presentation) для корзины ===
  sl.registerFactory<CartCubit>(
    () => CartCubit(
    ),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<LoginUseCase>(
        () => LoginUseCase(sl()),
  );
// и остальные use-cases
  sl.registerLazySingleton<RegisterUseCase>(
        () => RegisterUseCase(sl()),
  );
  sl.registerLazySingleton<LogoutUseCase>(
        () => LogoutUseCase(sl()),
  );
  sl.registerLazySingleton<IsLoggedInUseCase>(
        () => IsLoggedInUseCase(sl()),
  );
  sl.registerLazySingleton<GetCurrentUserUseCase>(
        () => GetCurrentUserUseCase(sl()),
  );
  sl.registerLazySingleton<SignInWithGoogleUseCase>(
        () => SignInWithGoogleUseCase(sl()),
  );

  sl.registerFactory<AuthCubit>(
        () => AuthCubit(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      isLoggedInUseCase: sl(),
      getCurrentUserUseCase: sl(),
      signInWithGoogleUseCase: sl()
    ),
  );

  // … здесь можете регистрировать другие фичи (AuthCubit, ShopCubit, SettingsCubit и т.д.)
}
