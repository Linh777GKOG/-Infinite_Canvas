import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/gallery_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 BƯỚC QUAN TRỌNG:
  // Xóa đoạn code khóa màn hình cũ đi.
  // Thay bằng đoạn này để cho phép xoay mọi hướng:
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pro Art Studio',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF32C5FF),
      ),
      home: const GalleryPage(),
    );
  }
}