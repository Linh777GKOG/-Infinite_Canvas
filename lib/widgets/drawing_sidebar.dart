import 'package:flutter/material.dart';

class DrawingSidebar extends StatelessWidget {
  final double currentWidth;
  final double currentOpacity;
  final Color currentColor;
  final ValueChanged<double> onWidthChanged;
  final ValueChanged<double> onOpacityChanged;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onColorTap;
  final bool isEraser;
  final VoidCallback onToggleTool;

  const DrawingSidebar({
    super.key,
    required this.currentWidth,
    required this.currentOpacity,
    required this.currentColor,
    required this.onWidthChanged,
    required this.onOpacityChanged,
    required this.onUndo,
    required this.onRedo,
    required this.onColorTap,
    required this.isEraser,
    required this.onToggleTool,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44, // 🔥 Thu nhỏ chiều ngang (cũ là 50)
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95), // Hơi trong suốt 1 xíu
          borderRadius: BorderRadius.circular(22), // Bo tròn mềm mại hơn
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(2, 4))
          ]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Vòng tròn màu
          GestureDetector(
            onTap: onColorTap,
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                  color: currentColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[200]!, width: 3), // Viền mỏng tinh tế
                  boxShadow: [BoxShadow(color: currentColor.withOpacity(0.3), blurRadius: 4)]
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 2. Công cụ (Brush/Eraser)
          GestureDetector(
            onTap: onToggleTool,
            child: Icon(
              isEraser ? Icons.cleaning_services_outlined : Icons.brush_outlined, // Dùng icon mảnh (outlined)
              color: Colors.black87,
              size: 24,
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(indent: 8, endIndent: 8, height: 1),
          ),

          // 3. Slider Size (Rút ngắn chiều cao)
          SizedBox(
            height: 120, // 🔥 GIẢM TỪ 150 XUỐNG 120
            child: RotatedBox(quarterTurns: 3, child: _ModernSlider(value: currentWidth, min: 1, max: 100, onChanged: onWidthChanged)),
          ),
          const Text("Size", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Colors.black45)),

          const SizedBox(height: 8),

          // 4. Slider Opacity
          SizedBox(
            height: 120, // 🔥 GIẢM TỪ 150 XUỐNG 120
            child: RotatedBox(quarterTurns: 3, child: _ModernSlider(value: currentOpacity, min: 0, max: 1, onChanged: onOpacityChanged)),
          ),
          const Text("Opac", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Colors.black45)),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(indent: 8, endIndent: 8, height: 1),
          ),

          // 5. Undo/Redo
          _buildTinyBtn(Icons.undo_rounded, onUndo),
          const SizedBox(height: 4),
          _buildTinyBtn(Icons.redo_rounded, onRedo),
        ],
      ),
    );
  }

  Widget _buildTinyBtn(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 20, color: Colors.black87),
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
      splashRadius: 15,
    );
  }
}

class _ModernSlider extends StatelessWidget {
  final double value;
  final double min, max;
  final ValueChanged<double> onChanged;
  const _ModernSlider({required this.value, required this.min, required this.max, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 3,
        activeTrackColor: Colors.black87,
        inactiveTrackColor: Colors.grey[200],
        thumbColor: Colors.black,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5), // Nút kéo nhỏ lại
        overlayShape: SliderComponentShape.noOverlay,
      ),
      child: Slider(value: value, min: min, max: max, onChanged: onChanged),
    );
  }
}