import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:image_picker/image_picker.dart';
import 'package:analytica/data/constants.dart';
import 'package:analytica/domain/models/auth_state.dart';
import 'package:analytica/domain/models/user.dart';
import 'package:analytica/pages/home/home_bloc.dart';

class HomeUserProfile extends StatelessWidget {
  const HomeUserProfile({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);

    return Card(
      color: Colors.black.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RxStreamBuilder<AuthenticationState>(
          stream: homeBloc.authState$,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final user = snapshot.data.userAndToken?.user;
            return user == null
                ? _buildUnauthenticated(context)
                : _buildProfile(user, homeBloc);
          },
        ),
      ),
    );
  }

  Widget _buildProfile(User user, HomeBloc homeBloc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        ClipOval(
          child: GestureDetector(
            child: user.imageUrl != null
                ? Image.network(
                    Uri.https(
                      baseUrl,
                      user.imageUrl,
                    ).toString(),
                    fit: BoxFit.cover,
                    width: 90.0,
                    height: 90.0,
                  )
                : Image.asset(
                    'assets/logo.png',
                    width: 90.0,
                    height: 90.0,
                  ),
            onTap: () => _pickAndUploadImage(homeBloc),
          ),
        ),
        Expanded(
          child: ListTile(
            title: Text(
              user.name,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${user.email}\n${user.createdAt}',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnauthenticated(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              strokeWidth: 2,
            ),
          ),
          Expanded(
            child: Text(
              'Loging out...',
              style: Theme.of(context).textTheme.subtitle,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _pickAndUploadImage(HomeBloc homeBloc) async {
    final imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 720.0,
      maxHeight: 720.0,
    );
    homeBloc.changeAvatar(imageFile);
  }
}
