import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/summary_model.dart';

class ApiService {
  // ใช้ Base URL เดียวกันเพื่อความง่ายในการจัดการ
  static const String baseUrl =
      "https://hosting.udru.ac.th/~it67040233115/skillup";

  // 1. ฟังก์ชันบันทึกข้อมูล (Create)
  Future<bool> saveSummary(Summary summary) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/insert_summary.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(summary.toJson()),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['status'] == 'success';
      }
      return false;
    } catch (e) {
      print("Save Error: $e");
      return false;
    }
  }

  // 2. ฟังก์ชันดึงข้อมูลทั้งหมด (Read)
  Future<List<Summary>> fetchSummaries() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_summaries.php'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Summary.fromJson(item)).toList();
      } else {
        throw "ไม่สามารถดึงข้อมูลจาก Server ได้";
      }
    } catch (e) {
      print("Fetch Error: $e");
      return [];
    }
  }

  // 3. ฟังก์ชันลบข้อมูล (Delete) - แก้ไขจุดเช็คเงื่อนไข JSON
  Future<bool> deleteSummary(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete_summary.php'),
        // ส่ง id เป็น String ภายใน Map เพื่อให้ PHP รับค่าผ่าน $_POST['id'] ได้
        body: {"id": id.toString()},
      );

      // Debug: พิมพ์ดูสิ่งที่ Server ส่งกลับมาจริง ๆ ใน Console
      print("Delete Response: ${response.body}");

      if (response.statusCode == 200) {
        // แกะ JSON แทนการเช็ค String ตรงๆ
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      print("Delete Error: $e");
      return false;
    }
  }

  Future<bool> updateSummaryTitle(int id, String newTitle) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_summary.php'), // ต้องสร้างไฟล์ PHP นี้เพิ่ม
        body: {"id": id.toString(), "title": newTitle},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
