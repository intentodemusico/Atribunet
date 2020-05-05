import 'package:analytica/domain/repositories/user_repository.dart';
import 'package:analytica/utils/result.dart';
import 'package:meta/meta.dart';

class ResetPasswordUseCase {
  final UserRepository _userRepository;

  const ResetPasswordUseCase(this._userRepository);

  Stream<Result<void>> call({
    @required String email,
    @required String token,
    @required String newPassword,
  }) =>
      _userRepository.resetPassword(
        email: email,
        token: token,
        newPassword: newPassword,
      );
}
