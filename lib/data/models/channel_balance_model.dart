class ChannelBalanceModel {
  final String name;
  final double balance;

  ChannelBalanceModel({
    required this.name,
    required this.balance,
  });

  ChannelBalanceModel copyWith({
    String? name,
    double? balance,
  }) {
    return ChannelBalanceModel(
      name: name ?? this.name,
      balance: balance ?? this.balance,
    );
  }
}
