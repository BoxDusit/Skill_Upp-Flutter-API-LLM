import 'package:flutter/material.dart';
import '../models/summary_model.dart';
import '../services/api_service.dart';
import '../services/file_helper.dart';
import '../services/ai_service.dart';
import '../screens/summary_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  final AIService _aiService = AIService();
  bool _isLoading = false;

  Future<void> _onRefresh() async => setState(() {});

  // --- ฟังก์ชันหลัก: อัปโหลดและสรุปด้วย AI ---
  void _handleUploadAndSummarize() async {
    final fileData = await FileHelper.pickAndReadInternal();
    if (fileData != null) {
      setState(() => _isLoading = true);
      try {
        String rawContent = fileData['content']!;
        String summaryResult = await _aiService.summarizeText(rawContent);

        Summary newEntry = Summary(
          title: fileData['title']!,
          content: summaryResult,
        );

        bool isSaved = await _apiService.saveSummary(newEntry);
        if (isSaved) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('สรุปและบันทึกเรียบร้อย!')));
          setState(() {}); 
        }
      } catch (e) {
        debugPrint("Error: $e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // ฟังก์ชันแก้ไขชื่อ
  void _editTitle(Summary item) async {
    final TextEditingController titleController = TextEditingController(text: item.title);
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("แก้ไขชื่อเอกสาร"),
        content: TextField(controller: titleController, decoration: const InputDecoration(border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("ยกเลิก")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("บันทึก")),
        ],
      ),
    );
    if (confirm == true && titleController.text.isNotEmpty) {
      await _apiService.updateSummaryTitle(item.id!, titleController.text);
      setState(() {});
    }
  }

  // ฟังก์ชันลบ
  void _confirmDelete(int? id) async {
    if (id == null) return;
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ยืนยันการลบ"),
        content: const Text("คุณต้องการลบสรุปนี้ใช่หรือไม่?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("ยกเลิก")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("ลบ", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _apiService.deleteSummary(id);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('SkillUpp', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.menu_open_rounded, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text("เริ่มต้นการ Up สกิลของคุณ!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("อัปโหลดไฟล์ของคุณได้อย่างรวดเร็วเพื่อให้ AI วิเคราะห์และช่วยพัฒนาทักษะของคุณทันที", 
                    style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                  
                  const SizedBox(height: 30),
                  
                  // --- กล่องอัปโหลดไฟล์ (ตามแบบดีไซน์) ---
                  GestureDetector(
                    onTap: _isLoading ? null : _handleUploadAndSummarize,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400, width: 2,),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.file_upload_outlined, size: 60, color: Colors.black),
                          const SizedBox(height: 10),
                          const Text("อัปโหลดไฟล์", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text("ชนิดไฟล์ .png .pdf .jpg .gif", style: TextStyle(color: Colors.grey[500])),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleUploadAndSummarize,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 34, 34, 34),
                              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 12)
                            ),
                            child: const Text("เริ่มเลย", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  const Text("ดูสรุปเอกสารล่าสุด", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // --- รายการสรุป (List Cards) ---
                  FutureBuilder<List<Summary>>(
                    future: _apiService.fetchSummaries(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting && !_isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text("ไม่มีข้อมูลสรุป"),
                        ));
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final item = snapshot.data![index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  Text(item.content, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600])),
                                  const SizedBox(height: 10),
                                  
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                onSelected: (value) {
                                  if (value == 'edit') _editTitle(item);
                                  if (value == 'delete') _confirmDelete(item.id);
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text("แก้ไขชื่อ")])),
                                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text("ลบ", style: TextStyle(color: Colors.red))])),
                                ],
                                icon: const Icon(Icons.more_vert),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SummaryDetailPage(
                                      summary: {
                                        'id': item.id,
                                        'title': item.title,
                                        'content': item.content,
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // --- หน้าจอโหลดตอน AI ทำงาน ---
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.black),
                    SizedBox(height: 20),
                    Text("AI กำลังประมวลผลสรุปให้คุณ...", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}