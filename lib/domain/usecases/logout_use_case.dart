import 'package:analytica/domain/repositories/user_repository.dart';
import 'package:analytica/utils/result.dart';

class LogoutUseCase {
  final UserRepository _userRepository;

  const LogoutUseCase(this._userRepository);

  Stream<Result<void>> call() => _userRepository.logout();
}
