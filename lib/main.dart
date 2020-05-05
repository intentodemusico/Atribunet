import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:analytica/app.dart';
import 'package:analytica/data/local/local_data_source.dart';
import 'package:analytica/data/local/shared_pref_util.dart';
import 'package:analytica/data/remote/api_service.dart';
import 'package:analytica/data/remote/remote_data_source.dart';
import 'package:analytica/data/user_repository_imp.dart';
import 'package:analytica/domain/repositories/user_repository.dart';
import 'package:analytica/domain/usecases/change_password_use_case.dart';
import 'package:analytica/domain/usecases/get_auth_state_stream_use_case.dart';
import 'package:analytica/domain/usecases/get_auth_state_use_case.dart';
import 'package:analytica/domain/usecases/login_use_case.dart';
import 'package:analytica/domain/usecases/logout_use_case.dart';
import 'package:analytica/domain/usecases/register_use_case.dart';
import 'package:analytica/domain/usecases/reset_password_use_case.dart';
import 'package:analytica/domain/usecases/send_reset_password_email_use_case.dart';
import 'package:analytica/domain/usecases/upload_image_use_case.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // construct RemoteDataSource
  const RemoteDataSource remoteDataSource = ApiService();

  // construct LocalDataSource
  final rxPrefs = RxSharedPreferences.getInstance();
  final LocalDataSource localDataSource = SharedPrefUtil(rxPrefs);

  // construct UserRepository
  final UserRepository userRepository = UserRepositoryImpl(
    remoteDataSource,
    localDataSource,
  );

  runApp(
    Providers(
      providers: [
        Provider<LoginUseCase>(value: LoginUseCase(userRepository)),
        Provider<RegisterUseCase>(value: RegisterUseCase(userRepository)),
        Provider<LogoutUseCase>(value: LogoutUseCase(userRepository)),
        Provider<GetAuthStateStreamUseCase>(
          value: GetAuthStateStreamUseCase(userRepository),
        ),
        Provider<GetAuthStateUseCase>(
          value: GetAuthStateUseCase(userRepository),
        ),
        Provider<UploadImageUseCase>(
          value: UploadImageUseCase(userRepository),
        ),
        Provider<ChangePasswordUseCase>(
          value: ChangePasswordUseCase(userRepository),
        ),
        Provider<SendResetPasswordEmailUseCase>(
          value: SendResetPasswordEmailUseCase(userRepository),
        ),
        Provider<ResetPasswordUseCase>(
          value: ResetPasswordUseCase(userRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
