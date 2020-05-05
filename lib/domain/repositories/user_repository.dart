import 'dart:io';

import 'package:meta/meta.dart';
import 'package:analytica/domain/models/auth_state.dart';
import 'package:analytica/utils/result.dart';

abstract class UserRepository {
  Stream<AuthenticationState> get authenticationState$;

  Future<AuthenticationState> get authenticationState;

  Stream<Result<void>> login({
    @required String email,
    @required String password,
  });

  Stream<Result<void>> registerUser({
    @required String name,
    @required String email,
    @required String password,
  });

  Stream<Result<void>> logout();

  Stream<Result<void>> uploadImage(File image);

  Stream<Result<void>> changePassword({
    @required String password,
    @required String newPassword,
  });

  Stream<Result<void>> resetPassword({
    @required String email,
    @required String token,
    @required String newPassword,
  });

  Stream<Result<void>> sendResetPasswordEmail(String email);
}
