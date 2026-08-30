
class PollenData{
  final double birchPollen;
  final double grassPollen;
  final double olivePollen;
  final String time;

PollenData({
  required this.birchPollen,
  required this.grassPollen,
  required this.olivePollen,
  required this.time,
});

//costruttore per convertire i adti JSON dell'API in un oggetto Dart
factory PollenData.fromJson(Map<String, dynamic> json){
  final hourly = json ['hourly'];
  if (hourly == null){
  return PollenData(
    birchPollen: (hourly['birchPollen'][0] as num). toDouble(),
    grassPollen: (hourly['grassPollen'][0] as num). toDouble(),
    olivePollen: (hourly['olivePollen'][0] as num). toDouble(),
    time: json['time'] as String,
    );
  }
    List<dynamic> birchList = hourly['birch_pollen'] ?? [];
    List<dynamic> grassList = hourly['grass_pollen'] ?? [];
    List<dynamic> oliveList = hourly['olive_pollen'] ?? [];
    List<dynamic> timeList = hourly['time'] ?? [];

    return PollenData(
      birchPollen: birchList.isNotEmpty ? (birchList[0] as num).toDouble() : 0.0,
      grassPollen: grassList.isNotEmpty ? (grassList[0] as num).toDouble() : 0.0,
      olivePollen: oliveList.isNotEmpty ? (oliveList[0] as num).toDouble() : 0.0,
      time: timeList.isNotEmpty ? timeList[0].toString() : DateTime.now().toString(),
    );
  }
}