import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/habit.dart';

class ProgressChart extends StatefulWidget {
  final List<Habit> habits; // Nhận dữ liệu thật từ màn hình Statistics

  const ProgressChart({super.key, required this.habits});

  @override
  State<ProgressChart> createState() => _ProgressChartState();
}

class _ProgressChartState extends State<ProgressChart> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isLoaded = true;
        });
      }
    });
  }

  // Hàm so sánh ngày (bỏ qua giờ phút giây)
  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    List<int> completedCounts = List.filled(7, 0);
    
    // Thu thập số lượng check-in của 7 ngày qua
    for (int i = 0; i < 7; i++) {
      final targetDate = today.subtract(Duration(days: 6 - i));
      final count = widget.habits.where((habit) {
        return habit.completionDates.any((date) => _isSameDate(date, targetDate));
      }).length;
      completedCounts[i] = count;
    }

    // Tự động scale độ cao trục Y dựa trên ngày có số Habit hoàn thành nhiều nhất
    double maxY = 5.0;
    for (var count in completedCounts) {
      if (count > maxY) maxY = count.toDouble();
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY + 1, // Dư ra 1 ô phía trên cho đẹp
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
                  
                  // Trục X tự động sinh ra Thứ (Mon, Tue...) của 7 ngày gần nhất
                  final targetDate = today.subtract(Duration(days: 6 - value.toInt()));
                  String text;
                  switch (targetDate.weekday) {
                    case 1: text = 'Mon'; break;
                    case 2: text = 'Tue'; break;
                    case 3: text = 'Wed'; break;
                    case 4: text = 'Thu'; break;
                    case 5: text = 'Fri'; break;
                    case 6: text = 'Sat'; break;
                    case 7: text = 'Sun'; break;
                    default: text = '';
                  }
                  
                  return SideTitleWidget(meta: meta, space: 4.0, child: Text(text, style: style));
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
              color: Colors.grey.withValues(alpha: 0.2),
              strokeWidth: 1.0,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (index) {
            return _buildBarGroup(index, _isLoaded ? completedCounts[index].toDouble() : 0.0);
          }),
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