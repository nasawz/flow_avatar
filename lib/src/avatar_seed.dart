/// Produces a stable unsigned 32-bit seed from a Dart string.
///
/// Iterating over [String.codeUnits] intentionally matches JavaScript's
/// UTF-16 `charCodeAt` behavior, including for emoji and surrogate pairs.
int flowAvatarSeed(String value) {
  var hash = 0x811c9dc5;
  for (final codeUnit in value.codeUnits) {
    hash ^= codeUnit;
    hash = _imul32(hash, 0x01000193);
  }

  // Murmur-inspired avalanche so similar identifiers diverge quickly.
  hash ^= hash >>> 16;
  hash = _imul32(hash, 0x7feb352d);
  hash ^= hash >>> 15;
  hash = _imul32(hash, 0x846ca68b);
  hash ^= hash >>> 16;
  return hash.toUnsigned(32);
}

int _imul32(int a, int b) {
  final aLow = a & 0xffff;
  final aHigh = (a >>> 16) & 0xffff;
  final bLow = b & 0xffff;
  final bHigh = (b >>> 16) & 0xffff;
  return (aLow * bLow + ((aHigh * bLow + aLow * bHigh) << 16)).toUnsigned(32);
}

/// Small deterministic PRNG whose state is always treated as uint32.
final class SeededRandom {
  SeededRandom(int seed) : _state = seed == 0 ? 0x6d2b79f5 : seed;

  int _state;

  int nextUint32() {
    var value = _state;
    value ^= value << 13;
    value ^= value >>> 17;
    value ^= value << 5;
    _state = value.toUnsigned(32);
    return _state;
  }

  double nextDouble() => nextUint32() / 0x100000000;

  int nextInt(int max) => (nextDouble() * max).floor();

  double between(double min, double max) => min + nextDouble() * (max - min);
}
