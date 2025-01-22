import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import 'ble_controller.dart';

class TestDetectBluetooth extends StatefulWidget {
  const TestDetectBluetooth({super.key});

  @override
  State<TestDetectBluetooth> createState() => _TestDetectBluetoothState();
}

class _TestDetectBluetoothState extends State<TestDetectBluetooth> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BLE SCANNER"),
      ),
      body: GetBuilder<BleController>(
        init: BleController(),
        builder: (BleController controller) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder<List<ScanResult>>(
                    stream: controller.filteredScanResults,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Expanded(
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final data = snapshot.data![index];
                                if (data.device.name.isNotEmpty) {
                                  return Card(
                                    elevation: 2,
                                    child: ListTile(
                                      title: Text(data.device.name),
                                      subtitle: Text(data.device.id.id),
                                      trailing: Text(data.rssi.toString()),
                                      onTap: () => controller
                                          .connectToDevice(data.device),
                                    ),
                                  );
                                } else {
                                  return SizedBox();
                                }
                              }),
                        );
                      } else {
                        return Center(
                          child: Text("No Device Found"),
                        );
                      }
                    }),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    onPressed: () async {
                      controller.scanDevices();
                      // await controller.disconnectDevice();
                    },
                    child: Text("SCAN")),
              ],
            ),
          );
        },
      ),
    );
  }
}
