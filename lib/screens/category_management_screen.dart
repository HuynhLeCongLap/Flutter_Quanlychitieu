import 'package:flutter/material.dart';
import '../data/AppDatabase.dart'; // Sửa lại tên file DB của bạn nếu khác
import '../model/category.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  // Danh sách icon mẫu để người dùng chọn
  final List<IconData> _availableIcons = [
    Icons.fastfood, Icons.shopping_bag, Icons.home, Icons.movie,
    Icons.directions_car, Icons.flight, Icons.medical_services, Icons.school,
    Icons.pets, Icons.sports_soccer, Icons.work, Icons.attach_money,
    Icons.card_giftcard, Icons.savings, Icons.trending_up, Icons.videogame_asset,
  ];

  // Danh sách màu mẫu
  final List<Color> _availableColors = [
    Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
    Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
    Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
    Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
    Colors.brown, Colors.grey, Colors.blueGrey, Colors.black,
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 2 Tab: Chi và Thu
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản Lý Danh Mục'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Chi tiêu', icon: Icon(Icons.money_off)),
              Tab(text: 'Thu nhập', icon: Icon(Icons.attach_money)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CategoryListTab(isExpense: true),  // Tab 1: Chi
            CategoryListTab(isExpense: false), // Tab 2: Thu
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => _showAddCategoryDialog(context),
        ),
      ),
    );
  }

  // Hàm hiển thị Dialog thêm danh mục
  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    IconData selectedIcon = _availableIcons[0];
    Color selectedColor = _availableColors[0];
    bool isExpense = true; // Mặc định là Chi

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder( // Dùng StatefulBuilder để cập nhật UI trong Dialog
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Thêm Danh Mục Mới'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Nhập tên
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Tên danh mục'),
                    ),
                    const SizedBox(height: 15),

                    // 2. Chọn loại (Chi/Thu)
                    Row(
                      children: [
                        const Text('Loại: '),
                        const SizedBox(width: 10),
                        ChoiceChip(
                          label: const Text('Chi tiêu'),
                          selected: isExpense,
                          selectedColor: Colors.red.shade100,
                          onSelected: (val) => setStateDialog(() => isExpense = true),
                        ),
                        const SizedBox(width: 10),
                        ChoiceChip(
                          label: const Text('Thu nhập'),
                          selected: !isExpense,
                          selectedColor: Colors.green.shade100,
                          onSelected: (val) => setStateDialog(() => isExpense = false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // 3. Chọn Màu
                    const Text('Chọn Màu:'),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _availableColors.length,
                        itemBuilder: (context, index) {
                          final color = _availableColors[index];
                          return GestureDetector(
                            onTap: () => setStateDialog(() => selectedColor = color),
                            child: Container(
                              width: 40, height: 40,
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: selectedColor == color 
                                  ? Border.all(width: 3, color: Colors.black) : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 15),

                    // 4. Chọn Icon
                    const Text('Chọn Icon:'),
                    SizedBox(
                      height: 150, // Giới hạn chiều cao
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10),
                        itemCount: _availableIcons.length,
                        itemBuilder: (context, index) {
                          final icon = _availableIcons[index];
                          return GestureDetector(
                            onTap: () => setStateDialog(() => selectedIcon = icon),
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedIcon == icon ? Colors.grey.shade300 : null,
                                borderRadius: BorderRadius.circular(10),
                                border: selectedIcon == icon 
                                  ? Border.all(color: Colors.blue, width: 2) : null,
                              ),
                              child: Icon(icon, color: selectedColor, size: 30),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty) return;

                    // Tạo đối tượng Category mới
                    final newCat = Category(
                      name: nameController.text,
                      isExpense: isExpense,
                      iconCode: selectedIcon.codePoint,
                      colorValue: selectedColor.value,
                    );

                    // Lưu vào DB
                    await AppDatabase.instance.insertCategory(newCat.toMap());
                    
                    // Đóng dialog và reload lại màn hình (cần trick nhỏ để reload tab)
                    if (context.mounted) {
                       Navigator.of(context).pop();
                       // Cách đơn giản nhất để refresh: Pop màn hình này và mở lại (hoặc dùng callback)
                       // Nhưng ở đây ta sẽ dùng setState của Widget cha nếu cần.
                       // Tạm thời user cần back ra vào lại để thấy, hoặc ta thêm callback.
                    }
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Khi đóng dialog, refresh lại toàn bộ màn hình để cập nhật danh sách
      setState(() {});
    });
  }
}

// --- Widget con hiển thị danh sách trong từng Tab ---
class CategoryListTab extends StatefulWidget {
  final bool isExpense;
  const CategoryListTab({super.key, required this.isExpense});

  @override
  State<CategoryListTab> createState() => _CategoryListTabState();
}

class _CategoryListTabState extends State<CategoryListTab> {
  List<Category> _list = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  // Hàm này để widget cha gọi khi cần refresh
  @override
  void didUpdateWidget(covariant CategoryListTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpense != widget.isExpense) {
      _loadData();
    }
  }

  void _loadData() async {
    setState(() => _isLoading = true);
    final maps = await AppDatabase.instance.getCategories(widget.isExpense);
    if (mounted) {
      setState(() {
        _list = maps.map((e) => Category.fromMap(e)).toList();
        _isLoading = false;
      });
    }
  }

  void _delete(int id, String catName) async {
    try {
      print('🗑️ Bắt đầu xóa danh mục ID: $id');
      final result = await AppDatabase.instance.deleteCategory(id);
      print('✅ Kết quả xóa: $result row(s) affected');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa danh mục "$catName" và các giao dịch liên quan'), duration: const Duration(seconds: 2))
        );
        
        // Reload danh sách danh mục
        _loadData();
        
        // Quay lại Dashboard và trigger refresh
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      print('❌ Lỗi xóa: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xóa: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 3))
        );
      }
    }
  }

  void _showDeleteConfirmDialog(int catId, String catName) async {
    // Kiểm tra số lượng giao dịch
    final transactionCount = await AppDatabase.instance.getTransactionCountByCategory(catId);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa danh mục'),
        content: transactionCount > 0
            ? Text(
                'Danh mục "$catName" có $transactionCount giao dịch.\n\n'
                '⚠️ Xóa danh mục sẽ xóa luôn tất cả $transactionCount giao dịch này!\n\n'
                'Bạn có chắc chắn muốn tiếp tục?',
                style: const TextStyle(fontSize: 15),
              )
            : Text('Bạn có chắc chắn muốn xóa danh mục "$catName"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _delete(catId, catName);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text("Chưa có danh mục nào", style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView.builder(
        itemCount: _list.length,
        itemBuilder: (context, index) {
          final cat = _list[index];
          final catColor = Color(cat.colorValue);
          return Dismissible(
            key: ValueKey(cat.id),
            background: Container(
              color: Colors.red.shade400,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _showDeleteConfirmDialog(cat.id!, cat.name);
            },
            confirmDismiss: (direction) async {
              return false; // Dialog sẽ được xử lý bằng _showDeleteConfirmDialog
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: catColor.withOpacity(0.2),
                  child: Icon(IconData(cat.iconCode, fontFamily: 'MaterialIcons'), color: catColor, size: 24),
                ),
                title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(widget.isExpense ? 'Chi tiêu' : 'Thu nhập', style: TextStyle(color: Colors.grey.shade600)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmDialog(cat.id!, cat.name);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}