import 'package:meta/meta.dart';
import 'package:node_auth/domain/repositories/user_repository.dart';
import 'package:node_auth/utils/result.dart';

class LoginUseCase {
  final UserRepository _userRepository;

  const LoginUseCase(this._userRepository);

  Stream<Result<void>> call({
    @required String email,
    @required String password,
  }) =>
      _userRepository.login(email: email, password: password);
}
