import 'dart:convert';

import 'package:allergy_alert/models/symptom_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _storageKey = 'symptom_logs';

  Future<void> saveSymptom(SymptomLog log) async {
    final prefs =  await SharedPreferences.getInstance();

  //1. Recupero storico esistente dei sintomi
  List<SymptomLog> currentLogs = await getSymptoms();  

  //2. Aggiungo il nuovo sintomo in cima alla lista (il più recente è il primo)
  currentLogs.insert(0,log);

  //3.Converto lista di oggeeti in lista di stringhe Json per poterla salvare in locale
  List<String> stringList = currentLogs.map((item) => json.encode(item.toMap())).toList();


//4. Scrivo i dati nella memoria persistente del dispositivo
  await prefs.setStringList(_storageKey, stringList);
}

//Recupero tutti i sintomi salvati in locale
  Future<List<SymptomLog>> getSymptoms() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stringList = prefs.getStringList(_storageKey);

    if (stringList == null) {
      return []; // se non ci sono dati salvati, restituisco una lista vuota
    }

    //Riconverto le stringhe JSON in oggetti SymptomLog
    return stringList.map((item){
     final Map <String, dynamic> map = json.decode(item);
     return SymptomLog.fromMap( map);
    }).toList();
  }
}