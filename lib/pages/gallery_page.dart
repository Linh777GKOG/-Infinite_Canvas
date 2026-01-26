import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../utils/storage_helper.dart';
import 'draw_page.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<Map<String, dynamic>> drawings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  // Load danh sách tranh
  Future<void> _loadGallery() async {
    setState(() => isLoading = true);
    final data = await StorageHelper.getAllDrawings();
    setState(() {
      drawings = data;
      isLoading = false;
    });
  }

  // Mở trang vẽ
  void _openCanvas({String? id}) async {
    // Tạo ID mới nếu bấm nút Tạo, hoặc dùng ID cũ nếu bấm vào tranh
    String drawingId = id ?? const Uuid().v4();

    // Chuyển sang DrawPage
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DrawPage(drawingId: drawingId)),
    );

    // Khi quay về thì load lại danh sách để cập nhật ảnh thumbnail mới
    _loadGallery();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Gallery", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : drawings.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.brush_rounded, size: 80, color: Colors.grey[800]),
            const SizedBox(height: 10),
            Text("Chưa có tranh nào", style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 5),
            Text("Bấm nút + để vẽ ngay", style: TextStyle(color: Colors.grey[800], fontSize: 12)),
          ],
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: drawings.length,
        itemBuilder: (context, index) {
          final item = drawings[index];
          final File thumbFile = File(item['thumbPath']);

          return GestureDetector(
            onTap: () => _openCanvas(id: item['id']),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6)],
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: thumbFile.existsSync()
                          ? Image.file(thumbFile, fit: BoxFit.cover)
                          : Container(color: Colors.grey[800], child: const Icon(Icons.broken_image, color: Colors.white54)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Artwork #${index + 1}",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${item['date'].day}/${item['date'].month} • ${item['date'].hour}:${item['date'].minute}",
                          style: TextStyle(color: Colors.grey[500], fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCanvas(),
        backgroundColor: const Color(0xFF32C5FF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tạo Canvas", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}