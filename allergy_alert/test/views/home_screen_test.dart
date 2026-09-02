import 'package:allergy_alert/models/pollen_data.dart';
import 'package:allergy_alert/models/symptom_log.dart';
import 'package:allergy_alert/viewmodels/allergy_viewmodel.dart';
import 'package:allergy_alert/views/home_screen.dart';
import 'package:allergy_alert/views/log_symptom_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAllergyViewModel extends ChangeNotifier implements AllergyViewModel {
  @override
  bool isLoading = false;

  @override
  bool isOnline = true;

  @override
  String? errorMessage;

  @override
  bool hasHighRisk = false;

  @override
  String alertMessage = 'Livelli nella norma';

  @override
  PollenData? todayPollen;

  @override
  List<PollenData> forecastPollen = [];

  @override
  List<SymptomLog> symptomHistory = [];

  @override
  Future<void> loadAppData() async {}

  @override
  Future<void> addSymptomLog(int severity, String note) async {}
}

void main() {
  group('HomeScreen Widget Tests', () {
    late FakeAllergyViewModel fakeViewModel;

    setUp(() {
      fakeViewModel = FakeAllergyViewModel();
    });

    testWidgets('Mostra il titolo dell AppBar e il FloatingActionButton',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(viewModel: fakeViewModel),
        ),
      );

      expect(find.text('Allergy Alert'), findsOneWidget);
      expect(find.text('Il tuo Diario dei Sintomi'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Toccando il pulsante "+" si naviga alla LogSymptomScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(viewModel: fakeViewModel),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(LogSymptomScreen), findsOneWidget);
    });
  });
}