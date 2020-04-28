import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_scan_bluetooth/flutter_scan_bluetooth.dart'
    hide BluetoothDevice;
import 'dart:async';

class BlueToothProvider with ChangeNotifier {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool isOn;
  String _data = 'Nobody found yet!';
  String dataBlue = '';
  bool _scanning = false;
  List<String> devices = [];
  List<String> previousSearch = [];
  FlutterScanBluetooth _bluetooth = FlutterScanBluetooth();

  String get data => _data;

  BlueToothProvider.initialize() {
    searchForDevices();
    // Timer.periodic(new Duration(seconds: 300), (timer) {
    //   searchForDevices();
    // });
  }

  void turnOn() async {
    isOn = await flutterBlue.isOn;
    notifyListeners();
  }

  // Future<void> connectoDevice(BluetoothDevice device) async {
  //   // Connect to the device
  //   // await device ;
  // }

  Future<void> stopScan() async {
    await _bluetooth.stopScan();
    previousSearch = devices;
    debugPrint("scanning stoped");
    _scanning = false;
    notifyListeners();
  }

  Future<void> searchForDevices() async {
    isOn = await flutterBlue.isOn;
    notifyListeners();
    if (!isOn) {
      return;
    } else {
      await _bluetooth.startScan(pairedDevices: false);
      _scanning = true;
      // schedule stoping search
      // Timer.periodic(new Duration(seconds: 60), (timer) {
      //   stopScan();
      // });
      _bluetooth.devices.toList().then((v) {
        print("number of devices: ${v.length}");
      });
      _bluetooth.devices.listen((device) {
        if (device != null) {
          _data = "";
        }
        _data += device.name + ' (${device.address})\n';
        devices.add(_data);
        // connectoDevice(device);
        notifyListeners();
      });
    }
  }
}
