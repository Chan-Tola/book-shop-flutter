class PaymentIntentInfo {
  final String paymentIntentId;
  final String clientSecret;
  final int amount;
  final String currency;
  final String status;

  PaymentIntentInfo({
    required this.paymentIntentId,
    required this.clientSecret,
    required this.amount,
    required this.currency,
    required this.status,
  });

  factory PaymentIntentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentIntentInfo(
      paymentIntentId: json['paymentIntentId']?.toString() ?? '',
      clientSecret: json['clientSecret']?.toString() ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toInt() : 0,
      currency: json['currency']?.toString() ?? 'usd',
      status: json['status']?.toString() ?? '',
    );
  }
}
