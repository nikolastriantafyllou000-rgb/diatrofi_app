/// Μικρό helper για όμορφη ημερομηνία/ώρα
String formatDateTime(DateTime d) {
  final date =
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  final time =
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  return '$date • $time';
}
