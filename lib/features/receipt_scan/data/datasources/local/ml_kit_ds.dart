// lib/features/receipt_scan/data/datasources/local/ml_kit_ds.dart
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

abstract class MlKitDataSource {
  Future<String> extractText(String imagePath);
  Future<void> close();
}

class MlKitDataSourceImpl implements MlKitDataSource {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<String> extractText(String imagePath) async {
    final input = InputImage.fromFile(File(imagePath));
    final result = await _recognizer.processImage(input);
    final sb = StringBuffer();
    for (final block in result.blocks) {
      for (final line in block.lines) sb.writeln(line.text);
    }
    return sb.toString().trim();
  }

  @override
  Future<void> close() => _recognizer.close();
}
