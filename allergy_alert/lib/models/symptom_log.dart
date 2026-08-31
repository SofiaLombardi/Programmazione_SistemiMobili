class SymptomLog {
  final String date;
  final int severity; // da 1 (lieve) a 5 (grave)
  final String note;

  SymptomLog({required this.date, required this.severity, required this.note});

  Map<String, dynamic> toMap() {
    return {'date': date, 'severity': severity, 'note': note};
  }

  factory SymptomLog.fromMap(Map<String, dynamic> map) {
    return SymptomLog(
      date: map['date'] as String,
      severity: map['severity'] as int,
      note: map['note'] as String,
    );
  }
}