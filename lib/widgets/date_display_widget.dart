import 'package:flutter/material.dart';
import '../utils/date_utils.dart' as app_date_utils;

class DateDisplayWidget extends StatelessWidget {
  final DateTime dateTime;

  const DateDisplayWidget({super.key, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    final formattedDate = app_date_utils.AppDateUtils.formatDateTime(dateTime);
    final relativeTime = app_date_utils.AppDateUtils.formatRelativeTime(dateTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Formatted Date: $formattedDate',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          'Relative Time: $relativeTime',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
