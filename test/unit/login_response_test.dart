import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/login_response.dart';

void main() {
  group('LoginResponse', () {
    test('should parse all known fields and extra values', () {
      final model = LoginResponse.fromJson(<String, dynamic>{
        'token': 't',
        'userId': 'u',
        'studentId': 's',
        'username': 'name',
        'name': 'real',
        'department': 'dep',
        'className': 'class',
        'success': false,
        'message': 'failed',
        'unexpectedKey': 123,
      });

      expect(model.token, 't');
      expect(model.userId, 'u');
      expect(model.studentId, 's');
      expect(model.username, 'name');
      expect(model.name, 'real');
      expect(model.department, 'dep');
      expect(model.className, 'class');
      expect(model.success, isFalse);
      expect(model.message, 'failed');
      expect(model.extra!['unexpectedKey'], 123);
      expect(model.isSuccess, isFalse);
    });

    test('should default isSuccess to true when success is null', () {
      final model = LoginResponse.fromJson(<String, dynamic>{});
      expect(model.success, isNull);
      expect(model.isSuccess, isTrue);
      expect(model.toJson(), isEmpty);
    });

    test('toJson should only include non-null fields', () {
      final model = LoginResponse(
        token: 't',
        userId: 'u',
        success: true,
        message: 'ok',
        extra: <String, dynamic>{'env': 'test'},
      );

      final json = model.toJson();
      expect(json['token'], 't');
      expect(json['userId'], 'u');
      expect(json['success'], isTrue);
      expect(json['message'], 'ok');
      expect(json['env'], 'test');
      expect(json.containsKey('studentId'), isFalse);
    });
  });
}
