import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/drawing_models.dart';

// 1. Enum GridType
enum GridType { lines, dots, none }

// 2. DrawPainter: Vẽ các nét bút, ảnh và text
class DrawPainter extends CustomPainter {
  final List<Stroke> strokes;
  final List<ImportedImage> images;
  final List<CanvasText> texts;
  final Color? canvasColor;
  final bool isPreview;

  late final bool _hasEraser;

  DrawPainter(
      this.strokes,
      this.images, {
        this.texts = const [],
        this.canvasColor,
        this.isPreview = false,
      }) {
    _hasEraser = !isPreview && strokes.any((s) => s.isEraser);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Vẽ Ảnh
    for (final img in images) {
      final w = img.image.width * img.scale;
      final h = img.image.height * img.scale;
      canvas.save();
      canvas.translate(img.position.dx + w / 2, img.position.dy + h / 2);
      canvas.rotate(img.rotation);
      canvas.translate(-w / 2, -h / 2);
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, w, h),
        image: img.image,
        fit: BoxFit.fill,
      );
      canvas.restore();
    }

    if (_hasEraser) {
      canvas.saveLayer(null, Paint());
    }

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Vẽ Nét Bút
    for (final stroke in strokes) {
      paint.strokeWidth = stroke.width;
      if (stroke.isEraser) {
        if (isPreview && canvasColor != null) {
          paint.color = canvasColor!;
          paint.blendMode = BlendMode.srcOver;
        } else {
          paint.color = Colors.transparent;
          paint.blendMode = BlendMode.clear;
        }
      } else {
        paint.color = stroke.color;
        paint.blendMode = BlendMode.srcOver;
      }

      if (stroke.points.isEmpty) continue;
      if (stroke.points.length == 1) {
        canvas.drawPoints(ui.PointMode.points, stroke.points, paint);
        continue;
      }

      final path = Path();
      path.moveTo(stroke.points[0].dx, stroke.points[0].dy);
      for (int i = 0; i < stroke.points.length - 1; i++) {
        final p0 = stroke.points[i];
        final p1 = stroke.points[i + 1];
        final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
        if (i == 0) {
          path.lineTo(mid.dx, mid.dy);
        } else {
          path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
        }
      }
      path.lineTo(stroke.points.last.dx, stroke.points.last.dy);
      canvas.drawPath(path, paint);
    }

    if (_hasEraser) {
      canvas.restore();
    }

    // Vẽ Text
    for (final t in texts) {
      if (t.text.trim().isEmpty) continue;
      final textPainter = TextPainter(
        text: TextSpan(
          text: t.text,
          style: TextStyle(
            color: t.color,
            fontSize: t.fontSize,
            fontWeight: t.fontWeight,
            fontFamily: t.fontFamily,
            fontStyle: t.italic ? FontStyle.italic : FontStyle.normal,
            decoration: t.underline ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
        textAlign: t.align,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: t.maxWidth ?? double.infinity);

      final extraPad = t.backgroundColor == null ? 0.0 : t.padding * 2;
      final baseW = textPainter.width + extraPad;
      final baseH = textPainter.height + extraPad;
      final w = baseW * t.scale;
      final h = baseH * t.scale;

      canvas.save();
      canvas.translate(t.position.dx + w / 2, t.position.dy + h / 2);
      canvas.rotate(t.rotation);
      canvas.scale(t.scale);
      canvas.translate(-baseW / 2, -baseH / 2);

      if (t.backgroundColor != null) {
        final bgPaint = Paint()..color = t.backgroundColor!;
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, baseW, baseH), const Radius.circular(8)),
          bgPaint,
        );
      }
      textPainter.paint(canvas, t.backgroundColor == null ? Offset.zero : Offset(t.padding, t.padding));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant DrawPainter oldDelegate) => true;
}

// 3. GridPainter: Sửa lỗi Vector3/Offset
class GridPainter extends CustomPainter {
  final double gridSize;
  final GridType gridType;
  final Color gridColor;
  final TransformationController? controller;

