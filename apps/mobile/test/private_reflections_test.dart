import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunnaheveryday/src/private_reflections.dart';

void main() {
  group('PrivateReflection', () {
    test('normalizes a bounded user-authored body and UTC timestamps', () {
      final reflection = PrivateReflection.create(
        id: 'r_note_1',
        body: '  Private note  ',
        createdAtUtc: DateTime.parse('2026-07-19T12:00:00+08:00'),
        updatedAtUtc: DateTime.parse('2026-07-19T04:30:00Z'),
      );

      expect(reflection.id, 'r_note_1');
      expect(reflection.body, '  Private note  ');
      expect(reflection.createdAtUtc, DateTime.utc(2026, 7, 19, 4));
      expect(reflection.updatedAtUtc, DateTime.utc(2026, 7, 19, 4, 30));
      expect(
        PrivateReflection.normalizeBody(
          '🙂' * PrivateReflection.maximumBodyLength,
        ),
        isNotNull,
      );
      expect(
        PrivateReflection.normalizeBody(
          '🙂' * (PrivateReflection.maximumBodyLength + 1),
        ),
        isNull,
      );
    });

    test('rejects invalid bodies, identifiers, and timestamp ordering', () {
      final now = DateTime.utc(2026, 7, 19);

      expect(
        () => PrivateReflection.create(
          id: 'r_note_1',
          body: '   ',
          createdAtUtc: now,
          updatedAtUtc: now,
        ),
        throwsA(isA<PrivateReflectionFormatException>()),
      );
      expect(
        () => PrivateReflection.create(
          id: 'content_1',
          body: 'Private note',
          createdAtUtc: now,
          updatedAtUtc: now,
        ),
        throwsA(isA<PrivateReflectionFormatException>()),
      );
      expect(
        () => PrivateReflection.create(
          id: 'r_note_1',
          body: 'x' * (PrivateReflection.maximumBodyLength + 1),
          createdAtUtc: now,
          updatedAtUtc: now,
        ),
        throwsA(isA<PrivateReflectionFormatException>()),
      );
      expect(
        () => PrivateReflection.create(
          id: 'r_note_1',
          body: 'Private note',
          createdAtUtc: now,
          updatedAtUtc: now.subtract(const Duration(seconds: 1)),
        ),
        throwsA(isA<PrivateReflectionFormatException>()),
      );
    });
  });

  group('PrivateReflectionSnapshot', () {
    test(
      'is bounded, rejects duplicate records, and stores no content fields',
      () {
        var snapshot = PrivateReflectionSnapshot.empty;
        for (
          var index = 0;
          index < PrivateReflectionSnapshot.maximumEntries;
          index += 1
        ) {
          snapshot = snapshot.add(_reflection(index: index));
        }

        expect(snapshot.isFull, isTrue);
        expect(
          () => snapshot.add(_reflection(index: 99)),
          throwsA(isA<PrivateReflectionFormatException>()),
        );
        expect(
          () => PrivateReflectionSnapshot(
            reflections: [_reflection(index: 1), _reflection(index: 1)],
          ),
          throwsA(isA<PrivateReflectionFormatException>()),
        );

        final serialized = jsonDecode(jsonEncode(snapshot.toJson())) as Map;
        expect(
          serialized.keys,
          unorderedEquals(['schemaVersion', 'reflections']),
        );
        final record = (serialized['reflections'] as List).first as Map;
        expect(
          record.keys,
          unorderedEquals(['id', 'body', 'createdAtUtc', 'updatedAtUtc']),
        );
        expect(record.containsKey('contentId'), isFalse);
        expect(record.containsKey('bookmark'), isFalse);
        expect(record.containsKey('history'), isFalse);
      },
    );
  });

  group('SecurePrivateReflectionStore', () {
    test(
      'round-trips one isolated secure envelope and deletes only that key',
      () async {
        final values = _RecordingSecureValueStore();
        final store = SecurePrivateReflectionStore(values);
        final expected = PrivateReflectionSnapshot(
          reflections: [_reflection(index: 1)],
        );

        await store.write(expected);
        expect(values.lastWriteKey, 'private_reflections_v1');
        expect(values.lastWriteValue, isNotNull);
        expect(await store.read(), _matchesSnapshot(expected));

        await store.deleteAllReflections();
        expect(values.deletedKey, 'private_reflections_v1');
        expect(
          await store.read(),
          _matchesSnapshot(PrivateReflectionSnapshot.empty),
        );
      },
    );

    test(
      'masks corrupt values and platform failures without exposing note text',
      () async {
        final corrupt = _RecordingSecureValueStore(value: '{not json');
        final corruptStore = SecurePrivateReflectionStore(corrupt);
        await _expectGenericFailure(corruptStore.read, 'private note sentinel');

        final readFailure = _RecordingSecureValueStore(
          readError: StateError('private note sentinel'),
        );
        await _expectGenericFailure(
          SecurePrivateReflectionStore(readFailure).read,
          'private note sentinel',
        );

        final failing = _RecordingSecureValueStore(
          writeError: StateError('private note sentinel'),
          deleteError: StateError('private note sentinel'),
        );
        final failingStore = SecurePrivateReflectionStore(failing);
        await _expectGenericFailure(
          () => failingStore.write(
            PrivateReflectionSnapshot(reflections: [_reflection(index: 1)]),
          ),
          'private note sentinel',
        );
        await _expectGenericFailure(
          failingStore.deleteAllReflections,
          'private note sentinel',
        );
      },
    );

    test('fails closed when a secure read does not return', () async {
      final store = SecurePrivateReflectionStore(
        const _HangingSecureValueStore(),
        readTimeout: Duration.zero,
      );

      await _expectGenericFailure(store.read, 'private note sentinel');
    });

    test(
      'unreadable secure storage permits only a key-scoped recovery deletion',
      () async {
        final values = _RecordingSecureValueStore(value: '{not json');
        final recovery = SecurePrivateReflectionStore(values);

        await expectLater(
          recovery.read(),
          throwsA(isA<PrivateReflectionFormatException>()),
        );
        await recovery.deleteAllReflections();

        expect(recovery.canAttemptRecoveryDeletion, isTrue);
        expect(values.deletedKey, 'private_reflections_v1');
        expect(values.value, isNull);
      },
    );
  });

  group('PrivateReflectionController', () {
    test('creates distinct opaque local record identifiers', () async {
      final store = InMemoryPrivateReflectionStore();
      final container = _containerFor(store);
      addTearDown(container.dispose);
      await container.read(privateReflectionProvider.future);
      final controller = container.read(privateReflectionProvider.notifier);

      expect(await controller.addReflection('Private note one'), isTrue);
      expect(await controller.addReflection('Private note two'), isTrue);
      final ids = (await store.read()).reflections
          .map((reflection) => reflection.id)
          .toSet();

      expect(ids, hasLength(2));
      expect(ids.every((id) => id.startsWith('r_')), isTrue);
    });

    test('persists, reopens, and deletes an individual reflection', () async {
      final store = InMemoryPrivateReflectionStore();
      final first = _containerFor(store);
      final firstState = await first.read(privateReflectionProvider.future);
      expect(firstState, isA<PrivateReflectionReady>());

      final firstController = first.read(privateReflectionProvider.notifier);
      expect(await firstController.addReflection('Private note'), isTrue);
      final saved = await store.read();
      final savedId = saved.reflections.single.id;
      first.dispose();

      final reopened = _containerFor(store);
      addTearDown(reopened.dispose);
      final reopenedState = await reopened.read(
        privateReflectionProvider.future,
      );
      expect(reopenedState, isA<PrivateReflectionReady>());
      expect(
        (reopenedState as PrivateReflectionReady).snapshot,
        _matchesSnapshot(saved),
      );

      expect(
        await reopened
            .read(privateReflectionProvider.notifier)
            .deleteReflection(savedId),
        isTrue,
      );
      expect((await store.read()).isEmpty, isTrue);
    });

    test(
      'restores the previous ready state when writes or deletion fail',
      () async {
        final expected = PrivateReflectionSnapshot(
          reflections: [_reflection(index: 1)],
        );
        final store = InMemoryPrivateReflectionStore(
          initialSnapshot: expected,
          failWrites: true,
        );
        final container = _containerFor(store);
        addTearDown(container.dispose);
        await container.read(privateReflectionProvider.future);
        final controller = container.read(privateReflectionProvider.notifier);

        expect(await controller.addReflection('Another private note'), isFalse);
        expect(
          await controller.deleteReflection(expected.reflections.single.id),
          isFalse,
        );
        expect(_readySnapshot(container), _matchesSnapshot(expected));
        expect(await store.read(), _matchesSnapshot(expected));

        store.failWrites = false;
        store.failDeletes = true;
        expect(await controller.deleteAllReflections(), isFalse);
        expect(_readySnapshot(container), _matchesSnapshot(expected));
        expect(await store.read(), _matchesSnapshot(expected));
      },
    );

    test('deletes unreadable data through the recovery-only route', () async {
      final values = _RecordingSecureValueStore(value: '{not json');
      final container = _containerFor(SecurePrivateReflectionStore(values));
      addTearDown(container.dispose);

      expect(
        await container.read(privateReflectionProvider.future),
        isA<PrivateReflectionUnavailable>(),
      );
      expect(
        await container
            .read(privateReflectionProvider.notifier)
            .deleteAllReflections(),
        isTrue,
      );
      expect(values.deletedKey, 'private_reflections_v1');
      expect(_readySnapshot(container).isEmpty, isTrue);
    });

    test(
      'fails closed with no in-memory fallback when storage is unavailable',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(
          await container.read(privateReflectionProvider.future),
          isA<PrivateReflectionUnavailable>(),
        );
        final controller = container.read(privateReflectionProvider.notifier);
        expect(await controller.addReflection('Private note'), isFalse);
        expect(await controller.deleteReflection('r_note_1'), isFalse);
        expect(await controller.deleteAllReflections(), isFalse);
        expect(
          container.read(privateReflectionProvider).asData?.value,
          isA<PrivateReflectionUnavailable>(),
        );
      },
    );
  });

  test(
    'unsupported platform bootstrap fails closed without a memory fallback',
    () {
      final originalOverride = debugDefaultTargetPlatformOverride;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = originalOverride);

      expect(
        createPrivateReflectionStore(),
        isA<UnavailablePrivateReflectionStore>(),
      );
    },
  );
}

