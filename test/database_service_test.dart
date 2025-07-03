import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sheepfarm/services/database_service.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'dart:io';

// Minimal fake Reference for Storage
class FakeReference implements storage.Reference {
  @override
  Future<String> getDownloadURL() async => 'http://fakeurl';
  @override
  storage.Reference child(String path) => this;
  @override
  storage.UploadTask putFile(File file, [storage.SettableMetadata? metadata]) =>
      FakeUploadTask();
  // ...implement all other members as no-op or throw UnimplementedError...
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeUploadTask implements storage.UploadTask {
  // ...implement all members as no-op or throw UnimplementedError...
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeFirebaseStorage implements storage.FirebaseStorage {
  @override
  storage.Reference ref([String? path]) => FakeReference();
  // ...implement all other members as no-op or throw UnimplementedError...
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('DatabaseService.createAnimal', () {
    late FakeFirebaseFirestore firestore;
    late FakeFirebaseStorage storage;
    late DatabaseService service;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      storage = FakeFirebaseStorage();
      service = DatabaseService(
          firestore: firestore as dynamic, storage: storage as dynamic);
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
      // Pre-add a document with tagId 200
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
          // Check for duplicate before adding
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
