import 'dart:io';

import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:ping_discover_network_plus/ping_discover_network_plus.dart';

class TestDetectNetworkDevice extends StatefulWidget {
  const TestDetectNetworkDevice({super.key});

  @override
  State<TestDetectNetworkDevice> createState() =>
      _TestDetectNetworkDeviceState();
}

class _TestDetectNetworkDeviceState extends State<TestDetectNetworkDevice> {
  final List<Host> _hosts = <Host>[];

  double? progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:
            IconButton(onPressed: () async {}, icon: Icon(Icons.dangerous)),
        title: const Text('lan_scanner example'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () async {
                  String? ip = await NetworkInfo().getWifiGatewayIP();
                  setState(() {
                    progress = null;
                    _hosts.clear();
                  });
                  final hosts = await quickIcmpScanSync(
                    ipToCSubnet(ip ?? ""),
                    timeout: Duration(milliseconds: 100),
                  );

                  setState(() {
                    _hosts.addAll(hosts);
                    progress = 1.0;
                  });
                },
                child: const Text('Quick scan sync'),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _hosts.length,
                itemBuilder: (context, index) {
                  final host = _hosts[index];
                  final address = host.internetAddress.address;
                  final time = host.pingTime;

                  return Card(
                    child: ListTile(
                      title: Text(address),
                      trailing: Text(time != null ? time.toString() : 'N/A'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Cach su dung Socket de quet dia chi ip
  void scanNetwork(String subnet) async {
    const int port = 80;
    final stream = NetworkAnalyzer.i.discover2(subnet, port);

    stream.listen((NetworkAddress addr) {
      if (addr.exists) {
        print('Found device: ${addr.ip}');
      }
    }, onDone: () => print('Scan complete'));
  }

  Future<List<Host>> quickIcmpScanSync(
    String subnet, {
    int firstIP = 1,
    int lastIP = 255,
    Duration timeout = const Duration(seconds: 1),
  }) async {
    final hostFutures1 = <Future<Host?>>[];
    final hostFutures2 = <Future<Host?>>[];

    for (var currAddr = 1; currAddr <= 100; ++currAddr) {
      final hostToPing = '$subnet.$currAddr';
      hostFutures1.add(
        _pingHost(
          hostToPing,
          timeout: timeout.inSeconds,
        ),
      );
    }
    final resolvedHosts1 = await Future.wait(hostFutures1);

    for (var currAddr = 101; currAddr <= lastIP; ++currAddr) {
      final hostToPing = '$subnet.$currAddr';
      hostFutures2.add(_pingHost(hostToPing, timeout: timeout.inSeconds));
    }

    final resolvedHosts2 = await Future.wait(hostFutures2);

    final allResolvedHosts = [...resolvedHosts1, ...resolvedHosts2]
        .where((element) => element != null)
        .cast<Host>()
        .toList();

    return allResolvedHosts;
  }

  Future<Host?> _pingHost(
    String target, {
    required int timeout,
  }) async {
    late Ping pingRequest;
    try {
      pingRequest =
          Ping(target, count: 1, timeout: timeout, forceCodepage: true);
    } catch (exc) {
      if (exc is UnimplementedError &&
          (exc.message?.contains('iOS') ?? false)) {
        print(
            "DartPingIOS.register() chưa được gọi hoặc đang dùng hàm async, tham khảo https://pub.dev/packages/lan_scanner");
      } else {
        rethrow;
      }
    }

    await for (final data in pingRequest.stream) {
      if (data.response != null && data.error == null) {
        final response = data.response!;
        return Host(
          internetAddress: InternetAddress(target),
          pingTime: response.time != null
              ? Duration(microseconds: response.time!.inMicroseconds)
              : null,
        );
      }
    }
    return null;
  }
}

// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';
// import 'package:network_info_plus/network_info_plus.dart';
// import 'package:ping_discover_network_plus/ping_discover_network_plus.dart';
//
// class TestDetectNetworkDevice extends StatefulWidget {
//   const TestDetectNetworkDevice({super.key});
//
//   @override
//   TestDetectNetworkDeviceState createState() => TestDetectNetworkDeviceState();
// }
//
// class TestDetectNetworkDeviceState extends State<TestDetectNetworkDevice> {
//   String localIp = '';
//   List<String> devices = [];
//   bool isDiscovering = false;
//   int found = -1;
//   TextEditingController portController = TextEditingController(text: '80');
//   late FlutterBlue flutterBlue;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     flutterBlue = FlutterBlue.instance;
//   }
//
//   void discover(BuildContext ctx) async {
//     final scaffoldMessage = ScaffoldMessenger.of(context);
//
//     setState(() {
//       isDiscovering = true;
//       devices.clear();
//       found = -1;
//     });
//
//     String ip;
//     try {
//       ip = await NetworkInfo().getWifiGatewayIP() ?? 'NO IP DETECTED';
//       log('local ip:\t$ip');
//     } catch (e) {
//       print(e);
//       const snackBar = SnackBar(
//           content: Text('WiFi is not connected', textAlign: TextAlign.center));
//       scaffoldMessage.showSnackBar(snackBar);
//       return;
//     }
//     setState(() {
//       localIp = ip;
//     });
//
//     final String subnet = ip.substring(0, ip.lastIndexOf('.'));
//     int port = 80;
//     try {
//       port = int.parse(portController.text);
//     } catch (e) {
//       portController.text = port.toString();
//     }
//     log('subnet:\t$subnet, port:\t$port');
//
//     final stream = NetworkAnalyzer.i.discover(subnet, port);
//
//     stream.listen((NetworkAddress addr) {
//       if (addr.exists) {
//         log('Found device: ${addr.ip}');
//         setState(() {
//           devices.add(addr.ip);
//           found = devices.length;
//         });
//       }
//     })
//       ..onDone(() {
//         setState(() {
//           isDiscovering = false;
//           found = devices.length;
//         });
//       })
//       ..onError((dynamic e) {
//         const snackBar = SnackBar(
//             content: Text('Unexpected exception', textAlign: TextAlign.center));
//         ScaffoldMessenger.of(context).showSnackBar(snackBar);
//       });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(onPressed: () {}, icon: Icon(Icons.add)),
//         title: const Text('Discover Local Network'),
//       ),
//       body: Builder(
//         builder: (BuildContext context) {
//           return Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: <Widget>[
//                 TextField(
//                   controller: portController,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(
//                     labelText: 'Port',
//                     hintText: 'Port',
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Text('Local ip: $localIp',
//                     style: const TextStyle(fontSize: 16)),
//                 const SizedBox(height: 15),
//                 ElevatedButton(
//                     onPressed: isDiscovering ? null : () => discover(context),
//                     child: Text(isDiscovering ? 'Discovering...' : 'Discover')),
//                 const SizedBox(height: 15),
//                 found >= 0
//                     ? Text('Found: $found device(s)',
//                         style: const TextStyle(fontSize: 16))
//                     : Container(),
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: devices.length,
//                     itemBuilder: (BuildContext context, int index) {
//                       return Column(
//                         children: <Widget>[
//                           Container(
//                             height: 60,
//                             padding: const EdgeInsets.only(left: 10),
//                             alignment: Alignment.centerLeft,
//                             child: Row(
//                               children: <Widget>[
//                                 const Icon(Icons.devices),
//                                 const SizedBox(width: 10),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: <Widget>[
//                                       Text(
//                                         '${devices[index]}:${portController.text}',
//                                         style: const TextStyle(fontSize: 16),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const Icon(Icons.chevron_right),
//                               ],
//                             ),
//                           ),
//                           const Divider(),
//                         ],
//                       );
//                     },
//                   ),
//                 )
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
