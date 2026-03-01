import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ios_club_app/core/services/club_service.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();

    tempDir = await Directory.systemTemp.createTemp('club_service_test_');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    await PrefsService.instance.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'read') return null;
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('getLinks should return empty list on network failure', () async {
    final list = await ClubService.getLinks();
    expect(list, isEmpty);
  });

  test('getMemberInfo should clear malformed member data and return fallback',
      () async {
    await PrefsService.instance.setString(PrefsKeys.MEMBER_DATA, '{bad-json}');

    final info = await ClubService.getMemberInfo();

    expect(info.memberData, isEmpty);
    expect(info.info, isNull);
    expect(PrefsService.instance.getString(PrefsKeys.MEMBER_DATA), '');
  });

  test('getMemberInfo should parse stored member data json', () async {
    await PrefsService.instance.setString(
      PrefsKeys.MEMBER_DATA,
      '{"userName":"u","userId":"id"}',
    );

    final info = await ClubService.getMemberInfo();

    expect(info.memberData['userName'], 'u');
    expect(info.memberData['userId'], 'id');
  });

  test('getMembersByPage should return empty page model on failure', () async {
    final result = await ClubService.getMembersByPage(1, 10);

    expect(result.data, isEmpty);
    expect(result.totalCount, 0);
    expect(result.totalPages, 0);
  });

  test('getStaffsByPage should return empty page model on failure', () async {
    final result = await ClubService.getStaffsByPage(1, 10);

    expect(result.data, isEmpty);
    expect(result.totalCount, 0);
    expect(result.totalPages, 0);
  });

  test('loginMember should return false on failure', () async {
    final ok = await ClubService.loginMember('u', 'p');
    expect(ok, isFalse);
  });

  test('changePassword should return false on failure', () async {
    final ok = await ClubService.changePassword('id', 'old', 'new');
    expect(ok, isFalse);
  });

  test('getAllMemberData should return empty list on failure', () async {
    final list = await ClubService.getAllMemberData();
    expect(list, isEmpty);
  });

  test('validateUser should return false on failure', () async {
    final ok = await ClubService.validateUser('id');
    expect(ok, isFalse);
  });
}
