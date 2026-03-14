import 'dart:io';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:pdfrx/pdfrx.dart';

class FileTextExtractorService {
  
  Future<String?> extractText(File file, String extension) async {
    try {
      switch (extension.toLowerCase()) {
        case 'pdf':
             return await _extractFromPdf(file);
        case 'docx':
             return await _extractFromDocx(file);
        case 'doc':
             return await _extractFromDoc(file);
        default:
             return null;
      }
    } catch (e) {
      print('FileTextExtractor error: $e');
      return null;
    }

  }

  Future<String> _extractFromPdf(File file) async {
    final document = await PdfDocument.openFile(file.path);
    final StringBuffer buffer = StringBuffer();
    

    for (int i = 1; i <= document.pages.length; i++) {
      final page = document.pages[i - 1];
      final textPage = await page.loadText();
      buffer.write(textPage.fullText);
      buffer.write('\n');
    }

    document.dispose();
    print('FileTextExtractor: extracted ${buffer.length} chars from PDF');
    return buffer.toString();
  }

  Future<String> _extractFromDocx(File file) async {
    final bytes = await file.readAsBytes();
    final text = docxToText(bytes);
    print('FileTextExtractor: extracted ${text.length} chars from DOCX');
    return text;
  }

  Future<String> _extractFromDoc(File file) async {
    final bytes = await file.readAsBytes();
    final raw = String.fromCharCodes(
      bytes.where((b) => b >= 32 && b < 127),
    );
    print('FileTextExtractor: extracted ${raw.length} chars from DOC (basic)');
    return raw;
  }

  String truncateForGemini(String text, {int maxChars = 10000}) {
    if (text.length <= maxChars) return text;
    print('FileTextExtractor: truncating from ${text.length} to $maxChars chars');
    return '${text.substring(0, maxChars)}\n\n[Content truncated...]';
  }
}