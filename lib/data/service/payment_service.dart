import '../model/payment.dart';
import '../source/hive_service.dart';

class PaymentService {
  Future<List<Payment>> getAllPayments() async {
    final box = HiveService.getPaymentBox();
    return box.values.map((e) => Payment.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  Future<Payment?> getPaymentById(String id) async {
    final box = HiveService.getPaymentBox();
    final paymentMap = box.get(id);
    if (paymentMap != null) {
      return Payment.fromMap(Map<String, dynamic>.from(paymentMap));
    }
    return null;
  }

  Future<List<Payment>> getPaymentsByStudent(String studentId) async {
    final box = HiveService.getPaymentBox();
    final payments = box.values.map((e) => Payment.fromMap(Map<String, dynamic>.from(e))).toList();
    return payments.where((payment) => payment.studentId == studentId).toList();
  }

  Future<List<Payment>> getPaymentsByMonth(String month, int year) async {
    final box = HiveService.getPaymentBox();
    final payments = box.values.map((e) => Payment.fromMap(Map<String, dynamic>.from(e))).toList();
    return payments.where((payment) => payment.month == month && payment.year == year).toList();
  }

  Future<List<Payment>> getPaymentsByYear(int year) async {
    final box = HiveService.getPaymentBox();
    final payments = box.values.map((e) => Payment.fromMap(Map<String, dynamic>.from(e))).toList();
    return payments.where((payment) => payment.year == year).toList();
  }

  Future<List<Payment>> getPaidPayments() async {
    final box = HiveService.getPaymentBox();
    final payments = box.values.map((e) => Payment.fromMap(Map<String, dynamic>.from(e))).toList();
    return payments.where((payment) => payment.status == PaymentStatus.paid).toList();
  }

  Future<List<Payment>> getUnpaidPayments() async {
    final box = HiveService.getPaymentBox();
    final payments = box.values.map((e) => Payment.fromMap(Map<String, dynamic>.from(e))).toList();
    return payments.where((payment) => payment.status == PaymentStatus.unpaid).toList();
  }

  Future<double> getTotalPaidAmount() async {
    final paidPayments = await getPaidPayments();
    double total = 0.0;
    for (final payment in paidPayments) {
      total += payment.amount;
    }
    return total;
  }

  Future<double> getTotalUnpaidAmount() async {
    final unpaidPayments = await getUnpaidPayments();
    double total = 0.0;
    for (final payment in unpaidPayments) {
      total += payment.amount;
    }
    return total;
  }

  Future<Map<String, double>> getPaymentStatsByStudent(String studentId) async {
    final payments = await getPaymentsByStudent(studentId);
    double totalPaid = 0.0;
    double totalUnpaid = 0.0;

    for (final payment in payments) {
      if (payment.status == PaymentStatus.paid) {
        totalPaid += payment.amount;
      } else {
        totalUnpaid += payment.amount;
      }
    }

    return {
      'totalPaid': totalPaid,
      'totalUnpaid': totalUnpaid,
      'totalAmount': totalPaid + totalUnpaid,
    };
  }

  Future<void> addPayment(Payment payment) async {
    final box = HiveService.getPaymentBox();
    await box.put(payment.id, payment.toMap());
  }

  Future<void> updatePayment(Payment payment) async {
    final box = HiveService.getPaymentBox();
    await box.put(payment.id, payment.toMap());
  }

  Future<void> deletePayment(String id) async {
    final box = HiveService.getPaymentBox();
    await box.delete(id);
  }

  Future<void> markPaymentAsPaid(String id, String paymentDate) async {
    final payment = await getPaymentById(id);
    if (payment != null) {
      final updatedPayment = Payment(
        id: payment.id,
        studentId: payment.studentId,
        month: payment.month,
        year: payment.year,
        amount: payment.amount,
        status: PaymentStatus.paid,
        paymentDate: paymentDate,
      );
      await updatePayment(updatedPayment);
    }
  }
}
