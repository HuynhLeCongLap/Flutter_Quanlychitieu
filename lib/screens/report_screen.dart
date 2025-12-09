import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Thư viện biểu đồ
import 'package:intl/intl.dart';
import '../data/AppDatabase.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = true;
  double _totalExpense = 0; // Tổng chi tiêu để tính phần trăm

  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    // Gọi hàm SQL thống kê bạn vừa viết
    final data = await AppDatabase.instance.getExpenseStatistics();
    
    // Tính tổng tiền chi (để lát chia phần trăm cho biểu đồ)
    double total = 0;
    for (var item in data) {
      total += (item['totalAmount'] as num).toDouble();
    }

    if (mounted) {
      setState(() {
        _data = data;
        _totalExpense = total;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo Cáo Chi Tiêu'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _data.isEmpty
              ? const Center(child: Text("Chưa có dữ liệu chi tiêu tháng này"))
              : Column(
                  children: [
                    const SizedBox(height: 30),
                    // 1. Phần Biểu Đồ Tròn
                    SizedBox(
                      height: 250, // Chiều cao biểu đồ
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2, // Khoảng cách giữa các miếng
                          centerSpaceRadius: 40, // Độ rỗng ở giữa (tạo hình bánh Donut)
                          sections: _data.map((item) {
                            final double amount = (item['totalAmount'] as num).toDouble();
                            final double percent = (amount / _totalExpense) * 100;
                            
                            return PieChartSectionData(
                              color: Color(item['color_value']),
                              value: percent,
                              title: '${percent.toStringAsFixed(1)}%', // Hiển thị số %
                              radius: 60, // Độ to của bán kính
                              titleStyle: const TextStyle(
                                fontSize: 14, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.white,
                                shadows: [Shadow(color: Colors.black, blurRadius: 2)]
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    Text(
                      "Tổng chi: ${currencyFormat.format(_totalExpense)}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // 2. Phần Danh Sách Chi Tiết (Legend)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _data.length,
                        itemBuilder: (context, index) {
                          final item = _data[index];
                          final double amount = (item['totalAmount'] as num).toDouble();
                          final double percent = (amount / _totalExpense) * 100;

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Color(item['color_value']),
                                child: Icon(
                                  IconData(item['icon_code'], fontFamily: 'MaterialIcons'),
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: LinearProgressIndicator(
                                value: percent / 100, // Thanh % nhỏ bên dưới
                                backgroundColor: Colors.grey[200],
                                color: Color(item['color_value']),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(currencyFormat.format(amount), 
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('${percent.toStringAsFixed(1)}%', 
                                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}