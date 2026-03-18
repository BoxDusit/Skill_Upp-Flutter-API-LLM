import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controller สำหรับรับค่าจากหน้าจอ
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final _authService = AuthService();
  bool _isLoading = false;

  void _handleRegister() async {
    // 1. ตรวจสอบค่าว่าง
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอกข้อมูลให้ครบถ้วน")),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // 2. ดึงค่าและส่งไปยัง AuthService
    // หมายเหตุ: เนื่องจาก UI มี 2 ช่อง แต่ Database ต้องการ 3 ค่า (name, username, password)
    // เราจะใช้ค่าจาก _usernameController ส่งไปเป็นทั้ง 'name' และ 'username'
    final success = await _authService.register(
      _usernameController.text.trim(), // ส่งไปเป็น name
      _usernameController.text.trim(), // ส่งไปเป็น username
      _passwordController.text.trim(), // ส่งไปเป็น password
    );

    setState(() => _isLoading = false);

    // 3. จัดการผลลัพธ์
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("สมัครสมาชิกสำเร็จ! กรุณาเข้าสู่ระบบ")),
      );
      Navigator.pop(context); // กลับไปหน้า Login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("การสมัครสมาชิกล้มเหลว (อาจมีชื่อผู้ใช้นี้แล้ว)")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, 
        elevation: 0, 
        leading: const BackButton(color: Colors.black),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('SkillUpp', 
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900)),
              const Text('สร้างบัญชีใหม่', 
                style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 40),

              // ช่องกรอก Username
              _buildTextField("ชื่อผู้ใช้งาน (Username)", _usernameController, false, Icons.person),
              const SizedBox(height: 15),
              
              // ช่องกรอก Password
              _buildTextField("รหัสผ่าน (Password)", _passwordController, true, Icons.lock),
              const SizedBox(height: 30),

              // ปุ่มสมัครสมาชิก
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("สมัครสมาชิก", 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget ตัวช่วยสร้าง TextField เพื่อลดโค้ดซ้ำซ้อน
  Widget _buildTextField(String label, TextEditingController controller, bool isPassword, IconData icon) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }
}