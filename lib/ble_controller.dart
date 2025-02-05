import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class FindDeviceScreen extends StatefulWidget {
  final String targetDeviceId;

  FindDeviceScreen({required this.targetDeviceId});

  @override
  _FindDeviceScreenState createState() => _FindDeviceScreenState();
}

class _FindDeviceScreenState extends State<FindDeviceScreen> {
  int? rssiValue;
  double? estimatedDistance;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() async {
    setState(() {
      isScanning = true;
      rssiValue = null;
      estimatedDistance = null;
    });

    FlutterBluePlus.startScan();

    FlutterBluePlus.scanResults.listen((results) {
      for (var result in results) {
        if (result.device.id.id == widget.targetDeviceId) {
         if(mounted){
           setState(() {
             rssiValue = result.rssi;
             estimatedDistance = _calculateDistance(result.rssi);
           });
         }
        }
      }
    });


    setState(() {
      isScanning = false;
    });
  }

  double _calculateDistance(int rssi, {int txPower = -59, double n = 2.0}) {
    return pow(10, (txPower - rssi) / (10 * n)).toDouble();
  }
  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tìm kiếm thiết bị")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              rssiValue != null ? "RSSI: $rssiValue dBm" : "Đang tìm thiết bị...",
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 10),
            if (estimatedDistance != null)
              Text(
                "Khoảng cách ước tính: ${estimatedDistance!.toStringAsFixed(2)} m",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 20),
            if (rssiValue != null)
              Text(
                rssiValue! > -50
                    ? "Thiết bị rất gần 🔥"
                    : rssiValue! > -70
                    ? "Đang ở gần 📶"
                    : "Thiết bị xa hơn 📡",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 40),

          ],
        ),
      ),
    );
  }
}
