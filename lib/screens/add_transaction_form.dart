import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/AppDatabase.dart'; 
import '../model/category.dart';
import '../model/transaction.dart' as my_model;

class AddTransactionForm extends StatefulWidget {
  final VoidCallback onSave;
  final my_model.Transaction? existingTransaction; 
  final Function(int)? onDelete; 

  const AddTransactionForm({
    super.key, 
    required this.onSave,
    this.existingTransaction,
    this.onDelete,
  });

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _dateController = TextEditingController();
  
  List<Category> _categories = [];
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isExpenseController = true; 
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    _initForm();
  }

  void _initForm() async {
    if (widget.existingTransaction != null) {
      final tx = widget.existingTransaction!;
      _amountController.text = tx.amount.toStringAsFixed(0);
      _noteController.text = tx.note;
      _selectedDate = tx.date;
      _dateController.text = DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate);

      final allCatsExpense = await AppDatabase.instance.getCategories(true);
      final allCatsIncome = await AppDatabase.instance.getCategories(false);
      final allCats = [...allCatsExpense, ...allCatsIncome];

      try {
        final catMap = allCats.firstWhere((c) => c['id'] == tx.categoryId);
        _isExpenseController = (catMap['is_expense'] == 1);
      } catch (e) {
        _isExpenseController = true; 
      }
    } else {
      _dateController.text = DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate);
    }

    await _loadCategories(isInit: true);

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadCategories({bool isInit = false}) async {
    final List<Map<String, dynamic>> maps = 
        await AppDatabase.instance.getCategories(_isExpenseController);
    
    if (!mounted) return;

    setState(() {
      _categories = maps.map((e) => Category.fromMap(e)).toList();

      if (isInit && widget.existingTransaction != null) {
        // Lần đầu mở form Sửa: Cố tìm lại category cũ
        try {
          _selectedCategory = _categories.firstWhere(
            (c) => c.id == widget.existingTransaction!.categoryId
          );
        } catch (e) {
          if (_categories.isNotEmpty) _selectedCategory = _categories[0];
        }
      } else {
        // Trường hợp khác: Chọn cái đầu tiên nếu có
        if (_categories.isNotEmpty) {
           _selectedCategory = _categories[0];
        } else {
           _selectedCategory = null;
        }
      }
    });
  }

  // --- HÀM CHUYỂN TAB (ĐÃ SỬA ĐỂ TRÁNH TREO) ---
  void _switchTab(bool isExpense) {
    if (_isExpenseController == isExpense) return; // Nếu đang chọn rồi thì thôi

    setState(() {
      _isExpenseController = isExpense;
      _selectedCategory = null; // Reset lựa chọn ngay lập tức
      _categories = []; // XÓA SẠCH danh sách cũ ngay lập tức để tránh Dropdown vẽ nhầm
    });

    // Sau đó mới tải danh sách mới
    _loadCategories(isInit: false);
  }

  void _showQuickAddCategoryDialog() {
    final nameController = TextEditingController();
    final List<IconData> quickIcons = [
      Icons.fastfood, Icons.shopping_cart, Icons.home, Icons.commute,
      Icons.medical_services, Icons.school, Icons.pets, Icons.sports_soccer,
      Icons.work, Icons.attach_money, Icons.card_giftcard, Icons.savings,
    ];
    
    IconData selectedIcon = quickIcons[0];
    Color selectedColor = _isExpenseController ? Colors.red : Colors.green;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Thêm Danh Mục ${_isExpenseController ? "Chi" : "Thu"}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Tên danh mục', border: OutlineInputBorder()),
                      autofocus: false,
                    ),
                    const SizedBox(height: 15),
                    const Text('Chọn biểu tượng:'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 15, runSpacing: 15,
                      children: quickIcons.map((icon) {
                        final isSelected = (selectedIcon == icon);
                        return GestureDetector(
                          onTap: () => setStateDialog(() => selectedIcon = icon),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? selectedColor.withOpacity(0.2) : null,
                              border: isSelected ? Border.all(color: selectedColor, width: 2) : Border.all(color: Colors.grey.shade300),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: isSelected ? selectedColor : Colors.grey),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty) return;

                    final newCat = Category(
                      name: nameController.text,
                      isExpense: _isExpenseController,
                      iconCode: selectedIcon.codePoint,
                      colorValue: selectedColor.value,
                    );

                    int id = await AppDatabase.instance.insertCategory(newCat.toMap());
                    if (!context.mounted) return;
                    Navigator.of(ctx).pop();

                    await _loadCategories(isInit: false);
                    
                    setState(() {
                       try {
                         _selectedCategory = _categories.firstWhere((c) => c.id == id);
                       } catch (e) {}
                    });
                  },
                  child: const Text('Thêm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submitData() async {
    if (_amountController.text.isEmpty || _selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng nhập tiền và chọn danh mục!'))
        );
      return;
    }

    final enteredAmount = double.parse(_amountController.text);
    final enteredNote = _noteController.text;

    final tx = my_model.Transaction(
      id: widget.existingTransaction?.id,
      amount: enteredAmount,
      note: enteredNote,
      date: _selectedDate,
      categoryId: _selectedCategory!.id!,
    );

    if (widget.existingTransaction == null) {
      await AppDatabase.instance.insertTransaction(tx.toMap());
    } else {
      await AppDatabase.instance.updateTransaction(tx.toMap());
    }

    widget.onSave();
    Navigator.of(context).pop();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _isExpenseController ? Colors.red : Colors.green,
            ),
          ),
          child: child!,
        );
      },
    ).then((pickedDate) {
      if (pickedDate == null) return;
      final now = DateTime.now();
      final newDateTime = DateTime(
        pickedDate.year, pickedDate.month, pickedDate.day,
        now.hour, now.minute,
      );
      setState(() {
        _selectedDate = newDateTime;
        _dateController.text = DateFormat('dd/MM/yyyy HH:mm').format(newDateTime);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));

    final themeColor = _isExpenseController ? Colors.red : Colors.green;
    final String title = widget.existingTransaction == null 
        ? (_isExpenseController ? 'Thêm Khoản Chi' : 'Thêm Khoản Thu')
        : 'Chỉnh Sửa Giao Dịch';

    return Padding(
      padding: EdgeInsets.only(
        top: 20, left: 20, right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Expanded(
                 child: Text(title, 
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: themeColor),
                  ),
               ),
               if (widget.existingTransaction != null)
                 IconButton(
                   icon: const Icon(Icons.delete, color: Colors.grey),
                   onPressed: () {
                     showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Xác nhận xóa'),
                          content: const Text('Bạn có chắc chắn muốn xóa giao dịch này không?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                if (widget.onDelete != null) {
                                  widget.onDelete!(widget.existingTransaction!.id!);
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text('Xóa ngay', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                     );
                   },
                 )
            ],
          ),
          const SizedBox(height: 20),

          // 1. Toggle Button (Sử dụng hàm _switchTab)
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isExpenseController ? Colors.red : Colors.grey[300],
                    foregroundColor: _isExpenseController ? Colors.white : Colors.black,
                  ),
                  onPressed: () => _switchTab(true), // Chuyển sang Chi
                  child: const Text('Chi tiêu'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isExpenseController ? Colors.green : Colors.grey[300],
                    foregroundColor: !_isExpenseController ? Colors.white : Colors.black,
                  ),
                  onPressed: () => _switchTab(false), // Chuyển sang Thu
                  child: const Text('Thu nhập'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Số tiền
          TextField(
            controller: _amountController,
            decoration: InputDecoration(
                labelText: 'Số tiền', 
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: themeColor))
            ),
            keyboardType: TextInputType.number,
            style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
            autofocus: false,
          ),
          const SizedBox(height: 10),

          // 3. Dropdown & Nút Thêm nhanh
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<Category>(
                  // --- KEY QUAN TRỌNG ĐỂ CHỐNG TREO ---
                  // Khi _isExpenseController thay đổi, Flutter sẽ tạo một Dropdown MỚI TINH
                  // thay vì cố dùng lại cái cũ, giúp tránh xung đột dữ liệu.
                  key: ValueKey(_isExpenseController), 
                  // ------------------------------------
                  
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Danh mục', border: OutlineInputBorder()),
                  items: _categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Row(
                        children: [
                          Icon(IconData(cat.iconCode, fontFamily: 'MaterialIcons'), color: Color(cat.colorValue)),
                          const SizedBox(width: 10),
                          Text(cat.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  hint: _categories.isEmpty ? const Text("Chưa có danh mục") : null,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: themeColor.withOpacity(0.5)),
                ),
                child: IconButton(
                  icon: Icon(Icons.add, color: themeColor),
                  tooltip: "Thêm danh mục mới",
                  onPressed: _showQuickAddCategoryDialog,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ... Các phần dưới giữ nguyên ...
          TextField(
            controller: _dateController,
            readOnly: true,
            onTap: _presentDatePicker,
            decoration: InputDecoration(
              labelText: 'Ngày giao dịch',
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: themeColor)),
              suffixIcon: Icon(Icons.calendar_today, color: themeColor),
            ),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Ghi chú (Không bắt buộc)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _submitData,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: Text(widget.existingTransaction == null ? 'LƯU GIAO DỊCH' : 'CẬP NHẬT'),
          ),
          
          if (widget.existingTransaction != null) ...[
            const SizedBox(height: 15),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Xác nhận xóa'),
                      content: const Text('Bạn có chắc chắn muốn xóa giao dịch này không?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            if (widget.onDelete != null) {
                              widget.onDelete!(widget.existingTransaction!.id!);
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('XÓA GIAO DỊCH NÀY', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('XÓA GIAO DỊCH NÀY', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ),
          ]
        ],
      ),
    );
  }
}