import 'package:allergy_alert/models/pollen_data.dart';
import 'package:allergy_alert/models/symptom_log.dart';
import 'package:allergy_alert/services/api_service.dart';
import 'package:allergy_alert/services/storage_service.dart';
import 'package:flutter/material.dart';

class AllergyViewModel extends ChangeNotifier {
  final ApiService _apiservice = ApiService();
  final StorageService _storageService = StorageService();

  PollenData? todayPollen;
  List<PollenData> forecastPollen = [];
  List<SymptomLog> symptomHistory = [];

  bool isLoading = false;
  String? errorMessage;
  String alertMessage = "Nessun alert imminente rilevato.";

  // Coordinate di default per Roma (lat: 41.8919, lon: 12.5113)
  final double _defaultLat = 41.8919;
  final double _defaultLon = 12.5113;

  Future<void> loadAppData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      todayPollen = await _apiservice.getTodayPollen(_defaultLat, _defaultLon);

      forecastPollen = await _apiservice.getPollenForecast(_defaultLat, _defaultLon);

      symptomHistory = await _storageService.getSymptoms();

      _generateAlert();
    } catch (e) {
      errorMessage = "Impossibile aggiornare i dati: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSymptomLog(int severity, String note) async {
    final now = DateTime.now();
    final dateString = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";

    final newLog = SymptomLog(date: dateString, severity: severity, note: note);

    await _storageService.saveSymptom(newLog);

    symptomHistory = await _storageService.getSymptoms();
    notifyListeners();
  }

  void _generateAlert() {
    if (forecastPollen.isEmpty) return;
    
    bool highRisk = false;
    List<String> criticalPollens = [];

    for (var dayData in forecastPollen) {
      if (dayData.birchPollen > 50 && !criticalPollens.contains("Betulla")) {
        criticalPollens.add("Betulla");
        highRisk = true;
      }
      if (dayData.grassPollen > 80 && !criticalPollens.contains("Graminacee")) {
        criticalPollens.add("Graminacee");
        highRisk = true;
      }
      if (dayData.olivePollen > 80 && !criticalPollens.contains("Olivo")) {
        criticalPollens.add("Olivo");
        highRisk = true;
      }
    }

    if (highRisk) {
      alertMessage = "ATTENZIONE!: Nei prossimi giorni è previsto un forte aumento di: ${criticalPollens.join(', ')}. Evita le attività esterne prolungate.";
    } else {
      alertMessage = "Livelli dei pollini stabili o bassi per i prossimi giorni. Situazione sotto controllo!";
    }
  }
}