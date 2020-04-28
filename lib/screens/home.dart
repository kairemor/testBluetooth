import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:xeexcorona/helpers/style.dart';
import 'package:xeexcorona/providers/bluetooth.dart';
import 'package:xeexcorona/widgets/custom_text.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const platform = const MethodChannel('bluetooth-mac-address');

  String _bluetooth_address = 'Unknown mac address.';

  Future<void> _getBatteryLevel() async {
    var bluetoothAddress;
    try {
      final result = await platform.invokeMethod('getMacAddress');
      bluetoothAddress = 'bluetooth mac address $result .';
    } on PlatformException catch (e) {
      bluetoothAddress =
          "Failed to get mac address bluetooth : '${e.message}'.";
    }

    setState(() {
      _bluetooth_address = bluetoothAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    final blue = Provider.of<BlueToothProvider>(context);
    final devices = Provider.of<BlueToothProvider>(context).devices;
    List<Widget> devicesView = [];
    for (String device in devices) {
      devicesView.add(ListTile(title: Text(device.toString())));
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: white,
          title: CustomText(text: "Corona Out"),
          centerTitle: true,
          elevation: 0.5,
        ),
        backgroundColor: white,
        body: blue.isOn
            ? Column(
                children: <Widget>[
                  Material(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          RaisedButton(
                            child: Text('Get bluetooth address'),
                            onPressed: _getBatteryLevel,
                          ),
                          Text(_bluetooth_address)
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomText(
                      text: "People Near You!",
                      size: 24,
                      weight: FontWeight.w300,
                      color: primary,
                    ),
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomText(
                      text: blue.data,
                      size: 18,
                      weight: FontWeight.w300,
                      color: grey,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomText(
                      text: "All people !",
                      size: 24,
                      weight: FontWeight.w300,
                      color: primary,
                    ),
                  ),
                  Container(
                      child: Column(
                    children: devicesView,
                  ))
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Your Bluetooth is turned off, please turn on the bluetooth and click on 'refresh'",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: grey),
                    ),
                  ),
                  FlatButton.icon(
                      onPressed: () {
                        blue.turnOn();
                      },
                      icon: Icon(Icons.refresh),
                      label: CustomText(text: "refresh")),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
      ),
    );
  }
}
