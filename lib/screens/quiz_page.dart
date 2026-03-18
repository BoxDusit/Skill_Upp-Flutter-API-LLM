import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  final List<dynamic> quizData;
  const QuizPage({super.key, required this.quizData});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedOption;
  bool _isAnswered = false;

  // 1. ฟังก์ชันเมื่อกดเลือกตัวเลือก (แสดง Dialog ยืนยัน)
  void _checkAnswer(String selected) {
    if (_isAnswered) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("ยืนยันคำตอบ", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("คุณเลือกข้อ: $selected\nต้องการส่งคำตอบนี้ใช่หรือไม่?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("เลือกใหม่", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _confirmAnswer(selected); // ไปที่ฟังก์ชันตรวจคำตอบ
            },
            child: const Text("ส่งคำตอบ", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 2. ฟังก์ชันตรวจคำตอบและบันทึกคะแนน
  void _confirmAnswer(String selected) {
    setState(() {
      _selectedOption = selected;
      _isAnswered = true;
      if (selected == widget.quizData[_currentIndex]['answer']) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.quizData.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _isAnswered = false;
      });
    } else {
      _showScoreDialog();
    }
  }

  void _showScoreDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("ยินดีด้วย! 🎉", textAlign: TextAlign.center),
        content: Text("คุณได้คะแนน $_score / ${widget.quizData.length}",
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context); // ปิด Dialog
                Navigator.pop(context); // กลับหน้า Detail
              },
              child: const Text("กลับไปหน้าบทเรียน", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quiz = widget.quizData[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("ข้อที่ ${_currentIndex + 1}/${widget.quizData.length}"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / widget.quizData.length,
              backgroundColor: Colors.grey[200],
              color: Colors.blueAccent,
              minHeight: 8,
            ),
            const SizedBox(height: 30),
            Text(quiz['question'],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            // รายการตัวเลือก 4 ข้อ
            ...List.generate(4, (index) {
              String option = quiz['options'][index];
              bool isCorrect = option == quiz['answer'];
              bool isSelected = option == _selectedOption;

              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: GestureDetector(
                  onTap: () => _checkAnswer(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _isAnswered
                          ? (isCorrect ? Colors.green[50] : (isSelected ? Colors.red[50] : Colors.white))
                          : Colors.white,
                      border: Border.all(
                        color: _isAnswered
                            ? (isCorrect ? Colors.green : (isSelected ? Colors.red : Colors.grey.shade300))
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Text("${String.fromCharCode(65 + index)}.",
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(option)),
                        if (_isAnswered && isCorrect)
                          const Icon(Icons.check_circle, color: Colors.green),
                        if (_isAnswered && isSelected && !isCorrect)
                          const Icon(Icons.cancel, color: Colors.red),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            // ปุ่มไปข้อถัดไป จะปรากฏเมื่อตอบแล้วเท่านั้น
            if (_isAnswered)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(
                    _currentIndex < widget.quizData.length - 1 ? "ข้อต่อไป" : "ดูผลคะแนน",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}