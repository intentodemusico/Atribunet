import 'package:meta/meta.dart';
import 'package:analytica/domain/repositories/user_repository.dart';
import 'package:analytica/utils/result.dart';

class RegisterUseCase {
  final UserRepository _userRepository;

  const RegisterUseCase(this._userRepository);

  Stream<Result<void>> call({
    @required String name,
    @required String email,
    @required String password,
  }) =>
      _userRepository.registerUser(
        name: name,
        email: email,
        password: password,
      );
}
