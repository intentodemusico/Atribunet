import 'package:analytica/data/local/entities/user_and_token_entity.dart';

abstract class LocalDataSource {
  Stream<UserAndTokenEntity> get userAndToken$;

  Future<UserAndTokenEntity> get userAndToken;

  Future<void> saveUserAndToken(UserAndTokenEntity userAndToken);

  Future<void> removeUserAndToken();
}
