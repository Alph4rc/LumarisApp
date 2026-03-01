import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/models/electric_data.dart';

void main() {
  test('ElectricData should allow reading and updating value', () {
    final ts = DateTime(2026, 3, 2, 10, 0, 0);
    final data = ElectricData(timestamp: ts, value: 12.5);

    expect(data.timestamp, ts);
    expect(data.value, 12.5);

    data.value = 18.0;
    expect(data.value, 18.0);
  });
}
