import 'package:bluetooth_low_energy/dashboard/home.dart';
import 'package:bluetooth_low_energy/login/sign-in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../bluetooth/bluetooth_constant.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mendapatkan user yang sedang login
    User? user = FirebaseAuth.instance.currentUser;

    // Cek apakah user sudah login atau belum
    if (user != null) {
      // Jika sudah login, arahkan ke Dashboard
      return Dashboard(device: BluetoothDevice(remoteId: const DeviceIdentifier(DEVICE_MAC_ID)));
    } else {
      // Jika belum login, arahkan ke halaman Sign-in
      return Signin();
    }
  }
}
