import 'dart:async';
import 'dart:io';
import 'package:allergy_alert/models/pollen_data.dart';
import 'package:allergy_alert/models/symptom_log.dart';
import 'package:allergy_alert/services/api_service.dart';
import 'package:allergy_alert/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AllergyViewModel extends ChangeNotifier {
  final ApiService _apiservice = ApiService();
  final StorageService _storageService = StorageService();

  PollenData? todayPollen;
  List<PollenData> forecastPollen = [];
  List<SymptomLog> symptomHistory = [];

  bool isLoading = false;
  String? errorMessage;
  String alertMessage = "Nessun alert imminente rilevato.";

  bool isOnline = true;
  bool hasHighRisk = false;

  // Coordinate di default per Roma (lat: 41.8919, lon: 12.5113)
  final double _defaultLat = 41.8919;
  final double _defaultLon = 12.5113;

  AllergyViewModel() {
    Future.microtask(() => loadAppData());
  }

  Future<void> loadAppData() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final responses = await Future.wait([
        _apiservice.getTodayPollen(_defaultLat, _defaultLon),
        _apiservice.getPollenForecast(_defaultLat, _defaultLon),
      ]);

      todayPollen = responses[0] as PollenData;
      forecastPollen = responses[1] as List<PollenData>;

      isOnline = true;
      symptomHistory = await _storageService.getSymptoms();
      _generateAlert();
    } on http.ClientException catch (_) {
      _setOfflineState();
    } on TimeoutException catch (_) {
      errorMessage =
          'Il server non risponde: controlla la connessione e riprova.';
      _setOfflineState();
    } on FormatException catch (_) {
      errorMessage = 'I dati ricevuti dal server non sono validi.';
    } on SocketException catch (_) {
      _setOfflineState();
    } catch (_) {
      errorMessage = 'Impossibile aggiornare i dati. Riprova più tardi.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _setOfflineState() {
    isOnline = false;
    errorMessage =
        'Nessuna connessione a Internet. Controlla la rete e riprova.';
  }

  Future<void> addSymptomLog(int severity, String note) async {
    final now = DateTime.now();
    final dateString =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final newLog = SymptomLog(date: dateString, severity: severity, note: note);

    await _storageService.saveSymptom(newLog);

    symptomHistory = await _storageService.getSymptoms();
    notifyListeners();
  }

  void _generateAlert() {
    if (forecastPollen.isEmpty) return;

    bool riskDetected = false;
    List<String> criticalPollens = [];

    for (var dayData in forecastPollen) {
      if (dayData.birchPollen > 50 && !criticalPollens.contains("Betulla")) {
        criticalPollens.add("Betulla");
        riskDetected = true;
      }
      if (dayData.grassPollen > 80 && !criticalPollens.contains("Graminacee")) {
        criticalPollens.add("Graminacee");
        riskDetected = true;
      }
      if (dayData.olivePollen > 80 && !criticalPollens.contains("Olivo")) {
        criticalPollens.add("Olivo");
        riskDetected = true;
      }
    }

    hasHighRisk = riskDetected;

    if (hasHighRisk) {
      alertMessage =
          "ATTENZIONE!: Nei prossimi giorni è previsto un forte aumento di: ${criticalPollens.join(', ')}. Evita le attività esterne prolungate.";
    } else {
      alertMessage =
          "Livelli dei pollini stabili o bassi per i prossimi giorni. Situazione sotto controllo!";
    }
  }
}
