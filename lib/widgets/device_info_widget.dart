import 'package:flutter/material.dart';
import '../services/device_info_service.dart';

class DeviceInfoWidget extends StatefulWidget {
  const DeviceInfoWidget({super.key});

  @override
  State<DeviceInfoWidget> createState() => _DeviceInfoWidgetState();
}

class _DeviceInfoWidgetState extends State<DeviceInfoWidget> {
  Map<String, dynamic>? _deviceInfo;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    final info = await DeviceInfoService.getDeviceInfo();
    setState(() {
      _deviceInfo = info;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_deviceInfo == null || _deviceInfo!.containsKey('error')) {
      return Center(child: Text('Error: ${_deviceInfo?['error'] ?? 'Unknown error'}'));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _deviceInfo!.entries.map((entry) {
        return ListTile(
          title: Text(entry.key),
          subtitle: Text('${entry.value}'),
        );
      }).toList(),
    );
  }
}
