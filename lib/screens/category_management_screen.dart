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
          title: const Text('Quản Lý Danh Mộc'),
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  // Hàm này để widget cha gọi khi cần refresh
  @override
  void didUpdateWidget(covariant CategoryListTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadData();
  }

  void _loadData() async {
    final maps = await AppDatabase.instance.getCategories(widget.isExpense);
    setState(() {
      _list = maps.map((e) => Category.fromMap(e)).toList();
    });
  }

  void _delete(int id) async {
    await AppDatabase.instance.deleteCategory(id);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_list.isEmpty) return const Center(child: Text("Chưa có danh mục nào"));
    
    return ListView.builder(
      itemCount: _list.length,
      itemBuilder: (context, index) {
        final cat = _list[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(cat.colorValue).withOpacity(0.2),
              child: Icon(IconData(cat.iconCode, fontFamily: 'MaterialIcons'), color: Color(cat.colorValue)),
            ),
            title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey),
              onPressed: () {
                // Hỏi trước khi xóa
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Xác nhận xóa'),
                    content: const Text('Lưu ý: Xóa danh mục sẽ xóa luôn các giao dịch thuộc danh mục này!'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _delete(cat.id!);
                        },
                        child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}