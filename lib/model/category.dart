class Category {
  final int? id;
  final String name;
  final bool isExpense;
  final int iconCode;
  final int colorValue;

  Category({
    this.id,
    required this.name,
    required this.isExpense,
    required this.iconCode,
    required this.colorValue,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      isExpense: map['is_expense'] == 1,
      iconCode: map['icon_code'],
      colorValue: map['color_value'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'is_expense': isExpense ? 1 : 0,
      'icon_code': iconCode,
      'color_value': colorValue,
    };
  }

  // --- QUAN TRỌNG NHẤT: PHẦN NÀY GIÚP CHỐNG TREO APP ---
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id; // So sánh bằng ID

  @override
  int get hashCode => id.hashCode;
}