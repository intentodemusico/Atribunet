import 'package:disposebag/disposebag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:analytica/pages/reset_password/input_token/input_token_and_reset_password.dart';
import 'package:analytica/utils/delay.dart';
import 'package:analytica/utils/snackbar.dart';
import 'package:analytica/widgets/password_textfield.dart';

class InputTokenAndResetPasswordPage extends StatefulWidget {
  final VoidCallback toggle;

  const InputTokenAndResetPasswordPage({Key key, @required this.toggle})
      : super(key: key);

  @override
  _InputTokenAndResetPasswordPageState createState() =>
      _InputTokenAndResetPasswordPageState();
}

class _InputTokenAndResetPasswordPageState
    extends State<InputTokenAndResetPasswordPage>
    with SingleTickerProviderStateMixin<InputTokenAndResetPasswordPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  DisposeBag disposeBag;

  FocusNode tokenFocusNode;
  FocusNode passwordFocusNode;

  AnimationController fadeController;
  Animation<double> fadeAnim;

  @override
  void initState() {
    super.initState();

    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        curve: Curves.fastOutSlowIn,
        parent: fadeController,
      ),
    );

    tokenFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    disposeBag ??= () {
      final resetPasswordBloc =
          BlocProvider.of<InputTokenAndResetPasswordBloc>(context);
      return DisposeBag([
        resetPasswordBloc.message$.listen((message) async {
          scaffoldKey.showSnackBar(_getMessageString(message));
          await delay(1000);
          if (message is ResetPasswordSuccess) {
            Navigator.pop<String>(context, message.email);
          }
        }),
        resetPasswordBloc.isLoading$.listen((isLoading) {
          if (isLoading) {
            fadeController.forward();
          } else {
            fadeController.reverse();
          }
        }),
      ]);
    }();
  }

  @override
  void dispose() {
    fadeController.dispose();
    disposeBag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resetPasswordBloc =
        BlocProvider.of<InputTokenAndResetPasswordBloc>(context);

    final emailTextField = StreamBuilder<String>(
      stream: resetPasswordBloc.emailError$,
      builder: (context, snapshot) {
        return TextField(
          autocorrect: true,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(Icons.email),
            ),
            labelText: 'Email',
            errorText: snapshot.data,
          ),
          keyboardType: TextInputType.emailAddress,
          maxLines: 1,
          autofocus: true,
          onChanged: resetPasswordBloc.emailChanged,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(tokenFocusNode);
          },
          style: TextStyle(fontSize: 16.0),
        );
      },
    );

    final tokenTextField = StreamBuilder<String>(
      stream: resetPasswordBloc.tokenError$,
      builder: (context, snapshot) {
        return TextField(
          autocorrect: true,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(Icons.security),
            ),
            labelText: 'Token',
            errorText: snapshot.data,
          ),
          keyboardType: TextInputType.text,
          maxLines: 1,
          focusNode: tokenFocusNode,
          onChanged: resetPasswordBloc.tokenChanged,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(passwordFocusNode);
          },
          style: TextStyle(fontSize: 16.0),
        );
      },
    );

    final passwordTextField = StreamBuilder<String>(
      stream: resetPasswordBloc.passwordError$,
      builder: (context, snapshot) {
        return PasswordTextField(
          errorText: snapshot.data,
          onChanged: resetPasswordBloc.passwordChanged,
          labelText: 'Password',
          onSubmitted: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          textInputAction: TextInputAction.done,
          focusNode: passwordFocusNode,
        );
      },
    );

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Reset password'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(0xBF),
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: emailTextField,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: tokenTextField,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: passwordTextField,
                ),
                Center(
                  child: FadeTransition(
                    opacity: fadeAnim,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: RaisedButton(
                    child: Text('Submit'),
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color: Theme.of(context).cardColor,
                    splashColor: Theme.of(context).accentColor,
                    onPressed: resetPasswordBloc.submit,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: RaisedButton(
                    child: Text('Request email'),
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(context).cardColor,
                    splashColor: Theme.of(context).accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onPressed: widget.toggle,
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _getMessageString(InputTokenAndResetPasswordMessage msg) {
    if (msg is InvalidInformation) {
      return 'Invalid information. Try again';
    }
    if (msg is ResetPasswordSuccess) {
      return 'Reset password successfully';
    }
    if (msg is ResetPasswordFailure) {
      return msg.message;
    }
    return 'An unexpected error has occurred';
  }
}
