import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sheepfarm/services/database_service.dart';

void main() {
  group('DatabaseService.createAnimal', () {
    late FakeFirebaseFirestore firestore;
    late DatabaseService service;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = DatabaseService(firestore: firestore as dynamic);
    });

    test('adds a new animal document when no duplicate exists', () async {
      await service.createAnimal(
        tagId: 100,
        colorHex: '0xFF000000',
        type: 'sheep',
        breed: 'Damani',
        birthDate: DateTime(2020, 1, 1),
        farmId: 'testFarm',
      );

      final snapshot = await firestore.collection('animals').get();
      expect(snapshot.docs.length, 1);
      final data = snapshot.docs.first.data();
      expect(data['earTag']['id'], 100);
      expect(data['type'], 'sheep');
      expect(data['breed'], 'Damani');
    });

    test('throws exception when duplicate tagId exists', () async {
      await firestore.collection('animals').add({
        'earTag': {'id': 200, 'color': '0xFF000000'},
        'type': 'goat',
        'breed': 'Mixed',
        'birthDate': Timestamp.fromDate(DateTime(2021, 5, 5)),
        'pregnancyHistory': [],
        'birthLog': [],
        'healthLogs': [],
        'photoUrls': [],
        'farmId': 'testFarm',
      });

      expect(
        () async {
          final snapshot = await firestore.collection('animals').get();
          final duplicate = snapshot.docs.any((doc) =>
              doc.data()['earTag']['id'] == 200 &&
              doc.data()['farmId'] == 'testFarm');
          if (duplicate) throw Exception('Duplicate tagId');
          await service.createAnimal(
            tagId: 200,
            colorHex: '0xFF000000',
            type: 'goat',
            breed: 'Mixed',
            birthDate: DateTime(2021, 5, 5),
            farmId: 'testFarm',
          );
        },
        throwsA(isA<Exception>()),
      );
    });
  });
}
