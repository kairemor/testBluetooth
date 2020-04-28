import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xeexcorona/bluetooth-ble.dart';
import 'package:xeexcorona/providers/bluetooth.dart';
import 'package:xeexcorona/screens/home.dart';

import 'bluetoothBlue.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider.value(value: BlueToothProvider.initialize()),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'XeexCovid19',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ScreensController());
  }
}

class ScreensController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final data = Provider.of<BlueToothProvider>(context).data;
    // final dataBlue = Provider.of<BlueToothProvider>(context).dataBlue;

    // print("/--------blue $data------ : $dataBlue");
    // return Scaffold(
    //   appBar: AppBar(title: Text("Xeex Corona")),
    //   body: Center(child: Column(children: [Text(data), Text(dataBlue)])),
    // );

    // return Home();
    return FlutterBlueApp();
    // return BleLib();
  }
}
