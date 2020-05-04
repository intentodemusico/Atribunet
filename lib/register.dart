import 'package:flutter/material.dart';
import 'package:node_auth/api_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  String _email, _password, _name;
  static const String emailRegExpString =
      r'[a-zA-Z0-9\+\.\_\%\-\+]{1,256}\@[a-zA-Z0-9][a-zA-Z0-9\-]{0,64}(\.[a-zA-Z0-9][a-zA-Z0-9\-]{0,25})+';
  static final RegExp emailRegExp =
       RegExp(emailRegExpString, caseSensitive: false);
  bool _obscurePassword = true;
  final _formKey =  GlobalKey<FormState>();
  final _scaffoldKey =  GlobalKey<ScaffoldState>();

  AnimationController _loginButtonController;
  Animation<double> _buttonSqueezeAnimation;

  ApiService apiService;

  @override
  void initState() {
    super.initState();
    _loginButtonController =  AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    _buttonSqueezeAnimation =  Tween(
      begin: 320.0,
      end: 70.0,
    ).animate( CurvedAnimation(
        parent: _loginButtonController, curve:  Interval(0.0, 0.250)))
      ..addListener(() {
        debugPrint(_buttonSqueezeAnimation.value.toString());
        setState(() {});
      });
    apiService =  ApiService();
  }


  @override
  void dispose() {
    assert(() {
      var _ticker;
      if (_ticker == null || !_ticker.isActive) {
        return true;
      }
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('$this was disposed with an active Ticker.'),
        ErrorDescription(
            '$runtimeType created a Ticker via its SingleTickerProviderStateMixin, but at the time '
                'dispose() was called on the mixin, that Ticker was still active. The Ticker must '
                'be disposed before calling super.dispose().'
        ),
        ErrorHint(
            'Tickers used by AnimationControllers '
                'should be disposed by calling dispose() on the AnimationController itself. '
                'Otherwise, the ticker will leak.'
        ),
        _ticker.describeForError('The offending ticker was')
      ]);
    }());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emailTextField =  TextFormField(
      autocorrect: true,
      autovalidate: true,
      decoration:  InputDecoration(
        prefixIcon:  Padding(
          padding: const EdgeInsetsDirectional.only(end: 8.0),
          child:  Icon(Icons.email),
        ),
        labelText: 'Email',
      ),
      keyboardType: TextInputType.emailAddress,
      maxLines: 1,
      style:  TextStyle(fontSize: 16.0),
      onSaved: (s) => _email = s,
      validator: (s) =>
          emailRegExp.hasMatch(s) ? null : 'Invalid email address!',
    );

    final passwordTextField =  TextFormField(
      autocorrect: true,
      autovalidate: true,
      obscureText: _obscurePassword,
      decoration:  InputDecoration(
        suffixIcon:  IconButton(
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          icon:  Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility),
          iconSize: 18.0,
        ),
        labelText: 'Password',
        prefixIcon:  Padding(
          padding: const EdgeInsetsDirectional.only(end: 8.0),
          child:  Icon(Icons.lock),
        ),
      ),
      keyboardType: TextInputType.text,
      maxLines: 1,
      style:  TextStyle(fontSize: 16.0),
      onSaved: (s) => _password = s,
      validator: (s) => s.length < 6 ? 'Minimum length of password is 6' : null,
    );

    final registerButton =  Container(
      width: _buttonSqueezeAnimation.value,
      height: 60.0,
      child:  Material(
        elevation: 5.0,
        shadowColor: Theme.of(context).accentColor,
        borderRadius:  BorderRadius.circular(24.0),
        child: _buttonSqueezeAnimation.value > 75.0
            ?  MaterialButton(
                onPressed: _register,
                color: Theme.of(context).backgroundColor,
                child:  Text(
                  'REGISTER',
                  style:  TextStyle(color: Colors.white, fontSize: 16.0),
                ),
                splashColor:  Color(0xFF00e676),
              )
            :  Container(
                padding:
                     EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                child:  CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor:  AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
      ),
    );

    final nameTextField =  TextFormField(
      autocorrect: true,
      autovalidate: true,
      decoration:  InputDecoration(
        labelText: 'Name',
        prefixIcon:  Padding(
          padding: const EdgeInsetsDirectional.only(end: 8.0),
          child:  Icon(Icons.person),
        ),
      ),
      keyboardType: TextInputType.text,
      maxLines: 1,
      style:  TextStyle(fontSize: 16.0),
      onSaved: (s) => _name = s,
    );

    return  Scaffold(
      key: _scaffoldKey,
      body:  Container(
        decoration:  BoxDecoration(
            image:  DecorationImage(
                image:  AssetImage('assets/bg.jpg'),
                fit: BoxFit.cover,
                colorFilter:  ColorFilter.mode(
                    Colors.black.withAlpha(0xBF), BlendMode.darken))),
        child:  Stack(
          children: <Widget>[
             Center(
              child:  Form(
                key: _formKey,
                autovalidate: true,
                child:  Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                     Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: nameTextField,
                    ),
                     Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: emailTextField,
                    ),
                     Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: passwordTextField,
                    ),
                     SizedBox(height: 32.0),
                      Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: registerButton,
                    ),
                  ],
                ),
              ),
            ),
            _getToolbar(context)
          ],
        ),
      ),
    );
  }

  _getToolbar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: BackButton(color: Colors.white),
    
    );
  }

  void _register() {
    if (!_formKey.currentState.validate()) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(content:  Text('Invalid information')),
      );
      return;
    }

    _formKey.currentState.save();
    _loginButtonController.reset();
    _loginButtonController.forward();

    debugPrint('$_name $_email $_password');

    apiService.registerUser(_name, _email, _password).then((Response response) {
      _loginButtonController.reverse();
      _scaffoldKey.currentState
          .showSnackBar(
             SnackBar(content:  Text(response.message)),
          )
          .closed
          .then((_) => Navigator.of(context).pop());
    }).catchError((error) {
      _loginButtonController.reverse();
      final message =
          error is MyHttpException ? error.message : 'Unknown error occurred';
      _scaffoldKey.currentState.showSnackBar(
         SnackBar(content:  Text(message)),
      );
    });
  }
}
