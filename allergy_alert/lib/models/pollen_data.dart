class PollenData {
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

  factory PollenData.fromJson(Map<String, dynamic> json) {
    final hourly = json['hourly'];
    if (hourly == null) {
      return PollenData(
        birchPollen: 0.0,
        grassPollen: 0.0,
        olivePollen: 0.0,
        time: DateTime.now().toString(),
      );
    }

    List<dynamic> birchList = hourly['birch_pollen'] ?? [];
    List<dynamic> grassList = hourly['grass_pollen'] ?? [];
    List<dynamic> oliveList = hourly['olive_pollen'] ?? [];
    List<dynamic> timeList = hourly['time'] ?? [];

    int currentIndex = 0;
    final now = DateTime.now();
    for (int i = 0; i < timeList.length; i++) {
      final t = DateTime.tryParse(timeList[i].toString());
      if (t != null &&
          t.year == now.year &&
          t.month == now.month &&
          t.day == now.day &&
          t.hour == now.hour) {
        currentIndex = i;
        break;
      }
    }

    return PollenData(
      birchPollen: currentIndex < birchList.length
          ? (birchList[currentIndex] as num).toDouble()
          : 0.0,
      grassPollen: currentIndex < grassList.length
          ? (grassList[currentIndex] as num).toDouble()
          : 0.0,
      olivePollen: currentIndex < oliveList.length
          ? (oliveList[currentIndex] as num).toDouble()
          : 0.0,
      time: currentIndex < timeList.length
          ? timeList[currentIndex].toString()
          : DateTime.now().toString(),
    );
  }
}

PollenData parsePollenTodayFromJson(Map<String, dynamic> json) {
  return PollenData.fromJson(json);
}

List<PollenData> parsePollenForecastFromJson(Map<String, dynamic> json) {
  final hourly = json['hourly'];
  final List<PollenData> forecastList = [];

  if (hourly != null && hourly['time'] != null) {
    List<dynamic> times = hourly['time'];
    List<dynamic> birch = hourly['birch_pollen'] ?? [];
    List<dynamic> grass = hourly['grass_pollen'] ?? [];
    List<dynamic> olive = hourly['olive_pollen'] ?? [];

    for (int i = 24 + 12; i < times.length; i += 24) {
      forecastList.add(
        PollenData(
          birchPollen: (i < birch.length && birch[i] != null)
              ? (birch[i] as num).toDouble()
              : 0.0,
          grassPollen: (i < grass.length && grass[i] != null)
              ? (grass[i] as num).toDouble()
              : 0.0,
          olivePollen: (i < olive.length && olive[i] != null)
              ? (olive[i] as num).toDouble()
              : 0.0,
          time: times[i].toString(),
        ),
      );
    }
  }
  return forecastList;
}
