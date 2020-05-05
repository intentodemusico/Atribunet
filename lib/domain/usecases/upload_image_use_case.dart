import 'dart:io';

import 'package:analytica/domain/repositories/user_repository.dart';
import 'package:analytica/utils/result.dart';

class UploadImageUseCase {
  final UserRepository _userRepository;

  const UploadImageUseCase(this._userRepository);

  Stream<Result<void>> call(File image) => _userRepository.uploadImage(image);
}
