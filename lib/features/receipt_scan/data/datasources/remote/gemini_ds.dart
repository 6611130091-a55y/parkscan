// lib/features/receipt_scan/data/datasources/remote/gemini_ds.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

class ReceiptClassification {
  final String storeName;
  final double totalAmount;
  final String receiptDateIso;
  final String category;

  ReceiptClassification({
    required this.storeName, required this.totalAmount,
    required this.receiptDateIso, required this.category,
  });

  factory ReceiptClassification.fromJson(Map<String, dynamic> j) =>
      ReceiptClassification(
        storeName:      j['store_name']   as String? ?? 'ไม่ทราบชื่อร้าน',
        totalAmount:   (j['total_amount'] as num?)?.toDouble() ?? 0.0,
        receiptDateIso: j['receipt_date'] as String? ?? '',
        category:       j['category']    as String? ?? 'unknown',
      );
}

abstract class GeminiDataSource {
  Future<ReceiptClassification> classify(String rawText);
}

class GeminiDataSourceImpl implements GeminiDataSource {
  final Dio _dio;
  final Box _cache;
  final String _apiKey;

  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  GeminiDataSourceImpl({required Dio dio, required Box cache, required String apiKey})
      : _dio = dio, _cache = cache, _apiKey = apiKey;

  @override
  Future<ReceiptClassification> classify(String rawText) async {
    final key = 'g_${rawText.hashCode}';
    final cached = _cache.get(key);
    if (cached != null) {
      return ReceiptClassification.fromJson(
          Map<String, dynamic>.from(jsonDecode(cached as String)));
    }

    const prompt = '''
คุณเป็นระบบวิเคราะห์ใบเสร็จ ตอบเป็น JSON เท่านั้น:
{
  "store_name": "ชื่อร้าน",
  "total_amount": 0.0,
  "receipt_date": "YYYY-MM-DD",
  "category": "shopping | restaurant | beverageBakery | unknown"
}
หมวดหมู่: shopping=ห้าง/ซูเปอร์, restaurant=ร้านอาหาร, beverageBakery=คาเฟ่/เครื่องดื่ม/เบเกอรี่
''';

    final res = await _dio.post(
      '$_endpoint?key=$_apiKey',
      data: {
        'contents': [{'parts': [{'text': '$prompt\nใบเสร็จ:\n$rawText'}]}],
        'generationConfig': {'temperature': 0.1, 'maxOutputTokens': 256},
      },
    );

    final text = res.data['candidates'][0]['content']['parts'][0]['text'] as String;
    final jsonStr = _extractJson(text);
    final parsed  = jsonDecode(jsonStr) as Map<String, dynamic>;
    await _cache.put(key, jsonEncode(parsed));
    return ReceiptClassification.fromJson(parsed);
  }

  String _extractJson(String text) {
    final m = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(text);
    if (m != null) return m.group(1)!.trim();
    final s = text.indexOf('{'), e = text.lastIndexOf('}');
    if (s != -1 && e != -1) return text.substring(s, e + 1);
    throw Exception('parse JSON ล้มเหลว');
  }
}
