import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exercise_history_model.dart';
import '../../providers/workout_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/stat_card.dart';

class ExerciseAnalyticsScreen extends StatefulWidget {
  final String? initialExerciseName;

  const ExerciseAnalyticsScreen({super.key, this.initialExerciseName});

  @override
  State<ExerciseAnalyticsScreen> createState() =>
      _ExerciseAnalyticsScreenState();
}

class _ExerciseAnalyticsScreenState extends State<ExerciseAnalyticsScreen> {
  late String _selectedExercise;
  List<ExerciseHistoryPoint> _history = [];
  bool _isLoading = false;
  String _selectedMetric = 'Max Weight'; // 'Max Weight', 'Volume', 'Est. 1RM'

  @override
  void initState() {
    super.initState();
    _selectedExercise =
        widget.initialExerciseName ?? AppConstants.defaultExercises.first.name;
    _loadHistory();
  }

  void _loadHistory() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    final data = await provider.fetchExerciseHistory(_selectedExercise);
    if (mounted) {
      setState(() {
        _history = data;
        _isLoading = false;
      });
    }
  }

  double _getMetricValue(ExerciseHistoryPoint pt) {
    switch (_selectedMetric) {
      case 'Volume':
        return pt.volume;
      case 'Est. 1RM':
        return pt.estimated1RM;
      case 'Max Weight':
      default:
        return pt.maxWeight;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day}/${dt.year.toString().substring(2)}';
  }

  @override
  Widget build(BuildContext context) {
    double bestWeight = 0;
    double best1RM = 0;

    for (var pt in _history) {
      if (pt.maxWeight > bestWeight) bestWeight = pt.maxWeight;
      if (pt.estimated1RM > best1RM) best1RM = pt.estimated1RM;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Exercise Analytics',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Dropdown Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButton<String>(
                value: _selectedExercise,
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: AppColors.surface,
                icon: const Icon(Icons.arrow_drop_down,
                    color: AppColors.primary),
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                items: AppConstants.defaultExercises.map((e) {
                  return DropdownMenuItem<String>(
                    value: e.name,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.name),
                        Text(
                          e.muscleGroup,
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null && val != _selectedExercise) {
                    setState(() {
                      _selectedExercise = val;
                    });
                    _loadHistory();
                  }
                },
              ),
            ),
            const SizedBox(height: 20),

            // Performance Stat Cards
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Max Weight',
                    value: '${bestWeight.toInt()} kg',
                    subtitle: 'Heaviest set',
                    icon: Icons.fitness_center,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Est. 1RM',
                    value: '${best1RM.toInt()} kg',
                    subtitle: 'Theoretical max',
                    icon: Icons.bolt,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Metric Selector & Chart
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PROGRESSION CURVE',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Max Weight', label: Text('Weight')),
                    ButtonSegment(value: 'Volume', label: Text('Volume')),
                    ButtonSegment(value: 'Est. 1RM', label: Text('1RM')),
                  ],
                  selected: {_selectedMetric},
                  onSelectionChanged: (set) {
                    setState(() => _selectedMetric = set.first);
                  },
                  style: SegmentedButton.styleFrom(
                    backgroundColor: AppColors.card,
                    selectedBackgroundColor: AppColors.primary,
                    selectedForegroundColor: const Color(0xFF121212),
                    foregroundColor: AppColors.textSecondary,
                    visualDensity: VisualDensity.compact,
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_selectedMetric Trend',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Unified historical performances across all workouts',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (_isLoading)
                    const SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  else if (_history.isEmpty)
                    Container(
                      height: 200,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.show_chart,
                              size: 44,
                              color: AppColors.textMuted.withValues(alpha: 0.5)),
                          const SizedBox(height: 8),
                          Text(
                            'No logged data for $_selectedExercise',
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Perform this exercise in any workout to track your progression.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      height: 220,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (val) => const FlLine(
                              color: AppColors.border,
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 38,
                                getTitlesWidget: (val, meta) {
                                  return Text(
                                    val.toInt().toString(),
                                    style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 26,
                                interval: 1,
                                getTitlesWidget: (val, meta) {
                                  final idx = val.toInt();
                                  if (idx >= 0 && idx < _history.length) {
                                    final d = _history[idx].date;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        '${d.month}/${d.day}',
                                        style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 10),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(
                                _history.length,
                                (i) => FlSpot(
                                    i.toDouble(), _getMetricValue(_history[i])),
                              ),
                              isCurved: true,
                              curveSmoothness: 0.25,
                              color: AppColors.primary,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, p, bar, idx) =>
                                    FlDotCirclePainter(
                                  radius: 4,
                                  color: AppColors.primary,
                                  strokeWidth: 2,
                                  strokeColor: AppColors.card,
                                ),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.35),
                                    AppColors.primary.withValues(alpha: 0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (_) => AppColors.surface,
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((spot) {
                                  final idx = spot.spotIndex;
                                  final pt = _history[idx];
                                  final val = _getMetricValue(pt);
                                  return LineTooltipItem(
                                    '${_formatDate(pt.date)}\n',
                                    const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '${val.toInt()} kg ($_selectedMetric)',
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Historical Log Entries
            const Text(
              'SESSION LOGS',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),

            ..._history.reversed.map((pt) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pt.routineName,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _formatDate(pt.date),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Max: ${pt.maxWeight.toInt()} kg',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '1RM: ~${pt.estimated1RM.toInt()} kg',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Vol: ${pt.volume.toInt()} kg',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                    if (pt.notes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        '📝 ${pt.notes}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
