import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const SkillUppApp());
}

class SkillUppApp extends StatelessWidget {
  const SkillUppApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillUpp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Kanit', // แนะนำให้ใช้ฟอนต์ภาษาไทยเพื่อให้ดูสวยงาม
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}