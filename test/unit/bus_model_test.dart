import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/bus_model.dart';

void main() {
  group('BusModel', () {
    test('should deserialize and serialize correctly', () {
      final json = <String, dynamic>{
        'records': <Map<String, dynamic>>[
          <String, dynamic>{
            'lineName': '1号线',
            'description': '高峰快线',
            'departureStation': '北门',
            'arrivalStation': '南门',
            'runTime': '01:20:00',
            'arrivalStationTime': 'x01:50',
          },
        ],
        'total': 1,
      };

      final model = BusModel.fromJson(json);
      expect(model.total, 1);
      expect(model.records.length, 1);
      expect(model.records.first.lineName, '1号线');
      expect(model.records.first.runTime, '01:20');
      expect(model.records.first.arrivalStationTime, '01小时 50分钟');
      expect(model.records.first.arrivalTime, '3:10');

      final encoded = model.toJson();
      expect(encoded['total'], 1);
      expect((encoded['records'] as List).length, 1);
    });
  });

  group('BusItem', () {
    test('should keep safe defaults when fields are malformed or missing', () {
      final fromJson = BusItem.fromJson(<String, dynamic>{});
      expect(fromJson.lineName, '');
      expect(fromJson.description, '');
      expect(fromJson.departureStation, '');
      expect(fromJson.arrivalStation, '');
      expect(fromJson.runTime, '');
      expect(fromJson.arrivalStationTime, '');
      expect(fromJson.arrivalTime, '');
    });

    test('should avoid substring and parse crashes on short time strings', () {
      final item = BusItem(
        lineName: '2号线',
        description: '短线',
        departureStation: 'A',
        arrivalStation: 'B',
        runTime: '12',
        arrivalStationTime: 'x',
      );

      expect(item.runTime, '12');
      expect(item.arrivalStationTime, 'x');
      expect(item.arrivalTime, '');
    });
  });
}
