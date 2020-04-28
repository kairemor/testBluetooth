import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

class BleLib extends StatefulWidget {
  @override
  BleLibState createState() {
    return BleLibState();
  }
}

class BleLibState extends State<BleLib> {
  BleManager bleManager = BleManager();

  Future<void> advertise() async {
    await bleManager.createClient();
  }

  Future<void> startScan() async {
    bleManager.startPeripheralScan().listen((scanResult) {
      print(
          "Scanned Peripheral ${scanResult.peripheral.name}, RSSI ${scanResult.rssi}");
      bleManager.stopPeripheralScan();
    });
  }

  Future<bool> connect(ScanResult scanResult) async {
    Peripheral peripheral = scanResult.peripheral;
    peripheral
        .observeConnectionState(
            emitCurrentValue: true, completeOnDisconnect: true)
        .listen((connectionState) {
      print(
          "Peripheral ${scanResult.peripheral.identifier} connection state is $connectionState");
    });
    await peripheral.connect();
    bool connected = await peripheral.isConnected();
    // await peripheral.disconnectOrCancelConnection();
    return connected;
  }

  @override
  void initState() {
    super.initState();
    advertise();
    startScan();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(title: Text("ble manager")),
      body: Container(
        child: Column(
          children: <Widget>[
            RaisedButton(
              onPressed: advertise,
              child: Text("Advetise"),
            ),
            RaisedButton(
              onPressed: startScan,
              child: Text("Scanning"),
            ),
          ],
        ),
      ),
    ));
  }
}
