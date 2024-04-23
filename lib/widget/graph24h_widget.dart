import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CustomLineChart extends StatelessWidget {
  final List<double> hourlyStats;

  const CustomLineChart({super.key, required this.hourlyStats});

  @override
  Widget build(BuildContext context) {
    const cutOffYValue = 0.0;
    final currentHour = DateTime.now().hour;

    return SizedBox(
      height: 300, // Hauteur du graphique
      child: LineChart(
        LineChartData(
          minY: hourlyStats.reduce((value, element) => value < element ? value : element) - 2, // Valeur minimale sur l'axe Y
          maxY: hourlyStats.reduce((value, element) => value > element ? value : element) + 2, // Valeur maximale sur l'axe Y
          titlesData: FlTitlesData(
            leftTitles: SideTitles(
              showTitles: true, // Afficher les titres sur l'axe Y
              reservedSize: 30, // Espace réservé pour les titres sur l'axe Y
              margin: 12, // Marge entre les titres et l'axe Y
              getTextStyles: (value) => const TextStyle(color: Colors.white),
              getTitles: (value) {
                // Retourner les valeurs de l'axe Y
                return value.toInt().toString();
              },
            ),
            bottomTitles: SideTitles(
              showTitles: true, // Afficher les titres sur l'axe X
              reservedSize: 30, // Espace réservé pour les titres sur l'axe X
              margin: 8, // Marge entre les titres et l'axe X
              getTitles: (value) {
                return value % 2 == 0 ? '${value.toInt()}h' : "---";
              },
              rotateAngle: 60, // Rotation des titres de l'axe X
              getTextStyles: (value) => TextStyle(color: currentHour != value ? Colors.white : Colors.lightBlue),
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
