import 'package:flutter_test/flutter_test.dart';
import 'package:guiter_up/models/practice_record.dart';

void main() {
  group('PracticeRecord', () {
    test('creates a record with all fields', () {
      final now = DateTime.now();
      final record = PracticeRecord(
        id: 'test-id',
        title: 'Test Practice',
        dateTime: now,
        guitarType: 'Electric Guitar',
        guitarModel: 'Fender Stratocaster',
        ampEquipmentMemo: 'Marshall amp',
        impressionMemo: 'Great practice session',
        referenceUrl: 'https://youtube.com/watch?v=test',
        videoPaths: ['/path/to/video1.mp4', '/path/to/video2.mp4'],
      );

      expect(record.id, 'test-id');
      expect(record.title, 'Test Practice');
      expect(record.dateTime, now);
      expect(record.guitarType, 'Electric Guitar');
      expect(record.guitarModel, 'Fender Stratocaster');
      expect(record.ampEquipmentMemo, 'Marshall amp');
      expect(record.impressionMemo, 'Great practice session');
      expect(record.referenceUrl, 'https://youtube.com/watch?v=test');
      expect(record.videoPaths.length, 2);
    });

    test('converts to and from map', () {
      final now = DateTime.now();
      final record = PracticeRecord(
        id: 'test-id',
        title: 'Test Practice',
        dateTime: now,
        guitarType: 'Electric Guitar',
        guitarModel: 'Fender Stratocaster',
        videoPaths: ['/path/to/video.mp4'],
      );

      final map = record.toMap();
      final restored = PracticeRecord.fromMap(map);

      expect(restored.id, record.id);
      expect(restored.title, record.title);
      expect(restored.guitarType, record.guitarType);
      expect(restored.guitarModel, record.guitarModel);
      expect(restored.videoPaths, record.videoPaths);
    });

    test('handles empty optional fields', () {
      final now = DateTime.now();
      final record = PracticeRecord(
        id: 'test-id',
        dateTime: now,
        videoPaths: [],
      );

      expect(record.title, isNull);
      expect(record.guitarType, isNull);
      expect(record.guitarModel, isNull);
      expect(record.ampEquipmentMemo, isNull);
      expect(record.impressionMemo, isNull);
      expect(record.referenceUrl, isNull);
      expect(record.videoPaths, isEmpty);
    });
  });
}
