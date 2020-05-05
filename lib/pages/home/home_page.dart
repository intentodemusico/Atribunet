import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:node_auth/domain/usecases/change_password_use_case.dart';
import 'package:node_auth/pages/home/change_password/change_password.dart';
import 'package:node_auth/pages/home/home.dart';
import 'package:node_auth/pages/home/home_profile_widget.dart';
import 'package:node_auth/pages/login/login.dart';
import 'package:node_auth/utils/delay.dart';
import 'package:node_auth/utils/snackbar.dart';
import 'package:node_auth/pages/graph/sparkline.dart';

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
    final logoSize = MediaQuery.of(context).size.width / 2;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Home'),
      ),
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/konan.png'),
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
                onPressed: showChangePassword,
                label: Text('Change password'),
                icon: Icon(Icons.lock_outline),
                color: Theme.of(context).backgroundColor,
                colorBrightness: Brightness.dark,
                splashColor: Colors.white.withOpacity(0.5),
              ),
            ),
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
                label: Text('Data'),
                icon: Icon(Icons.graphic_eq),
                color: Theme.of(context).backgroundColor,
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
                label: Text('Logout'),
                icon: Icon(Icons.exit_to_app),
                color: Theme.of(context).backgroundColor,
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
        scaffoldKey.showSnackBar('Logout successfully!');
        await delay(1000);
        await Navigator.of(context).pushNamedAndRemoveUntil(
          LoginPage.routeName,
          (_) => false,
        );
      }
      if (message is LogoutErrorMessage) {
        scaffoldKey.showSnackBar('Error when logout: ${message.message}');
      }
    }
    if (message is UpdateAvatarMessage) {
      if (message is UpdateAvatarSuccessMessage) {
        scaffoldKey.showSnackBar('Upload image successfully!');
      }
      if (message is UpdateAvatarErrorMessage) {
        scaffoldKey.showSnackBar('Error when upload image: ${message.message}');
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
