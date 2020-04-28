import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';

class FlutterBlueApp extends StatefulWidget {
  FlutterBlueApp({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _FlutterBlueAppState createState() => new _FlutterBlueAppState();
}

class _FlutterBlueAppState extends State<FlutterBlueApp> {
  FlutterBlue _flutterBlue = FlutterBlue.instance;

  /// Scanning
  StreamSubscription _scanSubscription;
  Map<DeviceIdentifier, ScanResult> scanResults = new Map();
  bool isScanning = false;

  /// State
  StreamSubscription _stateSubscription;
  BluetoothState state = BluetoothState.unknown;

  /// Device
  BluetoothDevice device;
  bool get isConnected => (device != null);
  StreamSubscription deviceConnection;
  StreamSubscription deviceStateSubscription;
  List<BluetoothService> services = new List();
  Map<Guid, StreamSubscription> valueChangedSubscriptions = {};
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;

  static const platform = const MethodChannel('bluetooth-mac-address');

  var _isAdvertising = "not advertising ";
  Future<void> _startAdvertise() async {
    var advertising = "not advertising";
    try {
      final result = await platform.invokeMethod('startAdvertising');
      advertising = result ? 'advertising' : 'return not advertising';
    } on PlatformException catch (e) {
      print("failed to start advertising : '${e.message}'.");
    }

    setState(() {
      _isAdvertising = advertising;
    });
  }

  // List scanresults = [];
  // Future<void> _startScannig() async {
  //   var scan = [];
  //   try {
  //     final result = await platform.invokeMethod('startScan');
  //     print("result flutter: $result ");
  //     scan = result;
  //     setState(() {
  //       isScanning = true;
  //     });
  //   } on PlatformException catch (e) {
  //     print("failed to start advertising : '${e.message}'.");
  //   }

  //   setState(() {
  //     scanresults = scan;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // _startAdvertise();
    // Immediately get the state of FlutterBlue
    _flutterBlue.state.listen((s) {
      setState(() {
        state = s;
      });
    });
    // Subscribe to state changes
    // _stateSubscription = _flutterBlue.onStateChanged().listen((s) {
    //   setState(() {
    //     state = s;
    //   });
    // });
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
    _scanSubscription?.cancel();
    _scanSubscription = null;
    deviceConnection?.cancel();
    deviceConnection = null;
    super.dispose();
  }

  _startScan() {
    _scanSubscription = _flutterBlue
        .scan(
            timeout: const Duration(seconds: 10), scanMode: ScanMode.lowLatency)
        .listen((scanResult) {
      print('localName: ${scanResult.advertisementData.localName}');
      print(
          'manufacturerData: ${scanResult.advertisementData.manufacturerData}');
      print('serviceData: ${scanResult.advertisementData.serviceData}');
      setState(() {
        scanResults[scanResult.device.id] = scanResult;
      });
    });
    print("scanResults: $scanResults");

    setState(() {
      isScanning = true;
    });
  }

  // _starScan() {
  //   setState(() {
  //     isScanning = true;
  //   });
  //   // Start scanning
  //   print("scaning");
  //   _flutterBlue.startScan(timeout: Duration(seconds: 10));

  //   // Listen to scan results
  //   _flutterBlue.scanResults.listen((results) {
  //     print("result : $results");
  //     // do something with scan results
  //     for (ScanResult r in results) {
  //       print('${r.device.name} found! rssi: ${r.rssi}');
  //     }
  //   }).onDone(() {
  //     print("scaningn donnnn");
  //   });

  //   // Stop scanning
  //   // _flutterBlue.stopScan();
  // }

  _stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    setState(() {
      isScanning = false;
    });
  }

  _connect(BluetoothDevice d) async {
    device = d;
// Connect to device
    device.connect(timeout: const Duration(seconds: 4)).then(null);

// Update the connection state immediately
    device.state.listen((s) {
      setState(() {
        deviceState = s;
      });
    });

// Subscribe to connection changes
    // deviceStateSubscription = device.onStateChanged().listen((s) {
    //   setState(() {
    //     deviceState = s;
    //   });
    //   if (s == BluetoothDeviceState.connected) {
    //     device.discoverServices().then((s) {
    //       setState(() {
    //         services = s;
    //       });
    //     });
    //   }
    // });
  }

  _disconnect() {
// Remove all value changed listeners
    valueChangedSubscriptions.forEach((uuid, sub) => sub.cancel());
    valueChangedSubscriptions.clear();
    deviceStateSubscription?.cancel();
    deviceStateSubscription = null;
    deviceConnection?.cancel();
    deviceConnection = null;
    setState(() {
      device = null;
    });
  }

  _readCharacteristic(BluetoothCharacteristic c) async {
    await c.read();
    setState(() {});
  }

