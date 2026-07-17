import 'package:flutter_test/flutter_test.dart';

// Test the package-private Bayer helpers via a thin re-export path is not
// available; import the implementation file through the package's src path.
import 'package:flow_avatar/src/paint/bayer.dart';

void main() {
  test('Bayer 8×8 has unit thresholds and full rank', () {
    expect(kBayer8.length, 8);
    for (final row in kBayer8) {
      expect(row.length, 8);
      for (final value in row) {
        expect(value, greaterThan(0));
        expect(value, lessThan(1));
      }
    }

    final flat = kBayer8.expand((row) => row).toList()..sort();
    // All 64 thresholds are unique for a proper ordered matrix.
    expect(flat.toSet().length, 64);
  });

  test('makeBayerMatrix(1) is the classic 2×2 ordered dither', () {
    final m = makeBayerMatrix(1);
    expect(m.length, 2);
    expect(m[0].length, 2);
    // Values are (rank + 0.5) / 4 for ranks 0,2 / 3,1 layout.
    expect(m[0][0], closeTo(0.5 / 4, 1e-9));
    expect(m[0][1], closeTo(2.5 / 4, 1e-9));
    expect(m[1][0], closeTo(3.5 / 4, 1e-9));
    expect(m[1][1], closeTo(1.5 / 4, 1e-9));
  });
}
