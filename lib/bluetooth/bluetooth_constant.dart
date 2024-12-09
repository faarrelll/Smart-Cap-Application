import 'dart:convert';


const DEVICE_MAC_ID = "84:FC:E6:52:4B:95";
const SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
const CHARACTERISTIC_DATA = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
// const CHARACTERISTIC_UUID_TX = "04d3552e-b9b3-4be6-a8b4-aa43c4507c4d";

class MyBluetoothData {
    DateTime date;
    int bpm;
    int oksigen;

    MyBluetoothData({
        required this.date,
        required this.bpm,
        required this.oksigen,
    });

    factory MyBluetoothData.fromRawJson(String str) => MyBluetoothData.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory MyBluetoothData.fromJson(Map<String, dynamic> json) => MyBluetoothData(
        date: DateTime.parse(json["date"]),
        bpm: json["bpm"],
        oksigen: json["oksigen"],
    );

    Map<String, dynamic> toJson() => {
        "date": date.toIso8601String(),
        "bpm": bpm,
        "oksigen": oksigen,
    };

  compareTo(MyBluetoothData a) {}
}