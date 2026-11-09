import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

Future<String> saveReportFile(String fileName, List<int> bytes) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

String csvLine(Iterable<Object?> values) => values.map((value) {
      final text = '${value ?? ''}';
      return '"${text.replaceAll('"', '""')}"';
    }).join(',');

/// Creates a small, dependency-free, print-friendly PDF using Helvetica text.
Uint8List createTextPdf(List<String> sourceLines) {
  const linesPerPage = 48;
  final lines = sourceLines.map(_pdfSafe).toList();
  final pageCount = (lines.length / linesPerPage).ceil().clamp(1, 100000);
  final objects = <int, String>{
    1: '<< /Type /Catalog /Pages 2 0 R >>',
    3: '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',
  };
  final pageIds = <int>[];

  for (var page = 0; page < pageCount; page++) {
    final contentId = 4 + page * 2;
    final pageId = contentId + 1;
    pageIds.add(pageId);
    final start = page * linesPerPage;
    final end = (start + linesPerPage).clamp(0, lines.length);
    final pageLines = lines.sublist(start, end);
    final buffer = StringBuffer('BT /F1 9 Tf 50 790 Td 14 TL ');
    for (final line in pageLines) {
      buffer.write('(${_pdfEscape(line)}) Tj T* ');
    }
    buffer.write('ET');
    final stream = buffer.toString();
    objects[contentId] =
        '<< /Length ${ascii.encode(stream).length} >>\nstream\n$stream\nendstream';
    objects[pageId] =
        '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 3 0 R >> >> /Contents $contentId 0 R >>';
  }
  objects[2] =
      '<< /Type /Pages /Kids [${pageIds.map((id) => '$id 0 R').join(' ')}] /Count $pageCount >>';

  final output = BytesBuilder();
  output.add(ascii.encode('%PDF-1.4\n'));
  final offsets = <int>[0];
  final maxId = 3 + pageCount * 2;
  for (var id = 1; id <= maxId; id++) {
    offsets.add(output.length);
    output.add(ascii.encode('$id 0 obj\n${objects[id]}\nendobj\n'));
  }
  final xrefOffset = output.length;
  output.add(ascii.encode('xref\n0 ${maxId + 1}\n'));
  output.add(ascii.encode('0000000000 65535 f \n'));
  for (var id = 1; id <= maxId; id++) {
    output.add(ascii.encode('${offsets[id].toString().padLeft(10, '0')} 00000 n \n'));
  }
  output.add(ascii.encode(
      'trailer\n<< /Size ${maxId + 1} /Root 1 0 R >>\nstartxref\n$xrefOffset\n%%EOF'));
  return output.toBytes();
}

String _pdfEscape(String value) =>
    value.replaceAll(r'\', r'\\').replaceAll('(', r'\(').replaceAll(')', r'\)');

String _pdfSafe(String value) => value
    .replaceAll('—', '-')
    .replaceAll('–', '-')
    .replaceAll('₨', 'Rs ')
    .replaceAll(RegExp(r'[^\x20-\x7E]'), '?');
