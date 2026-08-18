import '../core/l10n/strings.dart';

/// 1 000 000 -> "1 000 000"
String fmtNum(num n) {
  final s = n.round().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    b.write(s[i]);
    final rem = s.length - 1 - i;
    if (rem > 0 && rem % 3 == 0) b.write(' ');
  }
  return b.toString();
}

/// "12 000 so'm" ko'rinishidagi narx.
String money(AppLang lang, num n) => '${fmtNum(n)} ${S.t(lang, 'sum')}';

/// "12 000 so'm (kg)" ko'rinishi.
String moneyUnit(AppLang lang, num n, String unitLabel) =>
    '${money(lang, n)} · $unitLabel';

/// dd.MM.yyyy HH:mm
String fmtDateTime(DateTime d) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
}

/// dd.MM.yyyy
String fmtDate(DateTime d) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year}';
}
