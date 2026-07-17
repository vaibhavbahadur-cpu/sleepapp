import 'dart:async';
import 'dart:math';
import 'sensor_capability_probe.dart';

enum CalculatedSleepStage { awake, light, deep, rem }

class SleepStageSnapshot {
  final CalculatedSleepStage stage;
  final String stageLabel;
  final bool isRestfulContinuityValid;
  final double kineticEnergyMagnitude;
  final DateTime timestamp;

  SleepStageSnapshot({
    required this.stage,
    required this.stageLabel,
    required this.isRestfulContinuityValid,
    required this.kineticEnergyMagnitude,
    required this.timestamp,
  });
}

class SleepStagingEngine {
  final int daytimeRestingBpmBase;
  final SensorCapabilityMap capabilityMap;
  
  // Storage for the overnight graph
  final List<SleepStageSnapshot> sleepHistory = [];

  SleepStagingEngine({
    required this.daytimeRestingBpmBase,
    required this.capabilityMap,
  });

  /// Calculates the stage and automatically saves it to history
  Future<SleepStageSnapshot> calculateAndSaveStage({
    required int currentLiveBpm,
    required double hrvRmssd,
    required double accelX, 
    required double accelY, 
    required double accelZ,
    required int totalWristMovementsIn10Mins,
    required int liveSpo2, 
  }) async {
    
    double motionVector = sqrt((accelX * accelX) + (accelY * accelY) + (accelZ * accelZ));

    // Confidence check: only use SpO2 if hardware is authorized
    bool isOxygenSlightlyDepressed = (capabilityMap.spo2Route == ProcessingRoute.directPhysicalSensor) 
        ? (liveSpo2 <= 95) 
        : false;

    bool isConsideredRestfulAndStill = totalWristMovementsIn10Mins <= 1 && motionVector < 0.25;
    bool isHeavyThrashing = totalWristMovementsIn10Mins > 6 || motionVector > 3.5;

    int pulseElevation = currentLiveBpm - daytimeRestingBpmBase;

    CalculatedSleepStage calculatedStage = CalculatedSleepStage.light;
    String label = "Light Sleep 🌛";

    // Staging Logic
    if (isHeavyThrashing || pulseElevation > 15) {
      calculatedStage = CalculatedSleepStage.awake;
      label = "Awake 🌅";
    } else if (isConsideredRestfulAndStill && pulseElevation <= 2 && hrvRmssd < 22.0) {
      calculatedStage = CalculatedSleepStage.deep;
      label = "Deep Sleep 💤";
    } else if (isConsideredRestfulAndStill && (pulseElevation > 3 && hrvRmssd > 35.0 || isOxygenSlightlyDepressed)) {
      calculatedStage = CalculatedSleepStage.rem;
      label = "REM Sleep (Dreaming) 🧠";
    }

    final snapshot = SleepStageSnapshot(
      stage: calculatedStage,
      stageLabel: label,
      isRestfulContinuityValid: isConsideredRestfulAndStill,
      kineticEnergyMagnitude: double.parse(motionVector.toStringAsFixed(2)),
      timestamp: DateTime.now(),
    );

    // Auto-save to the history list
    sleepHistory.add(snapshot);
    return snapshot;
  }

  /// Returns indices (0:Awake, 1:Light, 2:REM, 3:Deep) for graphing
  List<int> getGraphData() {
    return sleepHistory.map((s) {
      switch (s.stage) {
        case CalculatedSleepStage.awake: return 0;
        case CalculatedSleepStage.light: return 1;
        case CalculatedSleepStage.rem: return 2;
        case CalculatedSleepStage.deep: return 3;
      }
    }).toList();
  }
}
