import 'dart:convert';
import 'dart:io';

import 'package:bluetooth_low_energy/dashboard/bpmChart.dart';
import 'package:bluetooth_low_energy/dashboard/spo2Chart.dart';
import 'package:bluetooth_low_energy/data.dart';
import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:permission_handler/permission_handler.dart';

import '../bluetooth/bluetooth_constant.dart';

// ignore: must_be_immutable
class Chartscreen extends StatefulWidget {
  List<MyBluetoothData> datanya;
  Chartscreen({super.key, required this.datanya});

  @override
  State<Chartscreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<Chartscreen> {
  String userUid = "";
  int mode = 0;

  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserUid();
  }

  void getUserUid() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      userUid = user!.uid; // Default jika tidak ada pengguna
      ///
    });
  }

  DateTime splitStringToDateTime(String inputString) {
    int year = int.parse(inputString.substring(0, 4));
    int month = int.parse(inputString.substring(4, 6));
    int day = int.parse(inputString.substring(6, 8));
    int hour = int.parse(inputString.substring(8, 10));
    int minute = int.parse(inputString.substring(10, 12));
    int second = int.parse(inputString.substring(12, 14));
    print(year);
    print(month);
    print(day);
    print(hour);
    print(minute);
    print(second);
    return DateTime(year, month, day, hour, minute, second);
  }

  Future<List<MyBluetoothData>> ambilkanbulanbu() async {
    List<MyBluetoothData> listnyacoy = [];
    listnyacoy.clear();
    final FirebaseDatabase _database = FirebaseDatabase.instance;
    DatabaseEvent datanyacoy =
        await _database.ref().child("users").child(userUid).once();
    var tes = jsonEncode(datanyacoy.snapshot.value);
    Map<String, dynamic> tes2 = jsonDecode(tes);
    Map<String, dynamic> tes3 = tes2["sensorstorage"];
    tes3["bpm"].forEach((k, v) {
      DateTime dateTime = splitStringToDateTime(k);
      listnyacoy.add(
          MyBluetoothData(date: dateTime, bpm: v, oksigen: tes3["oxygen"][k]));
      // print("Key: $k, BPM: $v, Oksigen: ${tes3["oksigen"][k]}");
    });
    return listnyacoy;
  }

  exporttoExcel() async {
    // ambilkanbulanbu();
    requestStoragePermission();
    List<MyBluetoothData> merger = await ambilkanbulanbu();
    print(merger);
    // print(ambilkanbulanbu());
    Excel excel = Excel.createExcel();
    excel.rename(excel.getDefaultSheet()!, "Smart Cap Data");
    String namaSheet = "Smart Cap Data";
    Sheet sheet = excel[namaSheet];
    // List<Sheet>listCell=[];
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        TextCellValue("Date Time");
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value =
        TextCellValue("BPM");
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value =
        TextCellValue("Oksigen");

    for (int i = 0; i < merger.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          .value = TextCellValue(merger[i].date.toString());
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
          .value = IntCellValue(merger[i].bpm);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
          .value = IntCellValue(merger[i].oksigen);
    }
    // var fileBytes = excel.save(fileName: "Smart Cap.xlsx");
    // var directory = await getApplicationDocumentsDirectory();

    try {
      File result = await writeExcel(excel);
      if (result != null) {
        // Success
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Data exported successfully to ${result.path}'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Failure
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to export data!'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Handle error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Error: $e'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  // Future<void> createFolderAndFile() async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final filePath = File('${directory.path}/smart_cap.xls');

  //   // Cek apakah folder sudah ada
  //   if (!await Directory(filePath).exists()) {
  //     // Buat folder jika belum ada
  //     await Directory(filePath).create(recursive: true);
  //   }

  //   // Cek apakah file sudah ada
  //   if (!await File(filePath).exists()) {
  //     // Buat file jika belum ada
  //     await File(filePath).create();
  //   }
  // }

  // Future<String> get _localPath async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   return directory.path;
  // }

  // Future<Directory> get _exportDirectory async {
  //   final path = await _localPath;
  //   final directory = Directory('$path/Export Smartcap');
  //   if (!await directory.exists()) {
  //     await directory.create(recursive: true);
  //   }
  //   return directory;
  // }

  // Future<File> get _localFile async {
  //   final directory = await _exportDirectory;
  //   return File('${directory.path}/smart_cap.xlsx');
  // }

  // Future<File> writeExcel(Excel excelcoy) async {
  //   final file = await _localFile;
  //   return file.writeAsBytes(excelcoy.encode()!);
  // }
  Future<File> writeExcel(Excel excelcoy) async {
    // Dapatkan path penyimpanan di folder Android/data
    final directory = Directory('/storage/emulated/0/Download/Export Smartcap');

    // Cek apakah direktori ada, jika tidak, buat direktori tersebut
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    // Simpan file di direktori tersebut
    final file = File('${directory.path}/smartcap.xls');

    return file.writeAsBytes(excelcoy.encode()!);
  }

  @override
  Widget build(BuildContext context) {
    // if (widget.datanya.length >= 7) {
    //   widget.datanya.insert(
    //       0,
    //       MyBluetoothData(
    //           date: DateTime(0),
    //           bpm: widget.datanya[0].bpm.toInt(),
    //           oksigen: widget.datanya[0].oksigen.toInt()));
    //   widget.datanya.removeAt(7);
    // } else {
    //   widget.datanya.add(MyBluetoothData(
    //       date: DateTime(0),
    //       bpm: widget.datanya[0].bpm.toInt(),
    //       oksigen: widget.datanya[0].oksigen.toInt()));
    // }
    //  if (widget.datanya.isEmpty) {
    //     bpmtext = "0";
    //     oksigentext = "0";
    //   } else {
    //   widget.datanya.sort((a, b) => b.date.compareTo(a.date));
    //     bpmtext = widget.datanya.first.bpm.toString();
    //     oksigentext = widget.datanya.first.oksigen.toString();
    //   }

    Size size = MediaQuery.sizeOf(context);

    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                IconButton(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/back.png',
                      width: 40,
                    )),
                SizedBox(
                  width: 20,
                ),
                Text('Historical Data',
                    style: GoogleFonts.poppins(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: size.width,
              height: size.height * 0.08,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          mode = 0;
                        });
                      },
                      borderRadius:
                          BorderRadius.circular(15), // Match gradient shape
                      child: Container(
                        width: size.width * 0.35,
                        // padding:
                        //     const EdgeInsets.symmetric(horizontal: 50, vertical: 0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: mode == 0
                                ? [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.secondary,
                                    Theme.of(context).colorScheme.tertiary,
                                  ]
                                : [
                                    Colors.white,
                                    Colors.white
                                  ], // Same color for a solid effect
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            'Bpm',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              color: mode == 0 // Ternary operator for color
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          mode = 1;
                        });
                      },
                      borderRadius:
                          BorderRadius.circular(15), // Match gradient shape
                      child: Container(
                        width: size.width * 0.35,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: mode == 0
                                ? [Colors.white, Colors.white]
                                : [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.secondary,
                                    Theme.of(context).colorScheme.tertiary,
                                  ], // Same color for a solid effect
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            'SpO2',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              color: mode == 1 // Ternary operator for color
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: size.width,
              height: size.height * 0.4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 22, bottom: 20),
                child: mode == 0
                    ? Bpmchart(datanya: widget.datanya)
                    : Spo2Chart(datanya: widget.datanya),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Container(
              height: size.height * 0.06,
              width: size.width * 0.4,
              child: InkResponse(
                onTap: () {
                  exporttoExcel();
                },
                // borderRadius: BorderRadius.circular(5), // Match gradient shape
                highlightColor:
                    Colors.white.withOpacity(0.5), // Color when pressed
                splashColor:
                    Colors.white.withOpacity(0.5), // Color when pressed
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                        Theme.of(context).colorScheme.tertiary,
                      ], // Same color for a solid effect
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      'Export',
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    ));
  }
}
