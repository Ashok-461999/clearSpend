enum DateRangeType { today, week, month, year, custom }

({DateTime start, DateTime end}) monthBounds(int year, int month) {
  final start = DateTime(year, month, 1);
  final end = DateTime(year, month + 1, 1);
  return (start: start, end: end);
}

({DateTime start, DateTime end}) todayBounds() {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 1));
  return (start: start, end: end);
}

({DateTime start, DateTime end}) weekBounds() {
  final now = DateTime.now();
  final weekday = now.weekday;
  final start = DateTime(now.year, now.month, now.day - (weekday - 1));
  final end = start.add(const Duration(days: 7));
  return (start: start, end: end);
}

({DateTime start, DateTime end}) yearBounds(int year) {
  final start = DateTime(year, 1, 1);
  final end = DateTime(year + 1, 1, 1);
  return (start: start, end: end);
}
