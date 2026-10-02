DateTime parseServerDate(String value) {
  final parsed = DateTime.parse(value);
  if (parsed.isUtc) return parsed.toLocal();
  return DateTime.utc(
    parsed.year,
    parsed.month,
    parsed.day,
    parsed.hour,
    parsed.minute,
    parsed.second,
  ).toLocal();
}
