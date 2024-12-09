// Copyright 2017-2023, Charles Weinberger & Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:bluetooth_low_energy/app_view.dart';
import 'package:bluetooth_low_energy/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotifService.init();
  await Firebase.initializeApp();
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(const MyApp());
}

//
// This widget shows BluetoothOffScreen or
// ScanScreen depending on the adapter state
//
