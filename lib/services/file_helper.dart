import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class FileHelper {
  static Future<Map<String, String>?> pickAndReadInternal() async {
    // 1. เลือกไฟล์
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt'],
    );

    if (result != null && result.files.single.path != null) {
      String fileName = result.files.single.name;
      File file = File(result.files.single.path!);
      String extractedText = "";

      // 2. ถ้าเป็น PDF ให้แกะข้อความ
      if (result.files.single.extension == 'pdf') {
        final PdfDocument document = PdfDocument(inputBytes: await file.readAsBytes());
        extractedText = PdfTextExtractor(document).extractText();
        document.dispose();
      } 
      // 3. ถ้าเป็น TXT อ่านตรงๆ
      else {
        extractedText = await file.readAsString();
      }

      return {
        "title": fileName,
        "content": extractedText,
      };
    }
    return null;
  }
}