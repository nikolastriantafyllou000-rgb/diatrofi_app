import 'dart:convert';
import 'dart:html' as html;

Future<String> saveExportFiles(Map<String, String> files) async {
  // Ο browser ζητά ξεχωριστή επιβεβαίωση αποθήκευσης για κάθε ταυτόχρονο
  // download, οπότε συνδυάζουμε τα CSV σε ένα αρχείο ώστε να χρειάζεται
  // μόνο μία επιβεβαίωση από τον χρήστη.
  final buffer = StringBuffer('﻿');
  for (final entry in files.entries) {
    buffer.writeln('# ${entry.key}');
    buffer.writeln(entry.value);
  }

  final bytes = utf8.encode(buffer.toString());
  final blob = html.Blob([bytes], 'text/csv');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..download = 'diatrofi_export.csv'
    ..style.display = 'none'
    ..click();
  // Ο browser μπορεί να καθυστερήσει το download (πχ αναμονή επιβεβαίωσης),
  // οπότε δεν ανακαλούμε το blob URL αμέσως — αλλιώς το αρχείο μένει μόνιμα
  // ημιτελές (.crdownload).
  Future.delayed(const Duration(seconds: 15), () {
    html.Url.revokeObjectUrl(url);
  });

  return 'τις Λήψεις (Downloads) του browser';
}
