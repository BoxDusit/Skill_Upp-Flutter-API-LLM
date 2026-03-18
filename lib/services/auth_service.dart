import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "https://hosting.udru.ac.th/~it67040233115/skillup"; 

  // ฟังก์ชันสมัครสมาชิก (เพิ่ม String name เข้ามา)
  Future<bool> register(String name, String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,         // ส่งชื่อผู้ใช้
          'username': username, // ส่งอีเมล/ชื่อล็อกอิน
          'password': password, // ส่งรหัสผ่าน
        }),
      );

      // สำคัญมาก: ดู Log ตรงนี้เพื่อเช็คว่า Server ตอบกลับมาเป็น JSON หรือหน้า Error 500
      print("Register Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      print("Error connecting to Register API: $e");
      return false;
    }
  }

  // ฟังก์ชันเข้าสู่ระบบ
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print("Login Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data;
        }
        return null;
      }
      return null;
    } catch (e) {
      print("Error connecting to Login API: $e");
      return null;
    }
  }
}