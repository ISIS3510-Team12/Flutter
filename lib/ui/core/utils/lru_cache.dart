import 'dart:collection';

import 'package:clock/clock.dart';

class _Entry<V> {
  _Entry(this.value, this.storedAt);

  final V value;
  final DateTime storedAt;
}

class LruCache<K, V extends Object> {
  LruCache({
    required this.maxEntries,
    required this.ttl,
    Clock clock = const Clock(),
  }) : assert(maxEntries > 0),
       _clock = clock;

  final int maxEntries;
  final Duration ttl;
  final Clock _clock;
  final LinkedHashMap<K, _Entry<V>> _entries = LinkedHashMap();
  final Map<K, Future<V?>> _inFlight = {};

  int hits = 0;
  int misses = 0;

  int get length => _entries.length;

  V? get(K key) {
    final entry = _entries.remove(key);
    if (entry == null) {
      misses++;
      return null;
    }
    if (_clock.now().difference(entry.storedAt) > ttl) {
      misses++;
      return null;
    }
    _entries[key] = entry;
    hits++;
    return entry.value;
  }

  void put(K key, V value) {
    _entries.remove(key);
    _entries[key] = _Entry(value, _clock.now());
    while (_entries.length > maxEntries) {
      _entries.remove(_entries.keys.first);
    }
  }

  Future<V?> getOrLoad(K key, Future<V?> Function() loader) {
    final cached = get(key);
    if (cached != null) return Future.value(cached);
    final pending = _inFlight[key];
    if (pending != null) return pending;
    final future = loader()
        .then((value) {
          if (value != null) put(key, value);
          return value;
        })
        .whenComplete(() {
          _inFlight.remove(key);
        });
    _inFlight[key] = future;
    return future;
  }

  void clear() {
    _entries.clear();
    _inFlight.clear();
  }
}
