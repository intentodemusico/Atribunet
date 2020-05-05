// ignore_for_file: close_sinks

import 'dart:async';

import 'package:disposebag/disposebag.dart';
import 'package:meta/meta.dart';
import 'package:analytica/domain/usecases/send_reset_password_email_use_case.dart';
import 'package:analytica/my_base_bloc.dart';
import 'package:analytica/pages/reset_password/send_email/send_email.dart';
import 'package:analytica/utils/result.dart';
import 'package:analytica/utils/type_defs.dart';
import 'package:analytica/utils/validators.dart';
import 'package:rxdart/rxdart.dart';

class SendEmailBloc extends MyBaseBloc {
  ///
  final Function0<void> submit;
  final Function1<String, void> emailChanged;

  ///
  final Stream<String> emailError$;
  final Stream<SendEmailMessage> message$;
  final Stream<bool> isLoading$;

  SendEmailBloc._({
    @required this.submit,
    @required this.emailChanged,
    @required this.emailError$,
    @required this.message$,
    @required this.isLoading$,
    @required Function0<void> dispose,
  }) : super(dispose);

  factory SendEmailBloc(
      final SendResetPasswordEmailUseCase sendResetPasswordEmail) {
    assert(sendResetPasswordEmail != null);

    final emailS = PublishSubject<String>();
    final submitS = PublishSubject<void>();
    final isLoadingS = BehaviorSubject<bool>.seeded(false);

    final emailError$ = emailS.map((email) {
      if (Validator.isValidEmail(email)) return null;
      return 'Invalid email address';
    }).share();

    final submittedEmail$ =
        submitS.withLatestFrom(emailS, (_, String email) => email).share();

    final message$ = Rx.merge([
      submittedEmail$
          .where((email) => !Validator.isValidEmail(email))
          .map((_) => const SendEmailInvalidInformationMessage()),
      submittedEmail$.where(Validator.isValidEmail).exhaustMap(
        (email) {
          return send(
            email,
            sendResetPasswordEmail,
            isLoadingS,
          );
        },
      ),
    ]).share();

    return SendEmailBloc._(
      dispose: DisposeBag([emailS, submitS, isLoadingS]).dispose,
      emailChanged: trim.pipe(emailS.add),
      emailError$: emailError$,
      submit: () => submitS.add(null),
      message$: message$,
      isLoading$: isLoadingS,
    );
  }

  static Stream<SendEmailMessage> send(
    String email,
    SendResetPasswordEmailUseCase sendResetPasswordEmail,
    Sink<bool> isLoadingController,
  ) {
    SendEmailMessage _resultToMessage(result) {
      if (result is Success) {
        return const SendEmailSuccessMessage();
      }
      if (result is Failure) {
        return SendEmailErrorMessage(result.message, result.error);
      }
      return SendEmailErrorMessage('An error occurred!');
    }

    return sendResetPasswordEmail(email)
        .doOnListen(() => isLoadingController.add(true))
        .doOnData((_) => isLoadingController.add(false))
        .map(_resultToMessage);
  }
}
