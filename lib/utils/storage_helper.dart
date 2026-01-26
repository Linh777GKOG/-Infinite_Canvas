import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../models/drawing_models.dart';

class StorageHelper {

  // Lấy đường dẫn thư mục tài liệu của ứng dụng
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // 1. LƯU TRANH (Dữ liệu JSON + Ảnh Thumbnail)
  static Future<void> saveDrawing(String id, List<Stroke> strokes, Uint8List thumbnailBytes) async {
    final path = await _localPath;

    // a. Lưu dữ liệu nét vẽ (JSON)
    final fileData = File('$path/$id.json');
    List<Map<String, dynamic>> jsonList = strokes.map((s) => s.toJson()).toList();
    await fileData.writeAsString(json.encode(jsonList));

    // b. Lưu ảnh thumbnail (PNG)
    final fileThumb = File('$path/$id.png');
    await fileThumb.writeAsBytes(thumbnailBytes);
  }

  // 2. LOAD TRANH
  static Future<List<Stroke>> loadDrawing(String id) async {
    try {
      final path = await _localPath;
      final file = File('$path/$id.json');
      String contents = await file.readAsString();
      List<dynamic> jsonList = json.decode(contents);

      return jsonList.map((j) => Stroke.fromJson(j)).toList();
    } catch (e) {
      return []; // Nếu lỗi hoặc file mới thì trả về rỗng
    }
  }

  // 3. LẤY DANH SÁCH TẤT CẢ TRANH
  static Future<List<Map<String, dynamic>>> getAllDrawings() async {
    final path = await _localPath;
    final dir = Directory(path);
    List<Map<String, dynamic>> drawings = [];

    if (await dir.exists()) {
      // Quét tất cả file .json trong thư mục
      final List<FileSystemEntity> entities = await dir.list().toList();
      for (var entity in entities) {
        if (entity.path.endsWith('.json')) {
          String id = entity.uri.pathSegments.last.replaceAll('.json', '');
          String thumbPath = '$path/$id.png';

          // Lấy ngày sửa đổi
          DateTime lastMod = (await entity.stat()).modified;

          drawings.add({
            'id': id,
            'thumbPath': thumbPath,
            'date': lastMod,
          });
        }
      }
    }
    // Sắp xếp mới nhất lên đầu
    drawings.sort((a, b) => b['date'].compareTo(a['date']));
    return drawings;
  }
}