import 'package:flutter/material.dart';

class DrawingToolbar extends StatelessWidget {
  final VoidCallback onBack; // 🔥 THÊM: Hàm xử lý khi bấm nút Quay về
  final VoidCallback onSave;
  final VoidCallback onSettingsSelect;
  final String zoomLevel;

  const DrawingToolbar({
    super.key,
    required this.onBack, // 🔥 Yêu cầu truyền hàm này vào
    required this.onSave,
    required this.onSettingsSelect,
    required this.zoomLevel,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            // --- CỤM BÊN TRÁI ---
            // 🔥 NÚT BACK CHÍNH LÀ NÚT NÀY (GRID VIEW)
            _buildSquareBtn(Icons.grid_view_rounded, onTap: onBack),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                "Untitled 2",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            // --- CỤM BÊN PHẢI ---
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(zoomLevel, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 10),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(4)),
                  child: const Text("PRO", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
                ),
                const SizedBox(width: 8),

                _buildIconBtn(Icons.download_rounded, onTap: onSave),
                _buildIconBtn(Icons.upload_rounded, onTap: () {}),
                _buildIconBtn(Icons.settings_outlined, onTap: onSettingsSelect),
                _buildIconBtn(Icons.help_outline, onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, {required VoidCallback onTap}) {
    return IconButton(
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      padding: const EdgeInsets.all(4),
      icon: Icon(icon, color: Colors.black87, size: 24),
      onPressed: onTap,
      splashRadius: 20,
    );
  }

  // Widget nút hình vuông bo góc (Giống Concepts)
  Widget _buildSquareBtn(IconData icon, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            // Tạo bóng đổ nhẹ để nổi lên nền xám
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
        ),
        child: Icon(icon, color: Colors.black87, size: 22),
      ),
    );
  }
}