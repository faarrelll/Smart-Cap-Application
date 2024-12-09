import 'dart:convert';

class MyData {
  Sensorstorage sensorstorage;

  MyData({
    required this.sensorstorage,
  });

  factory MyData.fromRawJson(String str) => MyData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MyData.fromJson(Map<String, dynamic> json) => MyData(
        sensorstorage: Sensorstorage.fromJson(json["sensorstorage"]),
      );

  Map<String, dynamic> toJson() => {
        "sensorstorage": sensorstorage.toJson(),
      };
}

class Sensorstorage {
  Map<String, int> bpm;
  Map<String, int> oxygen;

  Sensorstorage({
    required this.bpm,
    required this.oxygen,
  });

  factory Sensorstorage.fromRawJson(String str) =>
      Sensorstorage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Sensorstorage.fromJson(Map<String, dynamic> json) => Sensorstorage(
        bpm: Map.from(json["bpm"]).map((k, v) => MapEntry<String, int>(k, v)),
        oxygen:
            Map.from(json["oxygen"]).map((k, v) => MapEntry<String, int>(k, v)),
      );

  Map<String, dynamic> toJson() => {
        "bpm": Map.from(bpm).map((k, v) => MapEntry<String, dynamic>(k, v)),
        "oxygen":
            Map.from(oxygen).map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}
