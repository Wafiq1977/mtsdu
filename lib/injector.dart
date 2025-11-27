import 'package:get_it/get_it.dart';
import 'data/repository/user_repository_impl.dart';
import 'domain/repository/user_repository.dart';
import 'domain/usecase/login_usecase.dart';
import 'presentation/bloc/auth_cubit.dart';

final injector = GetIt.instance;

void setupInjector() {
  // Repositories
  injector.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(),
  );

  // Use Cases
  injector.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(injector<UserRepository>()),
  );

  // BLoCs
  injector.registerFactory<AuthCubit>(
    () => AuthCubit(injector<LoginUseCase>()),
  );
}
