import 'dart:convert';

import 'package:allergy_alert/models/symptom_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _storageKey = 'symptom_logs';

  Future<void> saveSymptom(SymptomLog log) async {
    final prefs = await SharedPreferences.getInstance();

    List<SymptomLog> currentLogs = await getSymptoms();

    currentLogs.insert(0, log);

    List<String> stringList = currentLogs
        .map((item) => json.encode(item.toMap()))
        .toList();

    await prefs.setStringList(_storageKey, stringList);
  }

  Future<List<SymptomLog>> getSymptoms() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stringList = prefs.getStringList(_storageKey);

    if (stringList == null) {
      return [];
    }

    return stringList.map((item) {
      final Map<String, dynamic> map = json.decode(item);
      return SymptomLog.fromMap(map);
    }).toList();
  }
}
