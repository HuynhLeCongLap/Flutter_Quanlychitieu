import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/AppDatabase.dart'; 
import 'add_transaction_form.dart';
import 'category_management_screen.dart'; 
import '../model/transaction.dart' as my_model;
import 'report_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _transactions = [];
  double _totalBalance = 0;
  bool _isLoading = true;

  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() async {
    setState(() => _isLoading = true);
    final data = await AppDatabase.instance.getAllTransactions();

    double total = 0;
    for (var item in data) {
      double amount = item['amount'];
      bool isExpense = (item['is_expense'] == 1);
      if (isExpense) {
        total -= amount;
      } else {
        total += amount;
      }
    }

    if (mounted) {
      setState(() {
        _transactions = data;
        _totalBalance = total;
        _isLoading = false;
      });
    }
  }

  void _deleteTransaction(int id) async {
    await AppDatabase.instance.delete(id);
    _refreshData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa giao dịch!')),
    );
  }

  // Hàm mở form: Hỗ trợ cả Thêm mới và Sửa
  void _showTransactionModal({my_model.Transaction? transaction}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Full màn hình khi cần
      builder: (_) => AddTransactionForm(
        onSave: _refreshData,
        existingTransaction: transaction, // Truyền vào nếu là Sửa
        onDelete: _deleteTransaction,     // Truyền hàm xóa vào để gọi từ form
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sổ Thu Chi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Nút xem Báo cáo (MỚI THÊM)
          IconButton(
            icon: const Icon(Icons.pie_chart), // Icon hình biểu đồ bánh
            tooltip: 'Báo cáo thống kê',
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const ReportScreen())
              );
            },
          ),  

          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Tổng tiền
                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  color: Colors.green.shade50,
                  child: Column(
                    children: [
                      const Text('Tổng số dư hiện tại',
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 10),
                      Text(
                        currencyFormat.format(_totalBalance),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _totalBalance >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),

                // Danh sách giao dịch
                Expanded(
                  child: _transactions.isEmpty
                      ? const Center(child: Text("Chưa có giao dịch nào"))
                      : ListView.builder(
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            final item = _transactions[index];
                            final bool isExpense = (item['is_expense'] == 1);
                            
                            // Tạo object transaction để truyền đi khi Sửa
                            final txObj = my_model.Transaction(
                                id: item['id'],
                                amount: item['amount'],
                                note: item['note'],
                                date: DateTime.parse(item['date']),
                                categoryId: item['category_id'],
                            );

                            return Dismissible(
                              key: Key(item['id'].toString()),
                              direction: DismissDirection.endToStart,
                              // --- THÊM: Hộp thoại xác nhận khi vuốt xóa ---
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Xác nhận"),
                                    content: const Text("Bạn có chắc muốn xóa giao dịch này không?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(false),
                                        child: const Text("Hủy"),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(true),
                                        child: const Text("Xóa", style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              // ---------------------------------------------
                              onDismissed: (direction) {
                                _deleteTransaction(item['id']);
                              },
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              child: Card(
                                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                // InkWell để tạo hiệu ứng khi bấm vào
                                child: InkWell(
                                  onTap: () {
                                    // Bấm vào thì mở form Sửa
                                    _showTransactionModal(transaction: txObj);
                                  },
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Color(item['color_value']).withOpacity(0.2),
                                      child: Icon(
                                        IconData(item['icon_code'], fontFamily: 'MaterialIcons'),
                                        color: Color(item['color_value']),
                                      ),
                                    ),
                                    title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(
                                      "${item['note']} \n${dateFormat.format(DateTime.parse(item['date']))}",
                                    ),
                                    isThreeLine: true,
                                    trailing: Text(
                                      currencyFormat.format(item['amount']),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isExpense ? Colors.red : Colors.green,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionModal(), // Thêm mới (không truyền tham số)
        child: const Icon(Icons.add),
      ),
    );
  }
}