  GridPainter({
    required this.gridSize,
    required this.gridType,
    required this.gridColor,
    this.controller,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (gridType == GridType.none) return;

    final majorPaint = Paint()
      ..color = gridColor.withOpacity(0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // --- TỐI ƯU HÓA VIEWPORT ---
    double startX = 0;
    double endX = size.width;
    double startY = 0;
    double endY = size.height;

    if (controller != null) {
      final Matrix4 matrix = controller!.value;
      final double scale = matrix.getMaxScaleOnAxis();

      // 🔥 SỬA LỖI TẠI ĐÂY: Xóa chữ 'Offset' đi, để 'final' tự nhận diện Vector3
      final translationVector = matrix.getTranslation();

      final double transX = translationVector.x; // Giờ nó sẽ hiểu .x
      final double transY = translationVector.y; // và .y

      const double viewportW = 3000.0;
      const double viewportH = 3000.0;

      startX = (-transX / scale).clamp(0.0, size.width);
      startY = (-transY / scale).clamp(0.0, size.height);
      endX = ((-transX + viewportW) / scale).clamp(0.0, size.width);
      endY = ((-transY + viewportH) / scale).clamp(0.0, size.height);
    }

    startX = (startX / gridSize).floor() * gridSize;
    startY = (startY / gridSize).floor() * gridSize;

    if (gridType == GridType.lines) {
      for (double x = startX; x <= endX; x += gridSize) {
        canvas.drawLine(Offset(x, startY), Offset(x, endY), majorPaint);
      }
      for (double y = startY; y <= endY; y += gridSize) {
        canvas.drawLine(Offset(startX, y), Offset(endX, y), majorPaint);
      }
    } else if (gridType == GridType.dots) {
      final dotPaint = Paint()..color = gridColor.withOpacity(0.25)..style = PaintingStyle.fill;
      for (double x = startX; x <= endX; x += gridSize) {
        for (double y = startY; y <= endY; y += gridSize) {
          canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.gridType != gridType ||
        oldDelegate.gridSize != gridSize ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.controller != controller;
  }
}

// 4. SelectionPainter
class SelectionPainter extends CustomPainter {
  final ImportedImage? selectedImage;
  final CanvasText? selectedText;
  final double viewportScale;

  SelectionPainter({this.selectedImage, this.selectedText, required this.viewportScale});

  @override
  void paint(Canvas canvas, Size size) {
    Rect? rect; Offset? center; double? rotation;
    if (selectedImage != null) {
      final img = selectedImage!;
      final w = img.image.width * img.scale;
      final h = img.image.height * img.scale;
      center = Offset(img.position.dx + w / 2, img.position.dy + h / 2);
      rotation = img.rotation;
      rect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    } else if (selectedText != null) {
      final t = selectedText!;
      if (t.text.trim().isEmpty) return;
      final textPainter = TextPainter(
        text: TextSpan(text: t.text, style: TextStyle(color: t.color, fontSize: t.fontSize, fontWeight: t.fontWeight, fontFamily: t.fontFamily, fontStyle: t.italic ? FontStyle.italic : FontStyle.normal, decoration: t.underline ? TextDecoration.underline : TextDecoration.none)),
        textAlign: t.align, textDirection: TextDirection.ltr,
      )..layout(maxWidth: t.maxWidth ?? double.infinity);
      final extraPad = t.backgroundColor == null ? 0.0 : t.padding * 2;
      final w = (textPainter.width + extraPad) * t.scale;
      final h = (textPainter.height + extraPad) * t.scale;
      center = Offset(t.position.dx + w / 2, t.position.dy + h / 2);
      rotation = t.rotation;
      rect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    }

    if (rect != null && center != null && rotation != null) {
      final framePaint = Paint()..color = Colors.blueAccent.withOpacity(0.9)..style = PaintingStyle.stroke..strokeWidth = (2.0 / viewportScale).clamp(1.0, 3.0);
      final handleRadius = (7.0 / viewportScale).clamp(2.0, 14.0);
      final handleGap = (18.0 / viewportScale).clamp(6.0, 32.0);
      final handleFillPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
      final handleStrokePaint = Paint()..color = Colors.blueAccent.withOpacity(0.95)..style = PaintingStyle.stroke..strokeWidth = (2.0 / viewportScale).clamp(1.0, 3.0);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);
      canvas.drawRect(rect, framePaint);
      final corners = <Offset>[rect.topLeft, rect.topRight, rect.bottomRight, rect.bottomLeft];
      for (final p in corners) {
        canvas.drawCircle(p, handleRadius, handleFillPaint);
        canvas.drawCircle(p, handleRadius, handleStrokePaint);
      }
      final rotateHandlePos = Offset(0, rect.top - handleGap);
      canvas.drawLine(Offset(0, rect.top), rotateHandlePos, handleStrokePaint);
      canvas.drawCircle(rotateHandlePos, handleRadius, handleFillPaint);
      canvas.drawCircle(rotateHandlePos, handleRadius, handleStrokePaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant SelectionPainter oldDelegate) => true;
}

// 5. LassoSelectionPainter
class LassoSelectionPainter extends CustomPainter {
  final List<Offset> lassoPoints;
  final Set<String> selectedStrokeIds;
  final List<DrawingLayer> layers;
  final double scale;

  LassoSelectionPainter({
    required this.lassoPoints,
    required this.selectedStrokeIds,
    required this.layers,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (lassoPoints.isNotEmpty) {
      final paint = Paint()
        ..color = Colors.black87
        ..strokeWidth = 2 / scale
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(lassoPoints.first.dx, lassoPoints.first.dy);
      for (int i = 1; i < lassoPoints.length; i++) {
        path.lineTo(lassoPoints[i].dx, lassoPoints[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    if (selectedStrokeIds.isNotEmpty) {
      final highlightPaint = Paint()
        ..color = Colors.blueAccent.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      for (var layer in layers) {
        if (!layer.isVisible) continue;
        for (var stroke in layer.strokes) {
          if (selectedStrokeIds.contains(stroke.id)) {
            highlightPaint.strokeWidth = stroke.width + (6.0 / scale);
            if (stroke.points.isNotEmpty) {
              final path = Path();
              path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
              for (int i = 1; i < stroke.points.length; i++) {
                final p0 = stroke.points[i - 1];
                final p1 = stroke.points[i];
                final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
                if (i == 1) {
                  path.lineTo(mid.dx, mid.dy);
                } else {
                  path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
                }
              }
              path.lineTo(stroke.points.last.dx, stroke.points.last.dy);
              canvas.drawPath(path, highlightPaint);
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant LassoSelectionPainter oldDelegate) => true;
}