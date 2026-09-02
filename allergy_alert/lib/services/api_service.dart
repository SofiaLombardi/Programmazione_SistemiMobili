import 'dart:convert';
import 'package:allergy_alert/models/pollen_data.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl =
      'https://air-quality-api.open-meteo.com/v1/air-quality';

  Future<PollenData> getTodayPollen(double lat, double lon) async {
    final Uri url = Uri.parse(
      '$_baseUrl?latitude=$lat&longitude=$lon&hourly=birch_pollen,grass_pollen,olive_pollen&forecast_days=1',
    );

    final http.Response response = await http.get(
      url,
      headers: {
        'User-Agent': 'AllergyAlertApp/1.0',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedData =
          jsonDecode(response.body) as Map<String, dynamic>;
      return await compute(parsePollenTodayFromJson, decodedData);
    } else {
      throw Exception('Errore risposta server: ${response.statusCode}');
    }
  }

  Future<List<PollenData>> getPollenForecast(double lat, double lon) async {
    final Uri url = Uri.parse(
      '$_baseUrl?latitude=$lat&longitude=$lon&hourly=birch_pollen,grass_pollen,olive_pollen&forecast_days=3',
    );

    final http.Response response = await http.get(
      url,
      headers: {
        'User-Agent': 'AllergyAlertApp/1.0',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedData =
          jsonDecode(response.body) as Map<String, dynamic>;
      return await compute(parsePollenForecastFromJson, decodedData);
    } else {
      throw Exception('Errore risposta server: ${response.statusCode}');
    }
  }
}