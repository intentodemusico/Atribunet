import 'package:node_auth/domain/models/auth_state.dart';
import 'package:node_auth/domain/repositories/user_repository.dart';

class GetAuthStateUseCase {
  final UserRepository _userRepository;

  const GetAuthStateUseCase(this._userRepository);

  Future<AuthenticationState> call() => _userRepository.authenticationState;
}
