import 'dart:async';

import 'package:disposebag/disposebag.dart';
import 'package:meta/meta.dart';
import 'package:analytica/domain/usecases/register_use_case.dart';
import 'package:analytica/my_base_bloc.dart';
import 'package:analytica/pages/register/register.dart';
import 'package:analytica/utils/result.dart';
import 'package:analytica/utils/streams.dart';
import 'package:analytica/utils/type_defs.dart';
import 'package:analytica/utils/validators.dart';
import 'package:rxdart/rxdart.dart';

// ignore_for_file: close_sinks

/// BLoC handles validating form and register
class RegisterBloc extends MyBaseBloc {
  /// Input functions
  final Function1<String, void> nameChanged;
  final Function1<String, void> emailChanged;
  final Function1<String, void> passwordChanged;
  final Function0<void> submitRegister;

  /// Streams
  final Stream<String> emailError$;
  final Stream<String> passwordError$;
  final Stream<String> nameError$;
  final Stream<RegisterMessage> message$;
  final Stream<bool> isLoading$;

  RegisterBloc._({
    @required Function0<void> dispose,
    @required this.emailChanged,
    @required this.passwordChanged,
    @required this.submitRegister,
    @required this.emailError$,
    @required this.passwordError$,
    @required this.message$,
    @required this.isLoading$,
    @required this.nameChanged,
    @required this.nameError$,
  }) : super(dispose);

  factory RegisterBloc(final RegisterUseCase registerUser) {
    assert(registerUser != null);

    /// Controllers
    final emailController = PublishSubject<String>();
    final nameController = PublishSubject<String>();
    final passwordController = PublishSubject<String>();
    final submitRegisterController = PublishSubject<void>();
    final isLoadingController = BehaviorSubject<bool>.seeded(false);
    final controllers = [
      emailController,
      nameController,
      passwordController,
      submitRegisterController,
      isLoadingController,
    ];

    ///
    /// Streams
    ///

    final isValidSubmit$ = Rx.combineLatest4(
      emailController.stream.map(Validator.isValidEmail),
      passwordController.stream.map(Validator.isValidPassword),
      isLoadingController.stream,
      nameController.stream.map(Validator.isValidUserName),
      (isValidEmail, isValidPassword, isLoading, isValidName) {
        return isValidEmail && isValidPassword && !isLoading && isValidName;
      },
    ).shareValueSeeded(false);

    final registerUser$ = Rx.combineLatest3(
      emailController.stream,
      passwordController.stream,
      nameController.stream,
      (email, password, name) => RegisterUser(email, name, password),
    );

    final submit$ = submitRegisterController.stream
        .withLatestFrom(isValidSubmit$, (_, bool isValid) => isValid)
        .share();

    final message$ = Rx.merge([
      submit$
          .where((isValid) => isValid)
          .withLatestFrom(registerUser$, (_, RegisterUser user) => user)
          .exhaustMap(
            (user) => registerUser(
              email: user.email,
              password: user.password,
              name: user.name,
            )
                .doOnListen(() => isLoadingController.add(true))
                .doOnData((_) => isLoadingController.add(false))
                .map((result) => _responseToMessage(result, user.email)),
          ),
      submit$
          .where((isValid) => !isValid)
          .map((_) => const RegisterInvalidInformationMessage())
    ]).share();

    final emailError$ = emailController.stream
        .map((email) {
          if (Validator.isValidEmail(email)) return null;
          return 'Correo inválido';
        })
        .distinct()
        .share();

    final passwordError$ = passwordController.stream
        .map((password) {
          if (Validator.isValidPassword(password)) return null;
          return 'Contraseña debe tener al menos 6 caracteres';
        })
        .distinct()
        .share();

    final nameError$ = nameController.stream
        .map((name) {
          if (Validator.isValidUserName(name)) return null;
          return 'Nombre debe tener al menos 3 caracteres';
        })
        .distinct()
        .share();

    final subscriptions = <String, Stream>{
      'emailError': emailError$,
      'passwordError': passwordError$,
      'nameError': nameError$,
      'isValidSubmit': isValidSubmit$,
      'message': message$,
      'isLoading': isLoadingController,
    }.debug();

    return RegisterBloc._(
      dispose: DisposeBag([...subscriptions, ...controllers]).dispose,
      nameChanged: trim.pipe(nameController.add),
      emailChanged: trim.pipe(emailController.add),
      passwordChanged: passwordController.add,
      submitRegister: () => submitRegisterController.add(null),
      emailError$: emailError$,
      passwordError$: passwordError$,
      message$: message$,
      isLoading$: isLoadingController,
      nameError$: nameError$,
    );
  }

  static RegisterMessage _responseToMessage(Result result, String email) {
    if (result is Success) {
      return RegisterSuccessMessage(email);
    }
    if (result is Failure) {
      return RegisterErrorMessage(result.message, result.error);
    }
    return RegisterErrorMessage('Resultado desconocido $result');
  }
}
