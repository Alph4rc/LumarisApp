import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ios_club_app/features/club/models/student_model.dart';
import 'package:ios_club_app/features/club/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('auth_service_test_');
    Hive.init(tempDir.path);
  });

  setUp(() {
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

  final student = StudentModel(
    userName: 'u',
    userId: 'id',
    academy: 'a',
    politicalLandscape: 'p',
    gender: 'g',
    className: 'c',
    phoneNum: '1',
    joinTime: DateTime(2026, 1, 1),
    passwordHash: 'h',
    eMail: 'x@test.com',
  );

  test('login should return null on network failure', () async {
    final token = await AuthService.login('id', 'pwd');
    expect(token, isNull);
  });

  test('signup should return false on network failure', () async {
    final ok = await AuthService.signup(student);
    expect(ok, isFalse);
  });

  test('logout should return false on network failure', () async {
    final ok = await AuthService.logout('id');
    expect(ok, isFalse);
  });

  test('validate should return false on network failure', () async {
    final ok = await AuthService.validate('id');
    expect(ok, isFalse);
  });

  test('changePassword should return false on network failure', () async {
    final ok = await AuthService.changePassword('id', 'old', 'new');
    expect(ok, isFalse);
  });

  test('requestPasswordReset should return false on network failure', () async {
    final ok = await AuthService.requestPasswordReset('id');
    expect(ok, isFalse);
  });

  test('resetPassword should return false on network failure', () async {
    final ok = await AuthService.resetPassword('id', 'code', 'new');
    expect(ok, isFalse);
  });

  test('refreshToken should return null on network failure', () async {
    final token = await AuthService.refreshToken('id', 'refresh');
    expect(token, isNull);
  });
}
