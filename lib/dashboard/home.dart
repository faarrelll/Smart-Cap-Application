import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:bluetooth_low_energy/bluetooth/bluetooth_utils/extra.dart';
import 'package:bluetooth_low_energy/dashboard/chart.dart';
import 'package:bluetooth_low_energy/dashboard/main-screen.dart';
import 'package:bluetooth_low_energy/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../bluetooth/bluetooth_constant.dart';

class Dashboard extends StatefulWidget {
  final BluetoothDevice device;
  const Dashboard({super.key, required this.device});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String userUid = "";
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  int index = 0;
  int? _rssi;
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;
  List<BluetoothService> _services = [];
  bool _isDiscoveringServices = false;
  bool _isConnecting = false;
  bool _isDisconnecting = false;

  List<MyBluetoothData> _mydata = [];

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;
  late StreamSubscription<bool> _isConnectingSubscription;
  late StreamSubscription<bool> _isDisconnectingSubscription;
  List<int> _value = [];
  late StreamSubscription<List<int>> _lastValueSubscription;

  @override
  void initState() {
    super.initState();
    getUserUid();
    _connectionStateSubscription =
        widget.device.connectionState.listen((state) async {
      _connectionState = state;
      if (state == BluetoothConnectionState.connected) {
        _services = []; // must rediscover services
      }
      if (state == BluetoothConnectionState.connected && _rssi == null) {
        _rssi = await widget.device.readRssi();
      }

      // if (state == BluetoothConnectionState.disconnected) {
      //   backToHome(true);
      // }
    });
    _isConnectingSubscription = widget.device.isConnecting.listen((value) {
      _isConnecting = value;
      setState(() {});
    });

    _isDisconnectingSubscription =
        widget.device.isDisconnecting.listen((value) {
      _isDisconnecting = value;
      setState(() {});
    });

    onDiscoverServices();
  }

  void getUserUid() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      userUid = user!.uid; // Default jika tidak ada pengguna
    });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();

    _isConnectingSubscription.cancel();
    _isDisconnectingSubscription.cancel();
    _lastValueSubscription.cancel();

    _mydata.clear();
    super.dispose();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  Future onConnect() async {
    try {
      await widget.device.connectAndUpdateStream();
    } catch (e) {
      if (e is FlutterBluePlusException &&
          e.code == FbpErrorCode.connectionCanceled.index) {
      } else {
        print("Connect Error:${e.toString()}");
      }
    }
  }

  Future onCancel() async {
    try {
      await widget.device.disconnectAndUpdateStream(queue: false);
    } catch (e) {
      print("Cancel Error:${e.toString()}");
    }
  }

  Future onDisconnect() async {
    try {
      await widget.device.disconnectAndUpdateStream();
    } catch (e) {
      print("Disconnect Error:${e.toString()}");
    }
  }

  Future onDiscoverServices() async {
    _isDiscoveringServices = true;
    try {
      _services = await widget.device.discoverServices();
      final targetServiceUUID =
          _services.singleWhere((item) => item.serviceUuid.str == SERVICE_UUID);

      final targetCharacterUUID = targetServiceUUID.characteristics.singleWhere(
          (item) => item.characteristicUuid.str == CHARACTERISTIC_DATA);

      await targetCharacterUUID.setNotifyValue(true);

      _lastValueSubscription =
          targetCharacterUUID.lastValueStream.listen((value) {
        _value = value;
        // print(value);
        // print(value.length);
        // print("targetCharacterUUID : ");
        String decoded = utf8.decode(_value);
        String data = "test : $decoded"; //_value.toString();
        // print(data);
        List<String> dataku = decoded.split("#"); //_value.toString();
        // print(dataku);
        var mydate = DateTime.now();
        var outputFormat = DateFormat('yyyyMMddhhmmss');
        String dateKirim = outputFormat.format(mydate);
        int bpmnya = int.parse(dataku[0]);
        int oksigennya = int.parse(dataku[1]);
        if (bpmnya < 60) {
          NotifService.showNotification(
              'Peringatan', 'Anda Mengalami Bradycardia!');
        } else if (bpmnya > 100) {
          NotifService.showNotification(
              'Peringatan', 'Anda Mengalami Tachycardia!');
        }
        // print(bpmnya);
        ref
            .child("users")
            .child(userUid)
            .child("sensorstorage")
            .child("bpm")
            // .child(dateKirim)
            .update({
          dateKirim: bpmnya,
        });
        ref
            .child("users")
            .child(userUid)
            .child("sensorstorage")
            .child("oxygen")
            // .child(dateKirim)
            .update({dateKirim: oksigennya});
        _mydata.add(
            MyBluetoothData(date: mydate, bpm: bpmnya, oksigen: oksigennya));
        _mydata.sort((a, b) => b.date.compareTo(a.date));
        // print(_mydata);
        setState(() {});
      });
    } catch (e) {
      print("Discover Services Error:${e.toString()}");
    }
    _isDiscoveringServices = false;
  }

  @override
  Widget build(BuildContext context) {
    // print("ini datanya ");
    // print(widget.device!.remoteId);

    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      bottomNavigationBar: Container(
        height: size.height * 0.105,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black87.withOpacity(0.04),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(
                  0, -5), // adjust the offset to make the shadow extend upwards
            ),
          ],
        ),
        child: SafeArea(
          child: PhysicalModel(
            color: Colors.black.withOpacity(0.25),
            shadowColor: Colors.black87,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            elevation: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              child: BottomNavigationBar(
                onTap: (value) => setState(() {
                  index = value;
                }),
                backgroundColor: Colors.white,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                elevation: 5,
                items: [
                  BottomNavigationBarItem(
                    icon: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: index == 0
                                ? Colors.black87.withOpacity(0.15)
                                : Colors.white,
                            spreadRadius: 5,
                            blurRadius: 10,
                            offset: const Offset(0,
                                0), // adjust the offset to make the shadow extend upwards
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/home.png',
                        width: 27,
                      ),
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: index == 1
                                ? Colors.black87.withOpacity(0.15)
                                : Colors.white,
                            spreadRadius: 5,
                            blurRadius: 10,
                            offset: const Offset(0,
                                0), // adjust the offset to make the shadow extend upwards
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/chart.png',
                        width: 27,
                      ),
                    ),
                    label: 'Chart',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: index == 0
          ? Mainscreen(
              datanya: _mydata,
            )
          : Chartscreen(datanya: _mydata),
    );
  }
}
