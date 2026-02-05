import 'dart:math' as math;
import 'package:flutter/material.dart';

// 1. Enum xác định người dùng đang chạm vào đâu
enum TransformHandle { none, scale, rotate }

// 2. Class tính toán vị trí tay cầm và va chạm
class SelectionHandles {
  final Offset center;
  final double rotation;
  final double width;
  final double height;
  final double handleRadius;
  final double rotateRadius;
  final double rotateGap;

  const SelectionHandles({
    required this.center,
    required this.rotation,
    required this.width,
    required this.height,
    required this.handleRadius,
    required this.rotateRadius,
    required this.rotateGap,
  });

  // Kiểm tra xem người dùng có chạm vào tay cầm nào không
  TransformHandle hitTest(Offset scenePos) {
    final halfW = width / 2;
    final halfH = height / 2;

    // Tính tọa độ 4 góc đã xoay
    // (Dùng để xác định vị trí tay cầm Scale)
    final corners = <Offset>[
      Offset(-halfW, -halfH), // Góc trên trái
      Offset(halfW, -halfH),  // Góc trên phải
      Offset(halfW, halfH),   // Góc dưới phải
      Offset(-halfW, halfH),  // Góc dưới trái
    ].map((p) => center + _rotateOffset(p, rotation)).toList();

    // Tính tọa độ tay cầm Xoay (nằm phía trên hình)
    final rotHandle = center + _rotateOffset(Offset(0, -halfH - rotateGap), rotation);

    // 1. Kiểm tra chạm vào 4 góc (Scale)
    for (final c in corners) {
      if ((scenePos - c).distance <= handleRadius * 1.5) {
        // * 1.5 để vùng chạm rộng hơn chút cho dễ bấm
        return TransformHandle.scale;
      }
    }

    // 2. Kiểm tra chạm vào nút Xoay (Rotate)
    if ((scenePos - rotHandle).distance <= rotateRadius * 1.5) {
      return TransformHandle.rotate;
    }

    return TransformHandle.none;
  }

  // Hàm hỗ trợ: Xoay một điểm quanh gốc tọa độ (0,0)
  static Offset _rotateOffset(Offset p, double radians) {
    final c = math.cos(radians);
    final s = math.sin(radians);
    return Offset(p.dx * c - p.dy * s, p.dx * s + p.dy * c);
  }

  // Hàm hỗ trợ: Kiểm tra một điểm có nằm trong hình chữ nhật đã xoay không
  static bool isPointInRotatedRect({
    required Offset point,
    required Offset center,
    required double width,
    required double height,
    required double rotation,
  }) {
    // 1. Dời gốc tọa độ về tâm hình (Translate)
    final p = point - center;

    // 2. Xoay ngược điểm đó một góc -rotation (Inverse Rotate)
    final c = math.cos(-rotation);
    final s = math.sin(-rotation);
    final local = Offset(p.dx * c - p.dy * s, p.dx * s + p.dy * c);

    // 3. Kiểm tra trong hệ tọa độ thẳng (AABB)
    return local.dx.abs() <= width / 2 && local.dy.abs() <= height / 2;
  }
}