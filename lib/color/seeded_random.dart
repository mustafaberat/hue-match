/// Park–Miller (minimal standard) RNG.
///
/// `dart:math` Random(seed) dizisi platformlar arası garanti değil; günlük
/// meydan okumada Android / iOS / web aynı 5 rengi almalı. Çarpım 2^53
/// altında kaldığı için JS sayılarında da birebir aynı sonuç verir.
library;

import 'dart:math';

class SeededRandom implements Random {
  SeededRandom(int seed) : _state = _normalize(seed);

  static const int _modulus = 2147483647;
  static const int _multiplier = 48271;

  int _state;

  static int _normalize(int seed) {
    final s = seed.abs() % _modulus;
    return s == 0 ? 1 : s;
  }

  int _next() {
    _state = (_state * _multiplier) % _modulus;
    return _state;
  }

  @override
  double nextDouble() => (_next() - 1) / (_modulus - 1);

  @override
  int nextInt(int max) {
    if (max <= 0) {
      throw RangeError.range(max, 1, null, 'max');
    }
    return (nextDouble() * max).floor().clamp(0, max - 1);
  }

  @override
  bool nextBool() => _next().isOdd;
}
