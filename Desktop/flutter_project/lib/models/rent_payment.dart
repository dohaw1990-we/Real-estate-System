enum PaymentStatus { paid, due, overdue, partial }

class RentPayment {
  final String id;
  final String contractId;
  final int year;
  final int month;
  final DateTime dueDate;
  final DateTime? paidAt;
  final double amount;
  final double paidAmount;
  final PaymentStatus status;
  final String paymentMethod;
  final String receiptNumber;

  const RentPayment({
    required this.id,
    required this.contractId,
    required this.year,
    required this.month,
    required this.dueDate,
    required this.paidAt,
    required this.amount,
    required this.paidAmount,
    required this.status,
    required this.paymentMethod,
    required this.receiptNumber,
  });

  factory RentPayment.fromJson(Map<String, dynamic> json) {
    return RentPayment(
      id: json['id'] as String,
      contractId: json['contractId'] as String,
      year: json['year'] as int,
      month: json['month'] as int,
      dueDate: DateTime.parse(json['dueDate'] as String),
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
      amount: (json['amount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num).toDouble(),
      status: PaymentStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => PaymentStatus.due,
      ),
      paymentMethod: json['paymentMethod'] as String,
      receiptNumber: json['receiptNumber'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contractId': contractId,
      'year': year,
      'month': month,
      'dueDate': dueDate.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'amount': amount,
      'paidAmount': paidAmount,
      'status': status.name,
      'paymentMethod': paymentMethod,
      'receiptNumber': receiptNumber,
    };
  }
}
