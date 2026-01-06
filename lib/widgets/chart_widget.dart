import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartWidget extends StatelessWidget {
  final Map<String, dynamic> widgetData;

  const ChartWidget({super.key, required this.widgetData});

  @override
  Widget build(BuildContext context) {
    final type = widgetData['type']?.toString() ?? 'line'; // line, bar, pie
    final height = (widgetData['height'] as num?)?.toDouble() ?? 300.0;
    final title = widgetData['title']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Container(
        height: height,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty) ...[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 20),
            ],
            Expanded(
              child: _buildChart(type),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(String type) {
    switch (type) {
      case 'bar':
        return _buildBarChart();
      case 'pie':
        return _buildPieChart();
      case 'line':
      default:
        return _buildLineChart();
    }
  }

  Widget _buildLineChart() {
    final data = widgetData['data'] as List<dynamic>? ?? [];
    final showGrid = widgetData['show_grid'] ?? true;

    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      final point = data[i];
      final x = (point['x'] as num?)?.toDouble() ?? i.toDouble();
      final y = (point['y'] as num?)?.toDouble() ?? 0.0;
      spots.add(FlSpot(x, y));
    }

    if (spots.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: showGrid),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            left: BorderSide(color: Color(0xFFE2E8F0)),
            bottom: BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: widgetData['curved'] ?? true,
            color: const Color(0xFF3B82F6),
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: widgetData['fill'] ?? false,
              color: const Color(0xFF3B82F6).withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final data = widgetData['data'] as List<dynamic>? ?? [];

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < data.length; i++) {
      final point = data[i];
      final value = (point['value'] as num?)?.toDouble() ?? 0.0;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: const Color(0xFF3B82F6),
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }

    if (barGroups.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  final label = data[index]['label']?.toString() ?? '';
                  return Text(
                    label,
                    style: const TextStyle(fontSize: 12),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            left: BorderSide(color: Color(0xFFE2E8F0)),
            bottom: BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        gridData: const FlGridData(show: true),
      ),
    );
  }

  Widget _buildPieChart() {
    final data = widgetData['data'] as List<dynamic>? ?? [];

    final sections = <PieChartSectionData>[];
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
    ];

    for (int i = 0; i < data.length; i++) {
      final point = data[i];
      final value = (point['value'] as num?)?.toDouble() ?? 0.0;
      final label = point['label']?.toString() ?? '';

      sections.add(
        PieChartSectionData(
          value: value,
          title: '$label\n${value.toStringAsFixed(0)}',
          color: colors[i % colors.length],
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    if (sections.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 2,
        centerSpaceRadius: widgetData['donut'] == true ? 40 : 0,
      ),
    );
  }
}
