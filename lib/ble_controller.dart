import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController {
  FlutterBlue ble = FlutterBlue.instance;

  Future scanDevices() async {
    await ble.startScan(timeout: Duration(seconds: 5));

    ble.stopScan();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect(timeout: Duration(seconds: 15));

    device.state.listen((isConnected) {
      if (isConnected == BluetoothDeviceState.connecting) {
        print("Device connecting to: ${device.name}");
      } else if (isConnected == BluetoothDeviceState.connected) {
        print("Device connected: ${device.name}");
      } else {
        print("Device Disconnected");
      }
    });
  }

  Stream<List<ScanResult>> get filteredScanResults =>
      ble.scanResults.map((results) => results.where((scanResult) {
            return scanResult.advertisementData.connectable &&
                scanResult.device.name.isNotEmpty &&
                scanResult.rssi > -80;
          }).toList());
}
