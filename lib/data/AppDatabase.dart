import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// Import theo đường dẫn mới và tên file mới
import '../model/category.dart'; 

class AppDatabase {
  static const _dbName = "quan_li_chi_tieu.db";
  static const _dbVersion = 1;

  // Bảng Category
  static const tableCategory = 'categories';
  static const colCatId = 'id';
  static const colCatName = 'name';
  static const colCatIsExpense = 'is_expense';
  static const colCatIcon = 'icon_code';
  static const colCatColor = 'color_value';

  // Bảng Transaction
  static const tableTransaction = 'transactions';
  static const colTransId = 'id';
  static const colTransAmount = 'amount';
  static const colTransNote = 'note';
  static const colTransDate = 'date';
  static const colTransCatId = 'category_id';

  AppDatabase._privateConstructor();
  static final AppDatabase instance = AppDatabase._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableCategory (
        $colCatId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colCatName TEXT NOT NULL,
        $colCatIsExpense INTEGER NOT NULL,
        $colCatIcon INTEGER NOT NULL,
        $colCatColor INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableTransaction (
        $colTransId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colTransAmount REAL NOT NULL,
        $colTransNote TEXT,
        $colTransDate TEXT NOT NULL,
        $colTransCatId INTEGER NOT NULL,
        FOREIGN KEY ($colTransCatId) REFERENCES $tableCategory ($colCatId)
      )
    ''');

    await _seedCategories(db);
  }

  Future _seedCategories(Database db) async {
    // Sửa tên Class thành Category
    List<Category> defaults = [
      Category(name: 'Ăn uống', isExpense: true, iconCode: Icons.fastfood.codePoint, colorValue: Colors.orange.value),
      Category(name: 'Di chuyển', isExpense: true, iconCode: Icons.motorcycle.codePoint, colorValue: Colors.blue.value),
      Category(name: 'Mua sắm', isExpense: true, iconCode: Icons.shopping_bag.codePoint, colorValue: Colors.pink.value),
      Category(name: 'Giải trí', isExpense: true, iconCode: Icons.movie.codePoint, colorValue: Colors.purple.value),
      Category(name: 'Lương', isExpense: false, iconCode: Icons.attach_money.codePoint, colorValue: Colors.green.value),
      Category(name: 'Thưởng', isExpense: false, iconCode: Icons.card_giftcard.codePoint, colorValue: Colors.teal.value),
    ];

    for (var cat in defaults) {
      await db.insert(tableCategory, cat.toMap());
    }
  }

  // --- CRUD ---

  Future<List<Map<String, dynamic>>> getCategories(bool isExpense) async {
    Database db = await instance.database;
    return await db.query(
      tableCategory,
      where: '$colCatIsExpense = ?',
      whereArgs: [isExpense ? 1 : 0],
    );
  }

  Future<int> insertTransaction(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableTransaction, row);
  }

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT t.*, c.$colCatName, c.$colCatIcon, c.$colCatColor, c.$colCatIsExpense
      FROM $tableTransaction t
      INNER JOIN $tableCategory c ON t.$colTransCatId = c.$colCatId
      ORDER BY t.$colTransDate DESC
    ''');
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(
      tableTransaction, 
      where: '$colTransId = ?', 
      whereArgs: [id]
    );
  }

  // 1. Thêm danh mục mới
  Future<int> insertCategory(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableCategory, row);
  }

  // 2. Xóa danh mục
  Future<int> deleteCategory(int id) async {
    Database db = await instance.database;
    // Chú ý: Khi xóa category, các Transaction thuộc category đó sẽ bị lỗi khóa ngoại.
    // Thực tế nên dùng "Soft Delete" (ẩn đi), nhưng ở đây ta xóa luôn transaction liên quan cho sạch.
    await db.delete(tableTransaction, where: '$colTransCatId = ?', whereArgs: [id]);
    return await db.delete(tableCategory, where: '$colCatId = ?', whereArgs: [id]);
  }

  // Hàm cập nhật giao dịch
  Future<int> updateTransaction(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[colTransId]; // Lấy ID từ map
    return await db.update(
      tableTransaction,
      row,
      where: '$colTransId = ?',
      whereArgs: [id],
    );
  }

  // --- Thêm vào cuối class DatabaseHelper ---

  // Hàm tính tổng tiền chi tiêu theo danh mục
  // Trả về List gồm: Tên danh mục, Tổng tiền, Màu sắc, Icon
  Future<List<Map<String, dynamic>>> getExpenseStatistics() async {
    Database db = await instance.database;
    
    // Câu lệnh SQL "thần thánh": JOIN bảng và GROUP BY
    return await db.rawQuery('''
      SELECT 
        c.$colCatName, 
        c.$colCatColor, 
        c.$colCatIcon, 
        SUM(t.$colTransAmount) as totalAmount
      FROM $tableTransaction t
      INNER JOIN $tableCategory c ON t.$colTransCatId = c.$colCatId
      WHERE c.$colCatIsExpense = 1  -- Chỉ lấy khoản CHI (is_expense = 1)
      GROUP BY c.$colCatId          -- Gom nhóm theo danh mục
      ORDER BY totalAmount DESC     -- Xếp cái nào tiêu nhiều nhất lên đầu
    ''');
  }
}