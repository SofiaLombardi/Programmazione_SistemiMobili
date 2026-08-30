import 'dart:convert';
import 'package:allergy_alert/models/pollen_data.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = 'https://air-quality-api.open-meteo.com/v1/air-quality';

  // Chiamata n.1: Pollini di oggi
  Future<PollenData> getTodayPollen(double lat, double lon) async {
    final url = Uri.parse(
      '$_baseUrl?latitude=$lat&longitude=$lon&hourly=birch_pollen,grass_pollen,olive_pollen&forecast_days=1',
    );

    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'AllergyAlertApp/1.0',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedData = json.decode(response.body);
      return PollenData.fromJson(decodedData);
    } else {
      throw Exception('Errore risposta server: ${response.statusCode}');
    }
  }

  // Chiamata n.2: Previsioni a 3 giorni
  Future<List<PollenData>> getPollenForecast(double lat, double lon) async {
    final url = Uri.parse(
      '$_baseUrl?latitude=$lat&longitude=$lon&hourly=birch_pollen,grass_pollen,olive_pollen&forecast_days=3',
    );

    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'AllergyAlertApp/1.0',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedData = json.decode(response.body);
      final hourly = decodedData['hourly'];
      final List<PollenData> forecastList = [];

      if (hourly != null && hourly['time'] != null) {
        List<dynamic> times = hourly['time'];
        List<dynamic> birch = hourly['birch_pollen'] ?? [];
        List<dynamic> grass = hourly['grass_pollen'] ?? [];
        List<dynamic> olive = hourly['olive_pollen'] ?? [];

        // Recupero un dato ogni 24 ore
        for (int i = 0; i < times.length; i += 24) {
          forecastList.add(PollenData(
            birchPollen: (i < birch.length && birch[i] != null) ? (birch[i] as num).toDouble() : 0.0,
            grassPollen: (i < grass.length && grass[i] != null) ? (grass[i] as num).toDouble() : 0.0,
            olivePollen: (i < olive.length && olive[i] != null) ? (olive[i] as num).toDouble() : 0.0,
            time: times[i].toString(),
          ));
        }
      }
      return forecastList;
    } else {
      throw Exception('Errore risposta server: ${response.statusCode}');
    }
  }
}