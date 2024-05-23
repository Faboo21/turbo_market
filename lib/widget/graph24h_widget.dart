import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CustomLineChart extends StatelessWidget {
  final List<double> hourlyStats;
  final List<String> xLabels;

  const CustomLineChart({super.key, required this.hourlyStats, required this.xLabels});

  @override
  Widget build(BuildContext context) {
    const cutOffYValue = 0.0;

    double minY = hourlyStats.reduce((value, element) => value < element ? value : element) - 2;
    double maxY = hourlyStats.reduce((value, element) => value > element ? value : element) + 2;

    double range = maxY - minY;
    double step = (range / 10).ceilToDouble();

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          titlesData: FlTitlesData(
            leftTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              margin: 12,
              getTextStyles: (value) => const TextStyle(color: Colors.white),
              getTitles: (value) {
                if (value % step == 0) {
                  return value.toStringAsFixed(1);
                } else {
                  return '';
                }
              },
            ),
            bottomTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              margin: 8,
              getTitles: (value) {
                return value.toInt() != 0 && value.toInt() != 11? xLabels[value.toInt()] : "";
              },
              rotateAngle: 60,
              getTextStyles: (value) => const TextStyle(color: Colors.white),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: hourlyStats
                  .asMap()
                  .entries
                  .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                  .toList(),
              isCurved: false, // Courber la ligne entre les points
              belowBarData: BarAreaData(
                show: true,
                colors: [Colors.lightGreenAccent],
                cutOffY: cutOffYValue,
                applyCutOffY: true,
              ),
              aboveBarData: BarAreaData(
                show: true,
                colors: [Colors.redAccent],
                cutOffY: cutOffYValue,
                applyCutOffY: true,
              ),
              dotData: FlDotData(show: false), // Masquer les points
              colors: [Colors.white], // Couleur de la ligne
              barWidth: 2, // Épaisseur de la ligne
            ),
          ],
          borderData: FlBorderData(
            show: true, // Afficher la bordure du graphique
          ),
          gridData: FlGridData(
            show: true, // Afficher la grille du graphique
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.blue.withOpacity(0.8), // Couleur de fond de la tooltip
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (touchedSpots) {
                // Récupérer les données de tooltip pour chaque spot touché
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    spot.y.toStringAsFixed(2), // Valeur du point arrondie
                    const TextStyle(color: Colors.white), // Couleur du texte
                  );
                }).toList();
              },
            ),
            touchCallback: (LineTouchResponse touchResponse) {
              // Appeler la fonction de rappel du toucher
              // ...
            },
            handleBuiltInTouches: true,
          ),
        ),
      ),
    );
  }
}
