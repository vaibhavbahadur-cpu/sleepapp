import 'package:flutter/material.dart';
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

  // Helper method to calculate the total duration slept (excluding awake windows)
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
    int hours = totalSleepMins ~/ 60;
    int mins = totalSleepMins % 60;

    return Scaffold(
      backgroundColor: Colors.black, // Crucial: Saves AMOLED battery on Galaxy Watch 8
      body: Center(
        child: Container(
          // Lock layout dimensions strictly to prevent clipping on the circular Watch 8 bezel
          width: 220,
          height: 220,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. DURATION READOUT HEADER
              Text(
                "TOTAL SLEEP: ${hours}h ${mins}m",
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.black, letterSpacing: 0.5),
              ),
              const SizedBox(height: 6),

              // 2. TIMELINE CANVAS CONTAINER
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white10, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomPaint(
                    painter: SleepTimelineStepPainter(timeline: overnightTimeline),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // 3. HORIZONTAL TIMELINE FOOTER LABELS
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("11PM", style: TextStyle(color: Colors.white38, fontSize: 8)),
                    Text("2AM", style: TextStyle(color: Colors.white38, fontSize: 8)),
                    Text("6AM", style: TextStyle(color: Colors.white38, fontSize: 8)),
                  ],
                ),
              )
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

    // Configure drawing grid line styling
    final paintLine = Paint()
      ..color = Colors.indigoAccent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final path = Path();
    
    // Establish horizontal timeline layout increments
    double stepX = size.width / (timeline.length - 1);
    
    // Map vertical sleep stage levels (Clamped limits inside container height)
    double getStageHeightY(CalculatedSleepStage stage) {
      switch (stage) {
        case CalculatedSleepStage.awake:
          return size.height * 0.15; // Awake sits high up at top
        case CalculatedSleepStage.rem:
          return size.height * 0.40; // REM sits right below awake
        case CalculatedSleepStage.light:
          return size.height * 0.65; // Light sleep sits in mid-lower lane
        case CalculatedSleepStage.deep:
          return size.height * 0.90; // Deep sleep rests safely at the very bottom
      }
    }

    // Begin path drawing sequence at the initial sleep epoch coordinate block
    double startX = 0;
    double startY = getStageHeightY(timeline[0].stage);
    path.moveTo(startX, startY);

    for (int i = 0; i < timeline.length - 1; i++) {
      double currentX = i * stepX;
      double nextX = (i + 1) * stepX;
      
      double currentY = getStageHeightY(timeline[i].stage);
      double nextY = getStageHeightY(timeline[i + 1].stage);

      // CRUCIAL Sleep Science Drawing Logic: Create square step curves 
      // instead of standard angled diagonal lines to map accurate time boundaries
      path.lineTo(nextX, currentY); // Maintain resting level line horizontally until next timestamp check
      path.lineTo(nextX, nextY);    // Drop or climb vertically instantly at the execution point
    }

    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
