import 'dart:convert';

import 'package:allergy_alert/models/symptom_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _storageKey = 'symptom_logs';

  Future<void> saveSymptom(SymptomLog log) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Recupera la lista dei sintomi salvati (se vuota, usa una lista nuova)
    final currentLogs = await getSymptoms();

    // 2. Aggiunge il nuovo sintomo in cima alla lista
    currentLogs.insert(0, log);

    // 3. Converte la lista di oggetti SymptomLog in lista di stringhe JSON
    final List<String> stringList = currentLogs
        .map((item) => json.encode(item.toMap()))
        .toList();

    // 4. Salva la lista aggiornata
    await prefs.setStringList(_storageKey, stringList);
  }

  Future<List<SymptomLog>> getSymptoms() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stringList = prefs.getStringList(_storageKey);

    if (stringList == null) {
      return [];
    }

    return stringList.map((item) {
      final Map<String, dynamic> map =
          jsonDecode(item) as Map<String, dynamic>;
      return SymptomLog.fromMap(map);
    }).toList();
  }
}