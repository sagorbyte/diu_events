class Utils {
  static const String _k = 'DIU_SECRET_KEY_2025';

  static String _d(String h) {
    try {
      final b = <int>[];
      for (int i = 0; i < h.length; i += 2) {
        b.add(int.parse(h.substring(i, i + 2), radix: 16));
      }

      final sb = _k.codeUnits;
      final d = <int>[];

      for (int i = 0; i < b.length; i++) {
        final sb2 = sb[i % sb.length];
        d.add(b[i] ^ sb2);
      }

      return String.fromCharCodes(d);
    } catch (e) {
      return '';
    }
  }

  static String g(String key) {
    const Map<String, String> d = {
      'a': '002c233a3f2a333721743d326514365c58534f3125751e3120273b2b',
    };
    return _d(d[key] ?? '');
  }
}
