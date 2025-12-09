import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // Để format tiếng Việt nếu cần
import 'screens/dashboard_screen.dart'; // Import màn hình chính

void main() async {
  // Đảm bảo binding được khởi tạo trước khi chạy app (Best practice)
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo format ngày tháng (optional)
  // await initializeDateFormatting('vi_VN', null);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quản Lý Chi Tiêu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      // Gọi DashboardScreen từ file riêng
      home: const DashboardScreen(),
    );
  }
}