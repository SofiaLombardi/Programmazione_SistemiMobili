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
    final dynamic hourlyRaw = json['hourly'];
    if (hourlyRaw is! Map<String, dynamic>) {
      return PollenData(
        birchPollen: 0.0,
        grassPollen: 0.0,
        olivePollen: 0.0,
        time: DateTime.now().toString(),
      );
    }

    final Map<String, dynamic> hourly = hourlyRaw;

    final List<dynamic> birchList =
        (hourly['birch_pollen'] as List<dynamic>?) ?? [];
    final List<dynamic> grassList =
        (hourly['grass_pollen'] as List<dynamic>?) ?? [];
    final List<dynamic> oliveList =
        (hourly['olive_pollen'] as List<dynamic>?) ?? [];
    final List<dynamic> timeList =
        (hourly['time'] as List<dynamic>?) ?? [];

    int currentIndex = 0;
    final DateTime now = DateTime.now();

    for (int i = 0; i < timeList.length; i++) {
      final DateTime? t = DateTime.tryParse(timeList[i].toString());
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
      birchPollen: currentIndex < birchList.length && birchList[currentIndex] != null
          ? (birchList[currentIndex] as num).toDouble()
          : 0.0,
      grassPollen: currentIndex < grassList.length && grassList[currentIndex] != null
          ? (grassList[currentIndex] as num).toDouble()
          : 0.0,
      olivePollen: currentIndex < oliveList.length && oliveList[currentIndex] != null
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
  final dynamic hourlyRaw = json['hourly'];
  final List<PollenData> forecastList = [];

  if (hourlyRaw is Map<String, dynamic> && hourlyRaw['time'] != null) {
    final List<dynamic> times = (hourlyRaw['time'] as List<dynamic>?) ?? [];
    final List<dynamic> birch = (hourlyRaw['birch_pollen'] as List<dynamic>?) ?? [];
    final List<dynamic> grass = (hourlyRaw['grass_pollen'] as List<dynamic>?) ?? [];
    final List<dynamic> olive = (hourlyRaw['olive_pollen'] as List<dynamic>?) ?? [];

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