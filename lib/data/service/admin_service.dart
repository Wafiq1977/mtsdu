import '../../../data/model/user.dart';
import '../../../data/model/schedule.dart';
import '../../../data/model/payment.dart';
import '../../../domain/entity/user_entity.dart';
import 'user_service.dart';
import 'schedule_service.dart';
import 'payment_service.dart';

class AdminService {
  final UserService _userService = UserService();
  final ScheduleService _scheduleService = ScheduleService();
  final PaymentService _paymentService = PaymentService();

  Future<List<User>> getAllUsers() async {
    return _userService.getAllUsers();
  }

  Future<User?> getUserById(String id) async {
    return _userService.getUserById(id);
  }

  Future<List<User>> getUsersByRole(UserRole role) async {
    return _userService.getUsersByRole(role);
  }

  Future<List<Schedule>> getAllSchedules() async {
    return _scheduleService.getAllSchedules();
  }

  Future<List<Payment>> getAllPayments() async {
    return _paymentService.getAllPayments();
  }

  Future<void> addUser(User user) async {
    await _userService.addUser(user);
  }

  Future<void> updateUser(User user) async {
    await _userService.updateUser(user);
  }

  Future<void> deleteUser(String id) async {
    await _userService.deleteUser(id);
  }

  Future<void> addSchedule(Schedule schedule) async {
    await _scheduleService.addSchedule(schedule);
  }

  Future<void> updateSchedule(Schedule schedule) async {
    await _scheduleService.updateSchedule(schedule);
  }

  Future<void> deleteSchedule(String id) async {
    await _scheduleService.deleteSchedule(id);
  }

  Future<void> addPayment(Payment payment) async {
    await _paymentService.addPayment(payment);
  }

  Future<void> updatePayment(Payment payment) async {
    await _paymentService.updatePayment(payment);
  }

  Future<void> deletePayment(String id) async {
    await _paymentService.deletePayment(id);
  }
}
