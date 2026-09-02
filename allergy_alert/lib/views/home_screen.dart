import 'package:allergy_alert/viewmodels/allergy_viewmodel.dart';
import 'package:allergy_alert/views/log_symptom_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final AllergyViewModel viewModel;

  const HomeScreen({super.key, required this.viewModel});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  Color _getPollenColor(double value) {
    if (value < 30) return Colors.green;
    if (value < 80) return Colors.orange;
    return Colors.red;
  }

  Color _getSeverityColor(int severity) {
    if (severity <= 2) return Colors.green;
    if (severity <= 4) return Colors.orange;
    return Colors.red;
  }

  String _formatItalianDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  Widget _buildPollenRow(String label, double value) {
    final statusColor = _getPollenColor(value);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                Text(
                  '${value.toStringAsFixed(1)} gr/m³',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        final vm = widget.viewModel;
        final hasAnyData =
            vm.todayPollen != null || vm.forecastPollen.isNotEmpty;
        final showOfflinePlaceholder =
            !vm.isOnline && vm.errorMessage != null && !hasAnyData;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Allergy Alert'),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              if (!vm.isOnline)
                Container(
                  width: double.infinity,
                  color: Colors.red.shade900,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.cloud_off,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Connessione offline',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'I dati si aggiorneranno automaticamente quando la connessione sarà ripristinata',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : showOfflinePlaceholder
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  vm.errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () => vm.loadAppData(),
                                  child: const Text('Riprova'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => vm.loadAppData(),
                            color: Colors.teal,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Card(
                                    color: vm.hasHighRisk
                                        ? Colors.red.shade50
                                        : Colors.teal.shade50,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: vm.hasHighRisk
                                            ? Colors.red
                                            : Colors.teal,
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            vm.hasHighRisk
                                                ? Icons.warning_amber_rounded
                                                : Icons.info_outline,
                                            color: vm.hasHighRisk
                                                ? Colors.red
                                                : Colors.teal,
                                            size: 32,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              vm.alertMessage,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: vm.hasHighRisk
                                                    ? Colors.red.shade900
                                                    : Colors.teal.shade900,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Livelli Pollini Odierni (Roma)',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (vm.todayPollen != null) ...[
                                    _buildPollenRow(
                                      'Graminacee',
                                      vm.todayPollen!.grassPollen,
                                    ),
                                    _buildPollenRow(
                                      'Betulla',
                                      vm.todayPollen!.birchPollen,
                                    ),
                                    _buildPollenRow(
                                      'Olivo',
                                      vm.todayPollen!.olivePollen,
                                    ),
                                  ],
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Previsioni prossimi 2 giorni',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  vm.forecastPollen.isEmpty
                                      ? const Padding(
                                          padding: EdgeInsets.only(bottom: 8),
                                          child: Text(
                                            'Nessuna previsione disponibile al momento.',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        )
                                      : SizedBox(
                                          height: 195,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                vm.forecastPollen.length,
                                            itemBuilder: (context, index) {
                                              final item =
                                                  vm.forecastPollen[index];
                                              final average =
                                                  (item.birchPollen +
                                                          item.grassPollen +
                                                          item.olivePollen) /
                                                      3;
                                              return Container(
                                                width: 150,
                                                margin: const EdgeInsets.only(
                                                  right: 12,
                                                ),
                                                child: Card(
                                                  color: Colors.white,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                      12.0,
                                                    ),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          _formatItalianDate(
                                                            item.time,
                                                          ),
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        Text(
                                                          'Betulla: ${item.birchPollen.toStringAsFixed(1)}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 13,
                                                          ),
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                        Text(
                                                          'Olivo: ${item.olivePollen.toStringAsFixed(1)}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 13,
                                                          ),
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                        Text(
                                                          'Graminacee: ${item.grassPollen.toStringAsFixed(1)}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 13,
                                                          ),
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                _getPollenColor(
                                                              average,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              20,
                                                            ),
                                                          ),
                                                          child: Text(
                                                            average < 30
                                                                ? 'Basso'
                                                                : average < 80
                                                                    ? 'Medio'
                                                                    : 'Alto',
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Il tuo Diario dei Sintomi',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  vm.symptomHistory.isEmpty
                                      ? const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Text(
                                              'Nessun sintomo registrato.\nTocca il pulsante "+" per inserire il primo log!',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: vm.symptomHistory.length,
                                          itemBuilder: (context, index) {
                                            final log =
                                                vm.symptomHistory[index];
                                            return Card(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                vertical: 6,
                                              ),
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                  backgroundColor:
                                                      _getSeverityColor(
                                                    log.severity,
                                                  ),
                                                  child: Text(
                                                    '${log.severity}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                title: Text(
                                                  _formatItalianDate(log.date),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  log.note.isEmpty
                                                      ? 'Nessuna nota aggiuntiva'
                                                      : log.note,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ],
                              ),
                            ),
                          ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) =>
                      LogSymptomScreen(viewModel: widget.viewModel),
                ),
              );
            },
            backgroundColor: Colors.teal,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}