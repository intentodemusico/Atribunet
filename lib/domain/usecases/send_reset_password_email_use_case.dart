import 'package:analytica/domain/repositories/user_repository.dart';
import 'package:analytica/utils/result.dart';

class SendResetPasswordEmailUseCase {
  final UserRepository _userRepository;

  const SendResetPasswordEmailUseCase(this._userRepository);

  Stream<Result<void>> call(String email) =>
      _userRepository.sendResetPasswordEmail(email);
}
