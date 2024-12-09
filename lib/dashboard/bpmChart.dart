import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bluetooth/bluetooth_constant.dart';

// ignore: must_be_immutable
class Bpmchart extends StatefulWidget {
  List<MyBluetoothData> datanya;
  Bpmchart({super.key, required this.datanya});

  @override
  State<Bpmchart> createState() => _BpmchartState();
}

class _BpmchartState extends State<Bpmchart> {
  @override
  Widget build(BuildContext context) {
    // widget.datanya = [MyBluetoothData(date: DateTime(0), bpm: 0, oksigen: 0)];
    return BarChart(
      mainBarChart(),
    );
  }

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
          toY: y,
          gradient: LinearGradient(colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.tertiary,
          ], transform: const GradientRotation(pi / 40)),
          width: 18,
          backDrawRodData: BackgroundBarChartRodData(
              show: true, toY: 6, color: Theme.of(context).colorScheme.surface))
    ]);
  }

  List<BarChartGroupData> showingGroups() {
    if (widget.datanya.isEmpty) {
      return List.generate(7, (i) => makeGroupData(i, 0));
    } else {
      return List.generate(7, (i) {
        double x;
        if (i < widget.datanya.length) {
          x = widget.datanya[i].bpm.toDouble();
        } else {
          x = 0;
        }
        return makeGroupData(i, x);
      });
    }
  }

  BarChartData mainBarChart() {
    if (widget.datanya.isEmpty) {
      return BarChartData(
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true, reservedSize: 38, getTitlesWidget: getTitle),
          ),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 38,
                  getTitlesWidget: leftTitle)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(7, (i) => makeGroupData(i, 0)),
      );
    } else {
      return BarChartData(
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true, reservedSize: 38, getTitlesWidget: getTitle),
          ),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 38,
                  getTitlesWidget: leftTitle)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: showingGroups(),
      );
    }
  }

  Widget getTitle(double value, TitleMeta meta) {
    var style = GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Theme.of(context).colorScheme.outline,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = Text(
          '01',
          style: style,
        );
        break;
      case 1:
        text = Text(
          '02',
          style: style,
        );
        break;
      case 2:
        text = Text(
          '03',
          style: style,
        );
        break;
      case 3:
        text = Text(
          '04',
          style: style,
        );
        break;
      case 4:
        text = Text(
          '05',
          style: style,
        );
        break;
      case 5:
        text = Text(
          '06',
          style: style,
        );
        break;
      case 6:
        text = Text(
          '07',
          style: style,
        );
        break;
      default:
        text = Text(
          '',
          style: style,
        );
    }

    return SideTitleWidget(space: 16, child: text, axisSide: meta.axisSide);
  }

  Widget leftTitle(double value, TitleMeta meta) {
    var style = GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Theme.of(context).colorScheme.outline,
    );
    String text = value.toInt().toString();

    if (value % 10 == 0) {
      return SideTitleWidget(
          space: 0,
          child: Text(
            value.toInt().toString(),
            style: style,
          ),
          axisSide: meta.axisSide);
    } else {
      return Container(); // Tidak menampilkan apa-apa jika tidak sesuai interval
    }
  }
}
