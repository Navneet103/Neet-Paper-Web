class IstClock {
  static DateTime now() => DateTime.now();

  static String dateKey([DateTime? date]) {
    final d = date ?? now();
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  static int numericIdForDate(DateTime date) {
    return date.year * 10000 + date.month * 100 + date.day;
  }

  static DateTime nineAmOn(DateTime date) {
    return DateTime(date.year, date.month, date.day, 9, 0);
  }

  static DateTime parseDateKey(String key) {
    final parts = key.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  static int durationMinutesForCount(int questionCount) {
    if (questionCount <= 0) return 15;
    if (questionCount >= 180) return 180;
    return questionCount.clamp(15, 180);
  }
}
