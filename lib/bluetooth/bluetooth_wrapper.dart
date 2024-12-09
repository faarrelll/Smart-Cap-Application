import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'bluetooth_screen/bluetooth_off_screen.dart';
import 'bluetooth_screen/scan_screen.dart';

class BluetoothScan extends StatefulWidget {
  const BluetoothScan({super.key});

  @override
  State<BluetoothScan> createState() => _BluetoothScanState();
}

class _BluetoothScanState extends State<BluetoothScan>
    with WidgetsBindingObserver {
  //Bluetooth Adapter
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  List<BluetoothDevice> _connectedDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  @override
  void initState() {
    super.initState();
    _adapterStateStateSubscription =
        FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      if (mounted) {
        setState(() {});
      }
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // ignore: unnecessary_null_comparison
        if (!_isScanning == null) {
          onScanning();
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        onStopScanning();
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // StreamSubscription<BluetoothAdapterState>? adapterStateSubscription;

    // Widget screen = _adapterState == BluetoothAdapterState.on
    //     ? const ScanScreen()
    //     : BluetoothOffScreen(adapterState: _adapterState);
    return _adapterState == BluetoothAdapterState.on
        ? ScanScreen()
        : _adapterState == BluetoothAdapterState.off
            ? BluetoothOffScreen()
            : Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
              );
    // MaterialApp(
    //   color: Colors.lightBlue,
    //   debugShowCheckedModeBanner: false,
    //   theme: ThemeData(
    //       colorScheme: const ColorScheme.light(
    //           surface: Color(0xffF3F4F6),
    //           onSurface: Colors.black,
    //           primary: Color(0xff00B2E7),
    //           secondary: Color(0xff00C4FF),
    //           tertiary: Color(0xff85E3FF),
    //           outline: Color(0xffA1B1C6))),
    //   home: screen,
    //   navigatorObservers: [BluetoothAdapterStateObserver()],
    // );
  }

  void bleInit() {
    _adapterStateStateSubscription =
        FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      setState(() {});
    });

    FlutterBluePlus.systemDevices.then((devices) {
      _connectedDevices = devices;
      // print(_connectedDevices.toString());
      setState(() {});
    });

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      // findTargetDevice();
    }, onError: (e) {});

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      setState(() {});
    });

    onScanning();
  }

  Future onScanning() async {
    try {
      // android is slow when asking for all advertisments,
      // so instead we only ask for 1/8 of them
      int divisor = Platform.isAndroid ? 8 : 1;
      await FlutterBluePlus.startScan(
          timeout: null, continuousUpdates: true, continuousDivisor: divisor);
    } catch (e) {}
    setState(() {}); // force refresh of systemDevices
  }

  Future onStopScanning() async {
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {}
  }
}
