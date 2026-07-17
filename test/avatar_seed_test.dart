import 'package:flow_avatar/flow_avatar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('flowAvatarSeed', () {
    test('is stable and unsigned', () {
      final first = flowAvatarSeed('user@example.com');
      final second = flowAvatarSeed('user@example.com');

      expect(first, second);
      expect(first, 2085630174);
      expect(first, inInclusiveRange(0, 0xffffffff));
    });

    test('distinguishes nearby identities', () {
      expect(flowAvatarSeed('user-1001'), isNot(flowAvatarSeed('user-1002')));
    });

    test('supports UTF-16 identities', () {
      expect(flowAvatarSeed('你好 👋'), flowAvatarSeed('你好 👋'));
      expect(flowAvatarSeed('你好 👋'), 513115367);
      expect(flowAvatarSeed('你好 👋'), isNot(flowAvatarSeed('你好')));
    });
  });
}
