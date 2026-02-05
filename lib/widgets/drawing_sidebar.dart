import 'package:flutter/material.dart';

class DrawingSidebar extends StatefulWidget {
  final double currentWidth;
  final double currentOpacity;
  final Color currentColor;
  final Function(double) onWidthChanged;
  final Function(double) onOpacityChanged;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onColorTap;

  // Các công cụ
  final dynamic activeTool;
  final VoidCallback onSelectBrush;
  final VoidCallback onSelectEraser;
  final VoidCallback onSelectHand;
  final VoidCallback onSelectText;
  final VoidCallback? onSelectLasso;

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
    required this.activeTool,
    required this.onSelectBrush,
    required this.onSelectEraser,
    required this.onSelectHand,
    required this.onSelectText,
    this.onSelectLasso,
  });

  @override
  State<DrawingSidebar> createState() => _DrawingSidebarState();
}

class _DrawingSidebarState extends State<DrawingSidebar> {
  // Dùng để định vị vị trí popup
  final LayerLink _sizeLink = LayerLink();
  final LayerLink _opacityLink = LayerLink();

  // Quản lý Overlay (Cửa sổ nổi)
  OverlayEntry? _overlayEntry;
  String _activePopup = ''; // 'size', 'opacity' hoặc ''

  // Hàm đóng popup
  void _closePopup() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _activePopup = '';
    });
  }

  // Hàm mở popup slider
  void _showSliderPopup({
    required BuildContext context,
    required LayerLink link,
    required String type, // 'size' hoặc 'opacity'
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
  }) {
    // Nếu đang mở đúng cái này thì đóng lại (Toggle)
    if (_activePopup == type) {
      _closePopup();
      return;
    }

    // Đóng cái cũ nếu đang mở cái khác
    _closePopup();

    setState(() {
      _activePopup = type;
    });

    // Tạo Overlay mới
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: 200, // Chiều dài thanh trượt popup
          height: 48,
          child: CompositedTransformFollower(
            link: link,
            showWhenUnlinked: false,
            offset: const Offset(55, 0), // Xuất hiện lệch sang phải 55px
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Text(
                    type == 'size' ? "Size" : "Opac",
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                      ),
                      child: StatefulBuilder(
                          builder: (context, setStateSlider) {
                            return Slider(
                              value: type == 'size' ? widget.currentWidth : widget.currentOpacity,
                              min: min,
                              max: max,
                              activeColor: type == 'size' ? Colors.black : Colors.blue,
                              inactiveColor: Colors.grey[200],
                              onChanged: (val) {
                                setStateSlider(() {}); // Cập nhật slider UI
                                onChanged(val); // Gọi callback ra ngoài
                              },
                            );
                          }
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Chèn vào màn hình
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _closePopup(); // Dọn dẹp khi widget bị hủy
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isBrush = widget.activeTool.toString().contains('brush');
    bool isEraser = widget.activeTool.toString().contains('eraser');
    bool isHand = widget.activeTool.toString().contains('hand');
    bool isText = widget.activeTool.toString().contains('text');
    bool isLasso = widget.activeTool.toString().contains('lasso');

    return Container(
      width: 50,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. MÀU SẮC (Color Picker)
          GestureDetector(
            onTap: widget.onColorTap,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.currentColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, indent: 10, endIndent: 10),
          const SizedBox(height: 8),

          // 2. CÔNG CỤ (Tools)
          _buildToolIcon(Icons.brush, isBrush, widget.onSelectBrush),
          _buildToolIcon(Icons.cleaning_services_rounded, isEraser, widget.onSelectEraser),
          if (widget.onSelectLasso != null)
            _buildToolIcon(Icons.gesture, isLasso, widget.onSelectLasso!),
          _buildToolIcon(Icons.pan_tool, isHand, widget.onSelectHand),
          _buildToolIcon(Icons.text_fields, isText, widget.onSelectText),

          const SizedBox(height: 8),
          const Divider(height: 1, indent: 10, endIndent: 10),
          const SizedBox(height: 16),

          // 3. NÚT CHỈNH SIZE (Popup Slider)
          CompositedTransformTarget(
            link: _sizeLink,
            child: IconButton(
              icon: Icon(
                Icons.circle, // Icon hình tròn biểu thị size
                size: 14 + (widget.currentWidth / 5).clamp(0, 14), // Icon to nhỏ theo size thật
                color: _activePopup == 'size' ? Colors.blue : Colors.black87,
              ),
              onPressed: () => _showSliderPopup(
                context: context,
                link: _sizeLink,
                type: 'size',
                value: widget.currentWidth,
                min: 1.0,
                max: 50.0,
                onChanged: widget.onWidthChanged,
              ),
              tooltip: 'Chỉnh kích thước',
            ),
          ),

          const SizedBox(height: 8),

          // 4. NÚT CHỈNH OPACITY (Popup Slider)
          CompositedTransformTarget(
            link: _opacityLink,
            child: IconButton(
              icon: Icon(
                Icons.opacity,
                color: (_activePopup == 'opacity' ? Colors.blue : Colors.black87)
                    .withOpacity(0.5 + (widget.currentOpacity / 2)), // Icon mờ theo opacity thật
              ),
              onPressed: () => _showSliderPopup(
                context: context,
                link: _opacityLink,
                type: 'opacity',
                value: widget.currentOpacity,
                min: 0.1,
                max: 1.0,
                onChanged: widget.onOpacityChanged,
              ),
              tooltip: 'Chỉnh độ mờ',
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, indent: 10, endIndent: 10),
          const SizedBox(height: 8),

          // 5. UNDO / REDO
          IconButton(
            icon: const Icon(Icons.undo, color: Colors.black54),
            onPressed: widget.onUndo,
            tooltip: 'Hoàn tác',
          ),
          IconButton(
            icon: const Icon(Icons.redo, color: Colors.black54),
            onPressed: widget.onRedo,
            tooltip: 'Làm lại',
          ),
        ],
      ),
    );
  }

  Widget _buildToolIcon(IconData icon, bool isActive, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon),
      color: isActive ? Colors.blueAccent : Colors.black87,
      onPressed: onTap,
    );
  }
}