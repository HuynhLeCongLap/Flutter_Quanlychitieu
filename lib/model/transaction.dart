class Transaction{
  int? id;
  double amount;
  String note;
  DateTime date;
  int categoryId; // <--- Khóa ngoại trỏ sang bảng Category

  Transaction({
    this.id,
    required this.amount,
    required this.note,
    required this.date,
    required this.categoryId, // Bắt buộc phải có
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'date': date.toIso8601String(),
      'category_id': categoryId, // Lưu vào cột category_id
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'],
      note: map['note'],
      date: DateTime.parse(map['date']),
      categoryId: map['category_id'],
    );
  }
}