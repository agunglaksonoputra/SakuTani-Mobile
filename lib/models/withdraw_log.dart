class WithdrawLog {
  final String id;
  final String userName;
  final double amount;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  WithdrawLog({
    required this.id,
    required this.userName,
    required this.amount,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WithdrawLog.fromJson(Map<String, dynamic> json) {
    return WithdrawLog(
      id: json['id'],
      userName: json['user_name'],
      amount: json['amount'].toDouble(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
