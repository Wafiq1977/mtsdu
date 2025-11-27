enum PaymentStatus { paid, unpaid, overdue }

class Payment {
  final String id;
  final String studentId;
  final String month;
  final int year;
  final double amount;
  final PaymentStatus status;
  final String? paymentDate;

  Payment({
    required this.id,
    required this.studentId,
    required this.month,
    required this.year,
    required this.amount,
    required this.status,
    this.paymentDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'month': month,
      'year': year,
      'amount': amount,
      'status': status.index,
      'paymentDate': paymentDate,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      studentId: map['studentId'],
      month: map['month'],
      year: map['year'],
      amount: map['amount'],
      status: PaymentStatus.values[map['status']],
      paymentDate: map['paymentDate'],
    );
  }
}
