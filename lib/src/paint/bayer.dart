/// Builds an ordered Bayer matrix of order [n] (size 2^n × 2^n).
///
/// Each entry is a threshold in (0, 1). Used by the dither pattern.
List<List<double>> makeBayerMatrix(int n) {
  var matrix = [
    [0.0],
  ];
  for (var k = 0; k < n; k++) {
    final size = matrix.length;
    final next = List.generate(
      size * 2,
      (_) => List<double>.filled(size * 2, 0),
    );
    for (var y = 0; y < size * 2; y++) {
      for (var x = 0; x < size * 2; x++) {
        final base = matrix[y % size][x % size] * 4;
        final add = x < size ? (y < size ? 0 : 3) : (y < size ? 2 : 1);
        next[y][x] = base + add;
      }
    }
    matrix = next;
  }
  final max = matrix.length * matrix.length;
  return [
    for (final row in matrix) [for (final value in row) (value + 0.5) / max],
  ];
}

/// Cached Bayer 8×8 thresholds (order 3).
final List<List<double>> kBayer8 = makeBayerMatrix(3);
