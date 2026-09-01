import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/core/services/firebase_database_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseReference extends Mock implements DatabaseReference {}
class MockDataSnapshot extends Mock implements DataSnapshot {}

void main() {
  late MockDatabaseReference mockRef;
  late MockDatabaseReference mockChildRef;
  late DatabaseService service;

  setUp(() {
    mockRef = MockDatabaseReference();
    mockChildRef = MockDatabaseReference();
    when(() => mockRef.child(any())).thenReturn(mockChildRef);
    service = FirebaseDatabaseService(mockRef);
  });

  test('implements DatabaseService interface', () {
    expect(service, isA<DatabaseService>());
  });

  test('serverTimestamp and increment return expected values', () {
    expect(service.serverTimestamp, equals(ServerValue.timestamp));
    expect(service.increment(5), equals(ServerValue.increment(5)));
  });

  test('delete calls child remove on reference', () async {
    when(() => mockChildRef.remove()).thenAnswer((_) async {});

    await service.delete('item-123');

    verify(() => mockRef.child('item-123')).called(1);
    verify(() => mockChildRef.remove()).called(1);
  });

  test('getOnce returns map data when snapshot exists', () async {
    final mockSnapshot = MockDataSnapshot();
    when(() => mockSnapshot.exists).thenReturn(true);
    when(() => mockSnapshot.value).thenReturn({'id': '1', 'name': 'Item'});
    when(() => mockRef.get()).thenAnswer((_) async => mockSnapshot);

    final data = await service.getOnce();

    expect(data, isNotNull);
    expect(data!['name'], equals('Item'));
  });
}
