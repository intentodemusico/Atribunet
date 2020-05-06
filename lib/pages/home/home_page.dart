import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:analytica/domain/usecases/change_password_use_case.dart';
import 'package:analytica/pages/home/change_password/change_password.dart';
import 'package:analytica/pages/home/home.dart';
import 'package:analytica/pages/home/home_profile_widget.dart';
import 'package:analytica/pages/login/login.dart';
import 'package:analytica/utils/delay.dart';
import 'package:analytica/utils/snackbar.dart';
import 'package:analytica/pages/graph/sparkline.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home_page';

  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin<HomePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController rotateLogoController;

  StreamSubscription subscription;

  @override
  void initState() {
    super.initState();

    rotateLogoController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    subscription ??=
        BlocProvider.of<HomeBloc>(context).message$.listen(handleMessage);
  }

  @override
  void dispose() {
    rotateLogoController.dispose();
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);
    //final logoSize = MediaQuery.of(context).size.width / 2;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Cuenta'),
      ),
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg_home.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(0xBF),
              BlendMode.darken,
            ),
          ),
        ),
        child: ListView(
          children: <Widget>[
            const HomeUserProfile(),
            Container(
              height: 48.0,
              margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
              width: double.infinity,
              child: RaisedButton.icon(
              onPressed: () => 
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Chart()),
                  ),
                label: Text('Graficos'),
                icon: Icon(Icons.insert_chart),
                //color: Theme.of(context).backgroundColor,
                color: Colors.orange,
                colorBrightness: Brightness.dark,
                splashColor: Colors.white.withOpacity(0.5),
              ),
            ),
            Container(
              height: 48.0,
              margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
              width: double.infinity,
              child: RaisedButton.icon(
                onPressed: showChangePassword,
                label: Text('Cambiar contraseña'),
                icon: Icon(Icons.lock_outline),
                //color: Theme.of(context).backgroundColor,
                color: Colors.blueAccent,
                colorBrightness: Brightness.dark,
                splashColor: Colors.white.withOpacity(0.5),
              ),
            ),
            Container(
              height: 48.0,
              margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
              width: double.infinity,
              child: RaisedButton.icon(
                onPressed: homeBloc.logout,
                label: Text('Cerrar sesión'),
                icon: Icon(Icons.exit_to_app),
                //color: Theme.of(context).backgroundColor,
                color: Colors.redAccent,
                colorBrightness: Brightness.dark,
                splashColor: Colors.white.withOpacity(0.5),
              ),
            )
          ],
        ),
      ),
    );
  }

  void handleMessage(HomeMessage message) async {
    print('[DEBUG] homeBloc message=$message');

    if (message is LogoutMessage) {
      if (message is LogoutSuccessMessage) {
        scaffoldKey.showSnackBar('Sesión cerrada!');
        await delay(1000);
        await Navigator.of(context).pushNamedAndRemoveUntil(
          LoginPage.routeName,
          (_) => false,
        );
      }
      if (message is LogoutErrorMessage) {
        scaffoldKey.showSnackBar('Eror de salida de sesión: ${message.message}');
      }
    }
    if (message is UpdateAvatarMessage) {
      if (message is UpdateAvatarSuccessMessage) {
        scaffoldKey.showSnackBar('Cambio foto de perfil satisfactorio!');
      }
      if (message is UpdateAvatarErrorMessage) {
        scaffoldKey.showSnackBar('Error subiendo la foto: ${message.message}');
      }
    }
  }

  void showChangePassword() {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        ),
      ),
      context: context,
      builder: (context) {
        final changePassword = Provider.of<ChangePasswordUseCase>(context);
        return BlocProvider<ChangePasswordBloc>(
          initBloc: () => ChangePasswordBloc(changePassword),
          child: const ChangePasswordBottomSheet(),
        );
      },
      backgroundColor: Theme.of(context).canvasColor,
    );
  }
}
