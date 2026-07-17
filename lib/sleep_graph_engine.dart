import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:js' as js; 
import 'sleep_staging_engine.dart';

/// Individual data point representing a timed epoch measurement
class SleepEpochData {
  final DateTime timestamp;
  final CalculatedSleepStage stage;

  SleepEpochData({required this.timestamp, required this.stage});
}

class GalaxyWatchTimelineGraph extends StatelessWidget {
  final List<SleepEpochData> overnightTimeline;

  const GalaxyWatchTimelineGraph({super.key, required this.overnightTimeline});

  /// Factory helper: pass your SleepStagingEngine history list here directly
  static List<SleepEpochData> fromSnapshotHistory(List<SleepStageSnapshot> history) {
    return history.map((s) => SleepEpochData(timestamp: s.timestamp, stage: s.stage)).toList();
  }

  /// NEW: THIS SENDS THE SLEEP DATA TO YOUR HTML DASHBOARD
  void sendSleepDataToDashboard() {
    List<Map<String, dynamic>> jsonList = overnightTimeline.map((data) => {
      "time": data.timestamp.toIso8601String(),
      "stage": data.stage.toString().split('.').last, // e.g., "deep", "rem"
    }).toList();
    
    String jsonString = jsonEncode(jsonList);
    js.context.callMethod('updateSleepGraphs', [jsonString]);
  }

  int _calculateTotalSleepMinutes() {
    if (overnightTimeline.length < 2) return 0;
    int totalMinutes = 0;
    for (int i = 0; i < overnightTimeline.length - 1; i++) {
      if (overnightTimeline[i].stage != CalculatedSleepStage.awake) {
        totalMinutes += overnightTimeline[i + 1].timestamp.difference(overnightTimeline[i].timestamp).inMinutes;
      }
    }
    return totalMinutes;
  }

  @override
  Widget build(BuildContext context) {
    int totalSleepMins = _calculateTotalSleepMinutes();
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          width: 220,
          height: 220,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "TOTAL SLEEP: ${totalSleepMins ~/ 60}h ${totalSleepMins % 60}m",
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomPaint(
                    painter: SleepTimelineStepPainter(timeline: overnightTimeline),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// STEP-CURVE TIMELINE PAINTER
// ---------------------------------------------------------------------
class SleepTimelineStepPainter extends CustomPainter {
  final List<SleepEpochData> timeline;

  SleepTimelineStepPainter({required this.timeline});

  @override
  void paint(Canvas canvas, Size size) {
    if (timeline.length < 2) return;

    final paintLine = Paint()
      ..color = Colors.indigoAccent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    double stepX = size.width / (timeline.length - 1);

    double getStageHeightY(CalculatedSleepStage stage) {
      switch (stage) {
        case CalculatedSleepStage.awake: return size.height * 0.15;
        case CalculatedSleepStage.rem: return size.height * 0.40;
        case CalculatedSleepStage.light: return size.height * 0.65;
        case CalculatedSleepStage.deep: return size.height * 0.90;
      }
    }

    path.moveTo(0, getStageHeightY(timeline[0].stage));

    for (int i = 0; i < timeline.length - 1; i++) {
      double nextX = (i + 1) * stepX;
      double currentY = getStageHeightY(timeline[i].stage);
      double nextY = getStageHeightY(timeline[i + 1].stage);

      path.lineTo(nextX, currentY); 
      path.lineTo(nextX, nextY);    
    }

    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
