class UserBalance {
  final String userName;
  final double balance;

  UserBalance({
    required this.userName,
    required this.balance,
  });

  factory UserBalance.fromJson(Map<String, dynamic> json) {
    return UserBalance(
      userName: json['user_name'],
      balance: json['balance'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'balance': balance,
    };
  }
}