  _writeCharacteristic(BluetoothCharacteristic c) async {
    await c.write([0x12, 0x34]);
    setState(() {});
  }

  _readDescriptor(BluetoothDescriptor d) async {
    await d.read();
    setState(() {});
  }

  _writeDescriptor(BluetoothDescriptor d) async {
    await d.write([0x12, 0x34]);
    setState(() {});
  }

  _setNotification(BluetoothCharacteristic c) async {
    if (c.isNotifying) {
      await c.setNotifyValue(false);
      // Cancel subscription
      valueChangedSubscriptions[c.uuid]?.cancel();
      valueChangedSubscriptions.remove(c.uuid);
    } else {
      await c.setNotifyValue(true);
      // ignore: cancel_subscriptions
      // final sub = c.onValueChanged().listen((d) {
      //   setState(() {
      //     print('onValueChanged $d');
      //   });
      // });
      // Add to map
      // valueChangedSubscriptions[c.uuid] = sub;
    }
    setState(() {});
  }

  _refreshDeviceState(BluetoothDevice d) async {
    var state = d.state;
    setState(() {
      deviceState = state as BluetoothDeviceState;
      print('State refreshed: $deviceState');
    });
  }

  _buildScanningButton() {
    if (isConnected || state != BluetoothState.on) {
      return null;
    }
    if (isScanning) {
      return FloatingActionButton(
        child: Icon(Icons.stop),
        onPressed: _stopScan,
        backgroundColor: Colors.red,
      );
    } else {
      return FloatingActionButton(
          child: Icon(Icons.search), onPressed: _startScan);
    }
  }

  _buildScanResultTiles() {
    return scanResults.values
        .map((r) => ListTile(
              title: Text(r.toString()),
              onTap: () => _connect(r.device),
            ))
        .toList();
  }

  // List<Widget> _buildServiceTiles() {
  //   return services
  //       .map(
  //         (s) => new ListTile(
  //           title: Text(s.toString()),
  //           // characteristicTiles: s.characteristics
  //           //     .map(
  //           //       (c) => new CharacteristicTile(
  //           //         characteristic: c,
  //           //         onReadPressed: () => _readCharacteristic(c),
  //           //         onWritePressed: () => _writeCharacteristic(c),
  //           //         onNotificationPressed: () => _setNotification(c),
  //           //         descriptorTiles: c.descriptors
  //           //             .map(
  //           //               (d) => new DescriptorTile(
  //           //                 descriptor: d,
  //           //                 onReadPressed: () => _readDescriptor(d),
  //           //                 onWritePressed: () => _writeDescriptor(d),
  //           //               ),
  //           //             )
  //           //             .toList(),
  //           //       ),
  //               ),
  //               // .toList(),
  //         ),
  //       )
  //       .toList();
  // }

  _buildActionButtons() {
    if (isConnected) {
      return <Widget>[
        new IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: () => _disconnect(),
        )
      ];
    }
  }

  _buildAlertTile() {
    return new Container(
      color: Colors.redAccent,
      child: new ListTile(
        title: new Text(
          'Bluetooth adapter is ${state.toString().substring(15)}',
          style: Theme.of(context).primaryTextTheme.subhead,
        ),
        trailing: new Icon(
          Icons.error,
          color: Theme.of(context).primaryTextTheme.subhead.color,
        ),
      ),
    );
  }

  _buildDeviceStateTile() {
    return ListTile(
        leading: (deviceState == BluetoothDeviceState.connected)
            ? const Icon(Icons.bluetooth_connected)
            : const Icon(Icons.bluetooth_disabled),
        title: Text('Device is ${deviceState.toString().split('.')[1]}.'),
        subtitle: Text('${device.id}'),
        trailing: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _refreshDeviceState(device),
          color: Theme.of(context).iconTheme.color.withOpacity(0.5),
        ));
  }

  _buildProgressBarTile() {
    return LinearProgressIndicator();
  }

  @override
  Widget build(BuildContext context) {
    var tiles = new List<Widget>();
    tiles.add(Center(
      child: RaisedButton(
        child: Text('Advertising'),
        onPressed: _startAdvertise,
      ),
    ));
    if (state != BluetoothState.on) {
      tiles.add(_buildAlertTile());
    }
    if (isConnected) {
      tiles.add(_buildDeviceStateTile());
      // tiles.addAll(_buildServiceTiles());
    } else {
      tiles.addAll(_buildScanResultTiles());
    }
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('FlutterBlue'),
          actions: _buildActionButtons(),
        ),
        floatingActionButton: _buildScanningButton(),
        body: new Stack(
          children: <Widget>[
            (isScanning) ? _buildProgressBarTile() : new Container(),
            Text(_isAdvertising),
            ListView(
              children: tiles,
            )
          ],
        ),
      ),
    );
  }
}
