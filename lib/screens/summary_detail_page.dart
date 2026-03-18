import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import '../services/ai_service.dart';
import 'quiz_page.dart';

class SummaryDetailPage extends StatefulWidget {
  final Map<String, dynamic> summary;

  const SummaryDetailPage({Key? key, required this.summary}) : super(key: key);

  @override
  State<SummaryDetailPage> createState() => _SummaryDetailPageState();
}

class _SummaryDetailPageState extends State<SummaryDetailPage> {
  final AIService _aiService = AIService();
  bool _isQuizLoading = false;
  late String _displayTitle; // ใช้สำหรับอัปเดตชื่อบน UI ทันที

  @override
  void initState() {
    super.initState();
    _displayTitle = widget.summary['title'] ?? "ไม่มีชื่อไฟล์";
  }

  // --- ฟังก์ชันแก้ไขชื่อ ---
  void _editTitle() {
    TextEditingController _controller = TextEditingController(
      text: _displayTitle,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("แก้ไขชื่อบทสรุป"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: "ชื่อบทสรุปใหม่"),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          TextButton(
            onPressed: () {
              setState(() => _displayTitle = _controller.text);
              // TODO: ส่งค่ากลับไปบันทึกที่ Database หรือเรียก API อัปเดตที่นี่
              Navigator.pop(context);
            },
            child: const Text("บันทึก"),
          ),
        ],
      ),
    );
  }

  // --- ฟังก์ชันยืนยันการลบ ---
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("ยืนยันการลบ"),
        content: const Text("คุณแน่ใจหรือไม่ว่าต้องการลบบทสรุปนี้?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          TextButton(
            onPressed: () {
              // TODO: เรียก API ลบข้อมูลที่นี่
              Navigator.pop(context); // ปิด Dialog
              Navigator.pop(context); // กลับไปยังหน้า List
            },
            child: const Text("ลบ", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGenerateQuiz() async {
    setState(() => _isQuizLoading = true);
    try {
      final quizData = await _aiService.generateQuiz(
        widget.summary['content'] ?? "",
      );
      if (quizData.isNotEmpty) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuizPage(quizData: quizData)),
        );
      }
    } catch (e) {
      debugPrint("Quiz Error: $e");
    } finally {
      if (mounted) setState(() => _isQuizLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'รายละเอียดบทสรุป',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // --- เพิ่ม PopupMenuButton ตรงนี้ ---
        actions: [
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            onSelected: (value) {
              if (value == 'edit') _editTitle();
              if (value == 'delete') _confirmDelete();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text("แก้ไขชื่อ"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text("ลบ", style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert, color: Colors.black),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _displayTitle, // ใช้ตัวแปรที่รองรับการเปลี่ยนชื่อ
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(
                  widget.summary['created_at'] != null
                      ? DateFormat(
                          'dd MMMM yyyy, HH:mm',
                          'th_TH',
                        ).format(DateTime.parse(widget.summary['created_at']))
                      : "วันที่ไม่ทราบ",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Quiz Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(207, 242, 242, 242),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color.fromARGB(176, 199, 199, 199),
                ),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.psychology, color: Colors.black),
                      SizedBox(width: 10),
                      Text(
                        "พร้อมทดสอบไหม?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isQuizLoading ? null : _handleGenerateQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: _isQuizLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "เริ่มทำแบบทดสอบจากเนื้อหา",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F1F1)),
            const SizedBox(height: 25),

            // Markdown Content
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: Colors.blueAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  "บทสรุปจาก AI",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
             decoration: BoxDecoration(
                color: const Color.fromARGB(207, 242, 242, 242),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color.fromARGB(176, 199, 199, 199),
                ),
              ),
              child: MarkdownBody(
                data: widget.summary['content'] ?? "ไม่มีเนื้อหา",
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    fontSize: 16,
                    height: 1.7,
                    color: Colors.grey[800],
                  ),
                  listBullet: const TextStyle(
                    fontSize: 16,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
