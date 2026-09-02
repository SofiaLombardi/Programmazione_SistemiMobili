import 'package:flutter_test/flutter_test.dart';
import 'package:allergy_alert/viewmodels/allergy_viewmodel.dart';
import 'package:allergy_alert/services/api_service.dart';
import 'package:allergy_alert/services/storage_service.dart';
import 'package:allergy_alert/models/pollen_data.dart';
import 'package:allergy_alert/models/symptom_log.dart';

class FakeApiService implements ApiService {
  PollenData? todayPollenToReturn;
  List<PollenData> forecastPollenToReturn = [];

  @override
  Future<PollenData> getTodayPollen(double lat, double lon) async {
    return todayPollenToReturn ??
        PollenData(
          time: '2026-03-30T00:00',
          birchPollen: 0,
          grassPollen: 0,
          olivePollen: 0,
        );
  }

  @override
  Future<List<PollenData>> getPollenForecast(double lat, double lon) async {
    return forecastPollenToReturn;
  }
}

class FakeStorageService implements StorageService {
  List<SymptomLog> logs = [];

  @override
  Future<List<SymptomLog>> getSymptoms() async {
    return logs;
  }

  @override
  Future<void> saveSymptom(SymptomLog log) async {
    logs.add(log);
  }
}

void main() {
  late FakeApiService fakeApiService;
  late FakeStorageService fakeStorageService;

  setUp(() {
    fakeApiService = FakeApiService();
    fakeStorageService = FakeStorageService();
  });

  group('AllergyViewModel Tests', () {
    test('addSymptomLog aggiunge correttamente un sintomo', () async {
      final viewModel = AllergyViewModel(
        apiService: fakeApiService,
        storageService: fakeStorageService,
      );

      await viewModel.addSymptomLog(4, 'Starnuti frequenti');

      expect(viewModel.symptomHistory.length, 1);
      expect(viewModel.symptomHistory.first.severity, equals(4));
      expect(viewModel.symptomHistory.first.note, equals('Starnuti frequenti'));
    });

    test('Generazione di un Alert se i pollini di Betulla superano 50', () async {
      fakeApiService.todayPollenToReturn = PollenData(
        time: '2026-03-30T00:00',
        birchPollen: 10,
        grassPollen: 10,
        olivePollen: 10,
      );
      fakeApiService.forecastPollenToReturn = [
        PollenData(
          time: '2026-03-31T00:00',
          birchPollen: 60,
          grassPollen: 10,
          olivePollen: 10,
        )
      ];

      final viewModel = AllergyViewModel(
        apiService: fakeApiService,
        storageService: fakeStorageService,
      );

      await viewModel.loadAppData();

      expect(viewModel.hasHighRisk, isTrue);
      expect(viewModel.alertMessage, contains('ATTENZIONE!'));
      expect(viewModel.alertMessage, contains('Betulla'));
    });
  });
}