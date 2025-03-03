// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_scan_bluetooth/flutter_scan_bluetooth.dart';
//
//
// class TestDetectBluetooth extends StatefulWidget {
//   const TestDetectBluetooth({super.key});
//
//   @override
//   State<TestDetectBluetooth> createState() => _TestDetectBluetoothState();
// }
//
// class _TestDetectBluetoothState extends State<TestDetectBluetooth> {
//   Set<String> _data = {};
//   bool _scanning = false;
//   FlutterScanBluetooth _bluetooth = FlutterScanBluetooth();
//
//   @override
//   void initState() {
//     super.initState();
//
//     _bluetooth.devices.listen((device) {
//       setState(() {
//         if (device.name != device.address) {
//           _data.add("${device.name}: ${device.address}");
//         }
//       });
//     });
//     _bluetooth.scanStopped.listen((device) {
//       setState(() {
//         _scanning = false;
//       });
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Plugin example app'),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: <Widget>[
//           Expanded(
//               child: ListView.builder(
//                 itemBuilder: (context, index) {
//                   return Text(_data.toList()[index]);
//                 },
//                 itemCount: _data.length,
//               )),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Center(
//               child: ElevatedButton(
//                   child: Text(_scanning ? 'Stop scan' : 'Start scan'),
//                   onPressed: () async {
//                     try {
//                       if (_scanning) {
//                         await _bluetooth.stopScan();
//                         debugPrint("scanning stoped");
//                         setState(() {
//                           _data = {};
//                         });
//                       } else {
//                         _data = {};
//                         await _bluetooth.startScan(pairedDevices: false);
//                         debugPrint("scanning started");
//                         setState(() {
//                           _scanning = true;
//                         });
//                       }
//                     } on PlatformException catch (e) {
//                       debugPrint(e.toString());
//                     }
//                   }),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Center(
//               child: ElevatedButton(
//                   child: Text('Check permissions'),
//                   onPressed: () async {
//                     try {
//                       await _bluetooth.requestPermissions();
//                       print('All good with perms');
//                     } on PlatformException catch (e) {
//                       debugPrint(e.toString());
//                     }
//                   }),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get_mac_address/get_mac_address.dart';
import 'package:tmp/ble_controller.dart';

class TestDetectBluetooth extends StatefulWidget {
  const TestDetectBluetooth({super.key});

  @override
  _TestDetectBluetoothState createState() => _TestDetectBluetoothState();
}

class _TestDetectBluetoothState extends State<TestDetectBluetooth> {
  List<ScanResult> scanResults = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
    getMacAddress();
  }

  void _startScan() async {
    setState(() {
      isScanning = true;
      scanResults.clear();
    });

    FlutterBluePlus.startScan(timeout: Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        scanResults = results;
      });
    });

    await Future.delayed(Duration(seconds: 5));
    FlutterBluePlus.stopScan();

    setState(() {
      isScanning = false;
    });
  }

  Future<void> getMacAddress() async {
    final _getMacAddressPlugin = GetMacAddress();
    print("dsaasda ${await _getMacAddressPlugin.getMacAddress()}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tìm kiếm thiết bị")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: scanResults.length,
              itemBuilder: (context, index) {
                final result = scanResults[index];
                return ListTile(
                  title: Text(result.device.name.isNotEmpty
                      ? result.device.name
                      : result.device.id.id),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FindDeviceScreen(
                                  targetDeviceId: result.device.id.id)));
                    },
                    child: Text("Chọn"),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: isScanning ? null : _startScan,
            child: isScanning ? Text("Đang quét...") : Text("Quét lại"),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
