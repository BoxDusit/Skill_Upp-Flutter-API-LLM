import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // 1. นำ API Key จาก Groq มาวางตรงนี้
  static final String _apiKey = String.fromEnvironment('API_KEY'); // แนะนำให้เก็บใน .env หรือ Secret Manager ในโปรเจคจริง
  static const String _url = "https://api.groq.com/openai/v1/chat/completions";

  Future<bool> deleteSummary(String id) async {
    final response = await http.post(
      Uri.parse(
        "https://hosting.udru.ac.th/~it67040233115/skillup/delete_summary.php",
      ), // เปลี่ยนเป็น URL ของคุณ
      body: {"id": id},
    );

    if (response.statusCode == 200 && response.body == "success") {
      return true;
    }
    return false;
  }

  Future<String> summarizeText(String text) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model":
              "llama-3.3-70b-versatile", // ใช้รุ่น Llama 3.3 (ฟรีและฉลาดมาก)
          "messages": [
            {
              "role": "system",
              "content":
                  "คุณคือผู้ช่วยสรุปบทเรียน หน้าที่ของคุณคือสรุปเนื้อหาที่ได้รับให้เป็นข้อๆ เข้าใจง่าย และเป็นภาษาไทยเท่านั้น",
            },
            {
              "role": "user",
              "content": "ช่วยสรุปเนื้อหาต่อไปนี้ให้หน่อย: \n\n $text",
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        // ถอดรหัสภาษาไทยให้ถูกต้อง
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        return "AI Error (${response.statusCode}): กรุณาลองใหม่อีกครั้ง";
      }
    } catch (e) {
      return "ไม่สามารถเชื่อมต่อ AI ได้: $e";
    }
  }

  Future<List<dynamic>> generateQuiz(String text) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content":
                  "คุณคือครูที่เก่งที่สุด สร้างข้อสอบปรนัย 4 ตัวเลือก 5 ข้อ จากเนื้อหาที่ได้รับ โดยตอบกลับเป็น JSON List เท่านั้น ห้ามมีคำบรรยายอื่น รูปแบบ: [{\"question\": \"...\", \"options\": [\"A\", \"B\", \"C\", \"D\"], \"answer\": \"คำตอบที่ถูกต้อง\"}]",
            },
            {"role": "user", "content": "สร้างข้อสอบจากเนื้อหานี้: $text"},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String content = data['choices'][0]['message']['content'];
        // ป้องกันกรณี AI ใส่ markdown ```json ... ``` มาให้
        content = content
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        return jsonDecode(content);
      }
    } catch (e) {
      
    }
    return [];
  }
}
