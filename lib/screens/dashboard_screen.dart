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
  List<Map<String, dynamic>> _filteredTransactions = [];
  double _totalBalance = 0;
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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
      _filterTransactions();
    }
  }

  // Hàm tìm kiếm giao dịch
  void _filterTransactions() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredTransactions = _transactions;
      });
    } else {
      setState(() {
        _filteredTransactions = _transactions.where((item) {
          final note = (item['note'] as String).toLowerCase();
          final categoryName = (item['name'] as String).toLowerCase();
          final query = _searchQuery.toLowerCase();
          return note.contains(query) || categoryName.contains(query);
        }).toList();
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
          // Nút xem bảng cân đối chi/thu (MỚI)
          IconButton(
            icon: const Icon(Icons.assessment),
            tooltip: 'Bảng cân đối',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BalanceSummaryScreen())
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

                // Thanh tìm kiếm
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _filterTransactions();
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm giao dịch...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                                _filterTransactions();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                // Danh sách giao dịch (lọc)
                Expanded(
                  child: _filteredTransactions.isEmpty
                      ? Center(
                          child: Text(
                            _searchQuery.isEmpty
                                ? "Chưa có giao dịch nào"
                                : "Không tìm thấy giao dịch nào",
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final item = _filteredTransactions[index];
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

// Màn hình Bảng cân đối chi/thu
class BalanceSummaryScreen extends StatefulWidget {
  const BalanceSummaryScreen({super.key});

  @override
  State<BalanceSummaryScreen> createState() => _BalanceSummaryScreenState();
}

class _BalanceSummaryScreenState extends State<BalanceSummaryScreen> {
  Map<String, dynamic> _summary = {
    'totalIncome': 0.0,
    'totalExpense': 0.0,
    'balance': 0.0,
  };
  bool _isLoading = true;

  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  void _loadSummary() async {
    final transactions = await AppDatabase.instance.getAllTransactions();
    
    double totalIncome = 0;
    double totalExpense = 0;

    for (var item in transactions) {
      double amount = item['amount'];
      bool isExpense = (item['is_expense'] == 1);
      
      if (isExpense) {
        totalExpense += amount;
      } else {
        totalIncome += amount;
      }
    }

    if (mounted) {
      setState(() {
        _summary = {
          'totalIncome': totalIncome,
          'totalExpense': totalExpense,
          'balance': totalIncome - totalExpense,
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng Cân Đối Chi/Thu'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Thu nhập
                  Card(
                    elevation: 4,
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.add_circle, color: Colors.green, size: 28),
                              const SizedBox(width: 10),
                              const Text(
                                'Tổng Thu Nhập',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            currencyFormat.format(_summary['totalIncome']),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Card Chi tiêu
                  Card(
                    elevation: 4,
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.remove_circle, color: Colors.red, size: 28),
                              const SizedBox(width: 10),
                              const Text(
                                'Tổng Chi Tiêu',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            currencyFormat.format(_summary['totalExpense']),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Card Cân đối
                  Card(
                    elevation: 4,
                    color: _summary['balance'] >= 0
                        ? Colors.blue.shade50
                        : Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _summary['balance'] >= 0
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                color: _summary['balance'] >= 0
                                    ? Colors.blue
                                    : Colors.orange,
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Cân Đối (Số Dư)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            currencyFormat.format(_summary['balance']),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: _summary['balance'] >= 0
                                  ? Colors.blue
                                  : Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _summary['balance'] >= 0
                                ? '✓ Bạn đang có số dư dương'
                                : '⚠ Bạn đang âm tiền',
                            style: TextStyle(
                              fontSize: 14,
                              color: _summary['balance'] >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Bảng thống kê chi tiết
                  const Text(
                    'Chi tiết thống kê',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Table(
                    border: TableBorder.all(color: Colors.grey.shade300),
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                        ),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'Loại',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'Số tiền',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'Thu nhập',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              currencyFormat.format(_summary['totalIncome']),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'Chi tiêu',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              currencyFormat.format(_summary['totalExpense']),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                        ),
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'Cân đối',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              currencyFormat.format(_summary['balance']),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _summary['balance'] >= 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}