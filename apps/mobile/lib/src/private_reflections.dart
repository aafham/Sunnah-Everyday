import 'dart:convert';
import 'dart:math';

import 'package:characters/characters.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A bounded, user-authored note stored only on the user's Android device.
///
/// This model intentionally has no content identifier, title, source, grade,
/// evidence, or body field from the religious-content domain. Until a verified
/// public bundle exists, the shell cannot create bookmarks or view-history
/// records because it has no real immutable content reference to retain.
@immutable
class PrivateReflection {
  const PrivateReflection._({
    required this.id,
    required this.body,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  static const maximumBodyLength = 500;

  final String id;
  final String body;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  static String? normalizeBody(String value) {
    if (value.trim().isEmpty || value.characters.length > maximumBodyLength) {
      return null;
    }
    return value;
  }

  factory PrivateReflection.create({
    required String id,
    required String body,
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
  }) {
    final normalizedBody = normalizeBody(body);
    if (!_reflectionIdPattern.hasMatch(id) || normalizedBody == null) {
      throw const PrivateReflectionFormatException();
    }

    final created = createdAtUtc.toUtc();
    final updated = updatedAtUtc.toUtc();
    if (updated.isBefore(created)) {
      throw const PrivateReflectionFormatException();
    }

    return PrivateReflection._(
      id: id,
      body: normalizedBody,
      createdAtUtc: created,
      updatedAtUtc: updated,
    );
  }

  factory PrivateReflection.fromJson(Object? value) {
    final map = _jsonObject(value);
    return PrivateReflection.create(
      id: _jsonString(map['id']),
      body: _jsonString(map['body']),
      createdAtUtc: _jsonUtcDateTime(map['createdAtUtc']),
      updatedAtUtc: _jsonUtcDateTime(map['updatedAtUtc']),
    );
  }

  Map<String, Object> toJson() => <String, Object>{
    'id': id,
    'body': body,
    'createdAtUtc': createdAtUtc.toIso8601String(),
    'updatedAtUtc': updatedAtUtc.toIso8601String(),
  };
}

final _reflectionIdPattern = RegExp(r'^r_[a-z0-9_]{1,64}$');

/// The complete secure-storage envelope for the currently shippable personal-data
/// feature. It is deliberately capped so secure key-value storage is not used
/// as an unbounded database.
@immutable
class PrivateReflectionSnapshot {
  PrivateReflectionSnapshot({List<PrivateReflection> reflections = const []})
    : reflections = List.unmodifiable(reflections) {
    if (reflections.length > maximumEntries || !_hasDistinctIds(reflections)) {
      throw const PrivateReflectionFormatException();
    }
  }

  static const schemaVersion = 1;
  static const maximumEntries = 50;

  static final empty = PrivateReflectionSnapshot();

  final List<PrivateReflection> reflections;

  bool get isEmpty => reflections.isEmpty;
  bool get isFull => reflections.length >= maximumEntries;

  PrivateReflectionSnapshot add(PrivateReflection reflection) {
    if (isFull || reflections.any((existing) => existing.id == reflection.id)) {
      throw const PrivateReflectionFormatException();
    }
    return PrivateReflectionSnapshot(reflections: [reflection, ...reflections]);
  }

  PrivateReflectionSnapshot remove(String id) => PrivateReflectionSnapshot(
    reflections: reflections
        .where((reflection) => reflection.id != id)
        .toList(growable: false),
  );

  Map<String, Object> toJson() => <String, Object>{
    'schemaVersion': schemaVersion,
    'reflections': reflections
        .map((reflection) => reflection.toJson())
        .toList(),
  };

  factory PrivateReflectionSnapshot.fromJson(Object? value) {
    final map = _jsonObject(value);
    if (map['schemaVersion'] != schemaVersion) {
      throw const PrivateReflectionFormatException();
    }
    final rawReflections = map['reflections'];
    if (rawReflections is! List) {
      throw const PrivateReflectionFormatException();
    }
    return PrivateReflectionSnapshot(
      reflections: rawReflections
          .map(PrivateReflection.fromJson)
          .toList(growable: false),
    );
  }

  static bool _hasDistinctIds(List<PrivateReflection> reflections) =>
      reflections.map((reflection) => reflection.id).toSet().length ==
      reflections.length;
}

/// A deliberately generic error so private text and platform exception details
/// cannot be surfaced in the shell or diagnostics.
class PrivateReflectionFormatException implements Exception {
  const PrivateReflectionFormatException();

  @override
  String toString() => 'PrivateReflectionFormatException';
}

Map<String, Object?> _jsonObject(Object? value) {
  if (value is! Map) {
    throw const PrivateReflectionFormatException();
  }
  return Map<String, Object?>.from(value);
}

String _jsonString(Object? value) {
  if (value is! String) {
    throw const PrivateReflectionFormatException();
  }
  return value;
}

DateTime _jsonUtcDateTime(Object? value) {
  if (value is! String || !value.endsWith('Z')) {
    throw const PrivateReflectionFormatException();
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null || !parsed.isUtc) {
    throw const PrivateReflectionFormatException();
  }
  return parsed;
}

abstract interface class PrivateReflectionStore {
  Future<PrivateReflectionSnapshot> read();

  Future<void> write(PrivateReflectionSnapshot snapshot);

  /// Removes every reflection in this feature's isolated secure namespace.
  Future<void> deleteAllReflections();

  /// Whether an unavailable store can still make a best-effort, key-scoped
  /// deletion attempt without first reading private text.
  bool get canAttemptRecoveryDeletion;
}

/// Narrow adapter around platform secure storage so unit tests never need a
/// global platform mock or real device key material.
abstract interface class SecureValueStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

class FlutterSecureValueStore implements SecureValueStore {
  FlutterSecureValueStore()
    : _storage = FlutterSecureStorage(
        aOptions: AndroidOptions(
          storageNamespace: _secureStorageNamespace,
          // Never silently erase private reflections after a Keystore error.
          resetOnError: false,
        ),
      );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class SecurePrivateReflectionStore implements PrivateReflectionStore {
  SecurePrivateReflectionStore(
    this._storage, {
    this._readTimeout = const Duration(seconds: 5),
  });

  static const _storageKey = 'private_reflections_v1';

  final SecureValueStore _storage;
  final Duration _readTimeout;

  @override
  bool get canAttemptRecoveryDeletion => true;

  @override
  Future<PrivateReflectionSnapshot> read() async {
    try {
      final encoded = await _storage.read(_storageKey).timeout(_readTimeout);
      if (encoded == null) {
        return PrivateReflectionSnapshot.empty;
      }
      return PrivateReflectionSnapshot.fromJson(jsonDecode(encoded));
    } catch (_) {
      throw const PrivateReflectionFormatException();
    }
  }

  @override
  Future<void> write(PrivateReflectionSnapshot snapshot) async {
    try {
      await _storage.write(_storageKey, jsonEncode(snapshot.toJson()));
    } catch (_) {
      throw const PrivateReflectionFormatException();
    }
  }

  @override
  Future<void> deleteAllReflections() async {
    try {
      await _storage.delete(_storageKey);
    } catch (_) {
      throw const PrivateReflectionFormatException();
    }
  }
}

/// Test-only and safe-shell fallback implementation. It is never selected by
/// the installed Android bootstrap when secure storage is unavailable.
class InMemoryPrivateReflectionStore implements PrivateReflectionStore {
  InMemoryPrivateReflectionStore({
    PrivateReflectionSnapshot? initialSnapshot,
    this.failReads = false,
    this.failWrites = false,
    this.failDeletes = false,
  }) : _snapshot = initialSnapshot ?? PrivateReflectionSnapshot.empty;

  PrivateReflectionSnapshot _snapshot;
  bool failReads;
  bool failWrites;
  bool failDeletes;

  @override
  bool get canAttemptRecoveryDeletion => true;

  @override
  Future<PrivateReflectionSnapshot> read() async {
    if (failReads) {
      throw const PrivateReflectionFormatException();
    }
    return _snapshot;
  }

  @override
  Future<void> write(PrivateReflectionSnapshot snapshot) async {
    if (failWrites) {
      throw const PrivateReflectionFormatException();
    }
    _snapshot = snapshot;
  }

  @override
  Future<void> deleteAllReflections() async {
    if (failDeletes) {
      throw const PrivateReflectionFormatException();
    }
    _snapshot = PrivateReflectionSnapshot.empty;
  }
}

class UnavailablePrivateReflectionStore implements PrivateReflectionStore {
  const UnavailablePrivateReflectionStore();

  @override
  bool get canAttemptRecoveryDeletion => false;

  @override
  Future<PrivateReflectionSnapshot> read() =>
      Future<PrivateReflectionSnapshot>.error(
        const PrivateReflectionFormatException(),
      );

  @override
  Future<void> write(PrivateReflectionSnapshot snapshot) =>
      Future<void>.error(const PrivateReflectionFormatException());

  @override
  Future<void> deleteAllReflections() =>
      Future<void>.error(const PrivateReflectionFormatException());
}

/// Secure private persistence is Android-only in this Android-first release.
///
/// Constructing the Android adapter does not open a platform channel, so the
/// public shell never waits on private storage during startup. The provider
/// performs the first read, fails closed on an error, and still retains this
/// key-scoped adapter for an explicit recovery-deletion attempt. Browser
/// storage and unconfigured platform keychains are not represented as
/// equivalent protection.
PrivateReflectionStore createPrivateReflectionStore() {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
    return const UnavailablePrivateReflectionStore();
  }
  return SecurePrivateReflectionStore(FlutterSecureValueStore());
}

final privateReflectionStoreProvider = Provider<PrivateReflectionStore>(
  (ref) => const UnavailablePrivateReflectionStore(),
);

final privateReflectionProvider =
    AsyncNotifierProvider<PrivateReflectionController, PrivateReflectionState>(
      PrivateReflectionController.new,
    );

sealed class PrivateReflectionState {
  const PrivateReflectionState();
}

class PrivateReflectionReady extends PrivateReflectionState {
  const PrivateReflectionReady(this.snapshot, {this.isMutating = false});

  final PrivateReflectionSnapshot snapshot;
  final bool isMutating;
}

class PrivateReflectionUnavailable extends PrivateReflectionState {
  const PrivateReflectionUnavailable({this.isMutating = false});

  final bool isMutating;
}

class PrivateReflectionController
    extends AsyncNotifier<PrivateReflectionState> {
  final Random _idRandom = Random.secure();

  PrivateReflectionStore get _store => ref.read(privateReflectionStoreProvider);

  @override
  Future<PrivateReflectionState> build() async {
    try {
      return PrivateReflectionReady(await _store.read());
    } catch (_) {
      return const PrivateReflectionUnavailable();
    }
  }

  Future<bool> addReflection(String body) async {
    final current = _readySnapshot;
    final normalizedBody = PrivateReflection.normalizeBody(body);
    if (current == null || normalizedBody == null || current.isFull) {
      return false;
    }

    final now = DateTime.now().toUtc();
    final id = _newReflectionId(current);
    if (id == null) {
      return false;
    }
    final reflection = PrivateReflection.create(
      id: id,
      body: normalizedBody,
      createdAtUtc: now,
      updatedAtUtc: now,
    );
    return _persist(current.add(reflection), current);
  }

  Future<bool> deleteReflection(String id) async {
    final current = _readySnapshot;
    if (current == null || !current.reflections.any((item) => item.id == id)) {
      return false;
    }
    return _persist(current.remove(id), current);
  }

  Future<bool> deleteAllReflections() async {
    final previous = state.asData?.value;
    final canDelete = switch (previous) {
      PrivateReflectionReady() => true,
      PrivateReflectionUnavailable() => _store.canAttemptRecoveryDeletion,
      _ => false,
    };
    if (!canDelete) {
      return false;
    }

    switch (previous) {
      case PrivateReflectionReady(:final snapshot):
        state = AsyncData(PrivateReflectionReady(snapshot, isMutating: true));
      case PrivateReflectionUnavailable():
        state = const AsyncData(PrivateReflectionUnavailable(isMutating: true));
      case null:
        return false;
    }
    try {
      await _store.deleteAllReflections();
      state = AsyncData(
        PrivateReflectionReady(PrivateReflectionSnapshot.empty),
      );
      return true;
    } catch (_) {
      state = AsyncData(previous!);
      return false;
    }
  }

  PrivateReflectionSnapshot? get _readySnapshot {
    final current = state.asData?.value;
    return switch (current) {
      PrivateReflectionReady(:final snapshot) => snapshot,
      _ => null,
    };
  }

  Future<bool> _persist(
    PrivateReflectionSnapshot next,
    PrivateReflectionSnapshot previous,
  ) async {
    state = AsyncData(PrivateReflectionReady(previous, isMutating: true));
    try {
      await _store.write(next);
      state = AsyncData(PrivateReflectionReady(next));
      return true;
    } catch (_) {
      state = AsyncData(PrivateReflectionReady(previous));
      return false;
    }
  }

  String? _newReflectionId(PrivateReflectionSnapshot current) {
    for (var attempt = 0; attempt < 8; attempt += 1) {
      final segments = List<String>.generate(
        4,
        (_) => _idRandom.nextInt(1 << 32).toRadixString(36),
      );
      final id = 'r_${segments.join('_')}';
      if (!current.reflections.any((reflection) => reflection.id == id)) {
        return id;
      }
    }
    return null;
  }
}

const _secureStorageNamespace = 'sunnah_everyday_private_reflections_v1';
