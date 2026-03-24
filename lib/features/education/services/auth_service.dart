import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/services/secure_storage_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/education/models/user_data.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

import 'login_service.dart';

class AuthService {
  static Future<void> migrateCredentials() async {
    final prefs = PrefsService.instance;
    final secureStorage = SecureStorageService.instance;

    final username = prefs.getString(PrefsKeys.USERNAME);
    final password = prefs.getString(PrefsKeys.PASSWORD);

    if (username != null && username.isNotEmpty) {
      await secureStorage.write(key: PrefsKeys.USERNAME, value: username);
      await prefs.remove(PrefsKeys.USERNAME);
    }

    if (password != null && password.isNotEmpty) {
      await secureStorage.write(key: PrefsKeys.PASSWORD, value: password);
      await prefs.remove(PrefsKeys.PASSWORD);
    }

    final clubName = prefs.getString(PrefsKeys.CLUB_NAME);
    final clubId = prefs.getString(PrefsKeys.CLUB_ID);
    final memberJwt = prefs.getString(PrefsKeys.MEMBER_JWT);

    if (clubName != null && clubName.isNotEmpty) {
      await secureStorage.write(key: PrefsKeys.CLUB_NAME, value: clubName);
      await prefs.remove(PrefsKeys.CLUB_NAME);
    }

    if (clubId != null && clubId.isNotEmpty) {
      await secureStorage.write(key: PrefsKeys.CLUB_ID, value: clubId);
      await prefs.remove(PrefsKeys.CLUB_ID);
    }

    if (memberJwt != null && memberJwt.isNotEmpty) {
      await secureStorage.write(key: PrefsKeys.MEMBER_JWT, value: memberJwt);
      await prefs.remove(PrefsKeys.MEMBER_JWT);
    }

    final paymentNum = prefs.getString(PrefsKeys.PAYMENT_NUM);
    if (paymentNum != null && paymentNum.isNotEmpty) {
      await secureStorage.write(key: PrefsKeys.PAYMENT_NUM, value: paymentNum);
      await prefs.remove(PrefsKeys.PAYMENT_NUM);
    }
  }

  static Future<bool> loginFromData(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return false;
    }

    final prefs = PrefsService.instance;
    final response = await LoginService.login(username, password);
    if (response['success'] == true) {
      await prefs.setString(PrefsKeys.USER_DATA, jsonEncode(response));
      await prefs.setInt(
        PrefsKeys.LAST_FETCH_TIME,
        DateTime.now().millisecondsSinceEpoch,
      );
      return true;
    }

    return false;
  }

  static Future<bool> login() async {
    try {
      final prefs = PrefsService.instance;
      final secureStorage = SecureStorageService.instance;

      await migrateCredentials();

      final String? username =
          await secureStorage.read(key: PrefsKeys.USERNAME);
      final String? password =
          await secureStorage.read(key: PrefsKeys.PASSWORD);

      if (username == null || password == null) {
        return false;
      }
      if (username.isEmpty || password.isEmpty) {
        return false;
      }

      final response = await LoginService.login(username, password);
      if (response['success'] == true) {
        await prefs.setString(PrefsKeys.USER_DATA, jsonEncode(response));
        await prefs.setInt(
          PrefsKeys.LAST_FETCH_TIME,
          DateTime.now().millisecondsSinceEpoch,
        );
        return true;
      }
    } catch (e, stackTrace) {
      AppLogger.error('登录失败', error: e, stackTrace: stackTrace);
    }

    return false;
  }

  static Future<UserData?> getUserData() async {
    final cachedData = await getCookie();
    if (cachedData is UserData) {
      return cachedData;
    }

    final loginSuccess = await login();
    if (!loginSuccess) {
      return null;
    }

    final freshData = await getCookie();
    if (freshData is UserData) {
      return freshData;
    }

    throw const FormatException(
        'Cookie data is invalid after successful login');
  }

  static Future<UserData?> getCookie() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final prefs = PrefsService.instance;
      final lastFetchTime = prefs.getInt(PrefsKeys.LAST_FETCH_TIME);
      if (lastFetchTime == null || now - lastFetchTime > 1000 * 60 * 20) {
        return null;
      }

      final String? jsonString = prefs.getString(PrefsKeys.USER_DATA);
      if (jsonString != null) {
        return UserData.fromJson(jsonDecode(jsonString));
      }
    } catch (e, stackTrace) {
      AppLogger.error('读取本地数据失败', error: e, stackTrace: stackTrace);
    }

    return null;
  }
}
