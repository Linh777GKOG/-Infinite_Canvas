import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProcreateColorPicker extends StatefulWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorChanged;

  const ProcreateColorPicker({
    super.key,
    required this.currentColor,
    required this.onColorChanged,
  });

  @override
  State<ProcreateColorPicker> createState() => _ProcreateColorPickerState();
}

class _ProcreateColorPickerState extends State<ProcreateColorPicker> {
  late HSVColor _hsvColor;
  final TextEditingController _hexController = TextEditingController();

  // Bảng màu gợi ý (Pastel & Vivid)
  final List<Color> _swatches = [
    const Color(0xFF000000), const Color(0xFFFFFFFF), const Color(0xFFFF3B30),
    const Color(0xFFFF9500), const Color(0xFFFFCC00), const Color(0xFF4CD964),
    const Color(0xFF5AC8FA), const Color(0xFF007AFF), const Color(0xFF5856D6),
    const Color(0xFFFF2D55), const Color(0xFFE0E0E0), const Color(0xFF8E8E93),
  ];

  @override
  void initState() {
    super.initState();
    _hsvColor = HSVColor.fromColor(widget.currentColor);
    _hexController.text = _colorToHex(widget.currentColor);
  }

  void _updateColor(HSVColor color) {
    setState(() {
      _hsvColor = color;
      _hexController.text = _colorToHex(color.toColor());
    });
    widget.onColorChanged(color.toColor());
  }

  String _colorToHex(Color color) =>
      color.value.toRadixString(16).padLeft(8, '0').toUpperCase().substring(2);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 340,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: SingleChildScrollView( // Tránh lỗi overflow khi hiện bàn phím
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Header & Close Button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Select Color", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black87)),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.black54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // 2. Main Color Area (Saturation & Value)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: AspectRatio(
                  aspectRatio: 1.5, // Hình chữ nhật ngang nhẹ
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _SaturationValueBox(
                      hsvColor: _hsvColor,
                      onColorChanged: _updateColor,
                    ),
                  ),
                ),
              ),

              // 3. Hue Slider (Thanh 7 màu)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: SizedBox(
                  height: 24, // Chiều cao thanh trượt
                  child: _HueSlider(
                    hsvColor: _hsvColor,
                    onColorChanged: _updateColor,
                  ),
                ),
              ),

              // 4. Hex Input & Preview
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    // Preview Circle
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: _hsvColor.toColor(),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200, width: 1),
                        boxShadow: [BoxShadow(color: _hsvColor.toColor().withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Hex Field
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text("#", style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _hexController,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 1),
                                decoration: const InputDecoration(border: InputBorder.none),
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(6),
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
                                ],
                                onSubmitted: (value) {
                                  if (value.length == 6) {
                                    try {
                                      _updateColor(HSVColor.fromColor(Color(int.parse("0xFF$value"))));
                                    } catch (_) {}
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // 5. Swatches (Bảng màu gợi ý)
              Container(
                padding: const EdgeInsets.all(20),
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _swatches.map((color) => GestureDetector(
                    onTap: () => _updateColor(HSVColor.fromColor(color)),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12),
                        boxShadow: color == _hsvColor.toColor()
                            ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6, spreadRadius: 2)]
                            : null,
                      ),
                    ),
                  )).toList().sublist(0, 7), // Chỉ lấy 7 màu đầu cho đẹp, hoặc dùng GridView nếu nhiều
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET 1: Hộp chọn màu chính (Saturation & Value) ---
class _SaturationValueBox extends StatelessWidget {
  final HSVColor hsvColor;
  final ValueChanged<HSVColor> onColorChanged;

  const _SaturationValueBox({required this.hsvColor, required this.onColorChanged});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onPanUpdate: (d) => _handleGesture(d.localPosition, constraints.biggest),
        onTapDown: (d) => _handleGesture(d.localPosition, constraints.biggest),
        child: CustomPaint(
          size: Size.infinite,
          painter: _SaturationValuePainter(hsvColor),
        ),
      );
    });
  }

  void _handleGesture(Offset position, Size size) {
    final saturation = (position.dx / size.width).clamp(0.0, 1.0);
    final value = 1.0 - (position.dy / size.height).clamp(0.0, 1.0);
    onColorChanged(hsvColor.withSaturation(saturation).withValue(value));
  }
}

class _SaturationValuePainter extends CustomPainter {
  final HSVColor hsv;
  _SaturationValuePainter(this.hsv);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Lớp 1: Màu Hue nền
    final paintHue = Paint()..color = HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor();
    canvas.drawRect(rect, paintHue);

    // Lớp 2: Gradient Trắng (Ngang) -> Saturation
    final paintSat = Paint()..shader = const LinearGradient(
      colors: [Colors.white, Colors.transparent],
      begin: Alignment.centerLeft, end: Alignment.centerRight,
    ).createShader(rect);
    canvas.drawRect(rect, paintSat);

    // Lớp 3: Gradient Đen (Dọc) -> Value (Độ sáng)
    final paintVal = Paint()..shader = const LinearGradient(
      colors: [Colors.transparent, Colors.black],
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
    ).createShader(rect);
    canvas.drawRect(rect, paintVal);

    // Vẽ con trỏ (Cursor)
    final dx = hsv.saturation * size.width;
    final dy = (1 - hsv.value) * size.height;
    final center = Offset(dx, dy);

    // Bóng đổ nhẹ cho con trỏ
    canvas.drawCircle(center, 9, Paint()..color = Colors.black26..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    // Viền trắng dày
    canvas.drawCircle(center, 7, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2.5);
    // Viền đen mỏng
    canvas.drawCircle(center, 7, Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 0.5);
  }
  @override
  bool shouldRepaint(covariant _SaturationValuePainter old) => old.hsv != hsv;
}

// --- WIDGET 2: Thanh trượt 7 màu (Hue Slider) ---
class _HueSlider extends StatelessWidget {
  final HSVColor hsvColor;
  final ValueChanged<HSVColor> onColorChanged;

  const _HueSlider({required this.hsvColor, required this.onColorChanged});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onPanUpdate: (d) => _handleGesture(d.localPosition, constraints.maxWidth),
        onTapDown: (d) => _handleGesture(d.localPosition, constraints.maxWidth),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF0000), Color(0xFFFFFF00), Color(0xFF00FF00),
                Color(0xFF00FFFF), Color(0xFF0000FF), Color(0xFFFF00FF), Color(0xFFFF0000)
              ],
            ),
          ),
          child: CustomPaint(
            size: Size.infinite,
            painter: _HueThumbPainter(hsvColor.hue),
          ),
        ),
      );
    });
  }

  void _handleGesture(Offset position, double width) {
    final hue = (position.dx / width * 360).clamp(0.0, 360.0);
    onColorChanged(hsvColor.withHue(hue));
  }
}

class _HueThumbPainter extends CustomPainter {
  final double hue;
  _HueThumbPainter(this.hue);

  @override
  void paint(Canvas canvas, Size size) {
    final dx = (hue / 360) * size.width;
    final center = Offset(dx, size.height / 2);
    final height = size.height + 4; // Thumb cao hơn thanh một chút

    // Vẽ thanh trượt (Thumb) hình chữ nhật bo góc hoặc hình tròn
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 14, height: height),
      const Radius.circular(6),
    );

    // Bóng đổ
    canvas.drawRRect(rrect.shift(const Offset(0, 2)), Paint()..color = Colors.black26..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    // Thân trắng
    canvas.drawRRect(rrect, Paint()..color = Colors.white);
  }
  @override
  bool shouldRepaint(covariant _HueThumbPainter old) => old.hue != hue;
}