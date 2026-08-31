import 'package:allergy_alert/viewmodels/allergy_viewmodel.dart';
import 'package:flutter/material.dart';

class LogSymptomScreen extends StatefulWidget {
  final AllergyViewModel viewModel;

  const LogSymptomScreen({super.key, required this.viewModel});

  @override
  State<LogSymptomScreen> createState() => _LogSymptomScreenState();
}

class _LogSymptomScreenState extends State<LogSymptomScreen> {
  double _severity = 3.0; // Valore predefinito (moderato)
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registra Sintomi'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Come ti senti oggi?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Indica la gravità dei sintomi che stai avvertendo in questo momento.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lieve (1)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'Livello: ${_severity.toInt()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: _severity <= 2
                        ? Colors.green
                        : _severity <= 4
                        ? Colors.orange
                        : Colors.red,
                  ),
                ),
                const Text(
                  'Severo (5)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            Slider(
              value: _severity,
              min: 1.0,
              max: 5.0,
              divisions: 4,
              activeColor: Colors.teal,
              onChanged: (value) {
                setState(() {
                  _severity = value;
                });
              },
            ),
            const SizedBox(height: 24),

            const Text(
              'Inserisci una nota (Opzionale)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText:
                    'Esempio: Forte lacrimazione agli occhi, starnuti frequenti dopo passeggiata...',
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await widget.viewModel.addSymptomLog(
                    _severity.toInt(),
                    _noteController.text.trim(),
                  );

                  if (!mounted) return;

                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Salva nel Diario',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
