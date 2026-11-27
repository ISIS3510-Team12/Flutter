class SparseArray<T> {
  final List<int> _keys = [];
  final List<T> _values = [];

  int _binarySearch(int key) {
    var low = 0;
    var high = _keys.length - 1;

    while (low <= high) {
      final mid = low + (high - low) ~/ 2;
      final current = _keys[mid];

      if (current == key) return mid;
      if (current < key) {
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    return ~low;
  }

  T? get(int key) {
    final index = _binarySearch(key);
    return index >= 0 ? _values[index] : null;
  }

  void put(int key, T value) {
    final index = _binarySearch(key);

    if (index >= 0) {
      _values[index] = value;
    } else {
      final insertionIndex = ~index;
      _keys.insert(insertionIndex, key);
      _values.insert(insertionIndex, value);
    }
  }

  void remove(int key) {
    final index = _binarySearch(key);

    if (index >= 0) {
      _keys.removeAt(index);
      _values.removeAt(index);
    }
  }

  bool containsKey(int key) => _binarySearch(key) >= 0;

  void clear() {
    _keys.clear();
    _values.clear();
  }

  int get length => _keys.length;
}