PrivateReflection _reflection({required int index}) {
  final timestamp = DateTime.utc(2026, 7, 19, 12, 0, index);
  return PrivateReflection.create(
    id: 'r_note_$index',
    body: 'Private note $index',
    createdAtUtc: timestamp,
    updatedAtUtc: timestamp,
  );
}

ProviderContainer _containerFor(PrivateReflectionStore store) =>
    ProviderContainer(
      overrides: [privateReflectionStoreProvider.overrideWithValue(store)],
    );

PrivateReflectionSnapshot _readySnapshot(ProviderContainer container) {
  final state = container.read(privateReflectionProvider).asData?.value;
  expect(state, isA<PrivateReflectionReady>());
  return (state! as PrivateReflectionReady).snapshot;
}

Matcher _matchesSnapshot(PrivateReflectionSnapshot expected) => predicate(
  (PrivateReflectionSnapshot actual) =>
      actual.toJson().toString() == expected.toJson().toString(),
  'matches the expected private reflection snapshot',
);

Future<void> _expectGenericFailure(
  Future<void> Function() operation,
  String privateSentinel,
) async {
  try {
    await operation();
    fail('Expected a generic private-reflection failure.');
  } catch (error) {
    expect(error, isA<PrivateReflectionFormatException>());
    expect(error.toString(), isNot(contains(privateSentinel)));
  }
}

class _RecordingSecureValueStore implements SecureValueStore {
  _RecordingSecureValueStore({
    this.value,
    this.readError,
    this.writeError,
    this.deleteError,
  });

  String? value;
  final Object? readError;
  final Object? writeError;
  final Object? deleteError;
  String? lastReadKey;
  String? lastWriteKey;
  String? lastWriteValue;
  String? deletedKey;

  @override
  Future<void> delete(String key) async {
    if (deleteError != null) {
      throw deleteError!;
    }
    deletedKey = key;
    value = null;
  }

  @override
  Future<String?> read(String key) async {
    if (readError != null) {
      throw readError!;
    }
    lastReadKey = key;
    return value;
  }

  @override
  Future<void> write(String key, String nextValue) async {
    if (writeError != null) {
      throw writeError!;
    }
    lastWriteKey = key;
    lastWriteValue = nextValue;
    value = nextValue;
  }
}

class _HangingSecureValueStore implements SecureValueStore {
  const _HangingSecureValueStore();

  @override
  Future<void> delete(String key) async {}

  @override
  Future<String?> read(String key) => Completer<String?>().future;

  @override
  Future<void> write(String key, String value) async {}
}
