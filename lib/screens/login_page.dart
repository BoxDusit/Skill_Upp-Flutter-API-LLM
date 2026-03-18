import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_page.dart'; // สำหรับไปหน้าสมัครสมาชิก
import 'home_page.dart';     // เปลี่ยนเป็นชื่อหน้าหลักของคุณ (เช่น MainPage)

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  // ฟังก์ชันจัดการการ Login
  void _handleLogin() async {
    // Validation เบื้องต้น
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar("กรุณากรอกข้อมูลให้ครบถ้วน");
      return;
    }

    setState(() => _isLoading = true);
    
    final result = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result != null) {
      // SUCCESS: เก็บ Token (ถ้ามี) และไปหน้าหลัก
      _showSnackBar("เข้าสู่ระบบสำเร็จ!");
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()), // เปลี่ยนเป็นหน้าหลักของคุณ
      );
    } else {
      // FAIL: แจ้งเตือนข้อผิดพลาด
      _showSnackBar("อีเมลหรือรหัสผ่านไม่ถูกต้อง");
    }
  }

  // ฟังก์ชันแสดง SnackBar แบบสั้นๆ
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // โลโก้แบรนด์ SkillUpp ตามดีไซน์
              const Text('SkillUpp', 
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1.5)),
              const Text('Lean with AI', 
                style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 50),

              // ส่วนกรอกข้อมูล
              _buildTextField("อีเมล", _emailController, false, Icons.email_outlined),
              const SizedBox(height: 15),
              _buildTextField("รหัสผ่าน", _passwordController, true, Icons.lock_outline),
              
              const SizedBox(height: 30),

              // ปุ่มเข้าสู่ระบบ
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        width: 24, 
                        height: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("เข้าสู่ระบบ", 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 20),

              // ลิงก์ไปหน้าสมัครสมาชิก
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("ยังไม่มีบัญชี? ", style: TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: const Text("สมัครสมาชิก", 
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget สร้าง TextField ที่คุมดีไซน์ให้เหมือนกันทั้งแอป
  Widget _buildTextField(String label, TextEditingController controller, bool isPassword, IconData icon) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        floatingLabelStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
      ),
    );
  }
}