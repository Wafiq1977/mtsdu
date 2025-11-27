import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../data/model/payment.dart';

class StudentPaymentsView extends StatelessWidget {
  const StudentPaymentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final payments = dataProvider.payments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tagihan SPP & Status Pembayaran'),
      ),
      body: ListView.builder(
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final Payment payment = payments[index];
          return ListTile(
            title: Text('Bulan: ${payment.month}'),
            subtitle: Text('Jumlah: Rp${payment.amount}'),
            trailing: Text(payment.status.toString().split('.').last),
          );
        },
      ),
    );
  }
}
