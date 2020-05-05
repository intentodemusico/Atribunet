import 'dart:convert';

import 'package:analytica/data/exception/local_data_source_exception.dart';
import 'package:analytica/data/local/entities/user_and_token_entity.dart';
import 'package:analytica/data/local/local_data_source.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:rxdart/rxdart.dart';

class SharedPrefUtil implements LocalDataSource {
  static const _kUserTokenKey = 'com.hoc.analytica_flutter.user_and_token';
  final RxSharedPreferences _rxPrefs;

  @override
  final Stream<UserAndTokenEntity> userAndToken$;

  SharedPrefUtil(this._rxPrefs)
      : userAndToken$ = _rxPrefs
            .getStringStream(_kUserTokenKey)
            .map(_toEntity)
            .onErrorReturn(null);

  @override
  Future<void> removeUserAndToken() async {
    bool result;
    try {
      result = await _rxPrefs.remove(_kUserTokenKey);
    } catch (e) {
      throw LocalDataSourceException('Cannot delete user and token', e);
    }

    if (!result) {
      throw LocalDataSourceException('Cannot delete user and token');
    }
  }

  @override
  Future<void> saveUserAndToken(UserAndTokenEntity userAndToken) async {
    bool result;
    try {
      result =
          await _rxPrefs.setString(_kUserTokenKey, json.encode(userAndToken));
      print('Saved $userAndToken');
    } catch (e) {
      throw LocalDataSourceException('Cannot save user and token', e);
    }
    if (!result) {
      throw LocalDataSourceException('Cannot save user and token');
    }
  }

  @override
  Future<UserAndTokenEntity> get userAndToken => _rxPrefs
      .getString(_kUserTokenKey)
      .then(_toEntity)
      .catchError((_) => null);

  static UserAndTokenEntity _toEntity(String jsonString) => jsonString == null
      ? null
      : UserAndTokenEntity.fromJson(json.decode(jsonString));
}
