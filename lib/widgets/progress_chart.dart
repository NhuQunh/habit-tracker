import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProgressChart extends StatefulWidget {
  const ProgressChart({super.key});

  @override
  State<ProgressChart> createState() => _ProgressChartState();
}

class _ProgressChartState extends State<ProgressChart> {
  // Biến trạng thái để kích hoạt animation
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    // Tạo độ trễ 100ms trước khi bơm dữ liệu thật vào để fl_chart tự chạy animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isLoaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 5.0, 
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const style = TextStyle(
                    color: Colors.grey, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 12,
                  );
                  Widget text;
                  switch (value.toInt()) {
                    case 0: text = const Text('Mon', style: style); break;
                    case 1: text = const Text('Tue', style: style); break;
                    case 2: text = const Text('Wed', style: style); break;
                    case 3: text = const Text('Thu', style: style); break;
                    case 4: text = const Text('Fri', style: style); break;
                    case 5: text = const Text('Sat', style: style); break;
                    case 6: text = const Text('Sun', style: style); break;
                    default: text = const Text('', style: style); break;
                  }
                  return SideTitleWidget(meta: meta, space: 4.0, child: text);
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1.0, 
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withValues(alpha: 0.2), // Đã cập nhật chuẩn mới
              strokeWidth: 1.0, 
            ),
          ),
          borderData: FlBorderData(show: false), 
          barGroups: [
            _buildBarGroup(0, _isLoaded ? 3.0 : 0.0), 
            _buildBarGroup(1, _isLoaded ? 4.0 : 0.0), 
            _buildBarGroup(2, _isLoaded ? 2.0 : 0.0), 
            _buildBarGroup(3, _isLoaded ? 5.0 : 0.0), 
            _buildBarGroup(4, _isLoaded ? 3.0 : 0.0), 
            _buildBarGroup(5, _isLoaded ? 4.0 : 0.0), 
            _buildBarGroup(6, _isLoaded ? 4.0 : 0.0), 
          ],
        ),
        swapAnimationDuration: const Duration(milliseconds: 800),
        swapAnimationCurve: Curves.easeOutQuint,
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.blueAccent,
          width: 16.0, 
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }
}