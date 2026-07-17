import 'dart:math';

enum CalculatedSleepStage { awake, light, deep, rem }

class SleepStageSnapshot {
  final CalculatedSleepStage stage;
  final String stageLabel;
  final bool isRestfulContinuityValid; // Verified via the 10-minute window
  final double kineticEnergyMagnitude;

  SleepStageSnapshot({
    required this.stage,
    required this.stageLabel,
    required this.isRestfulContinuityValid,
    required this.kineticEnergyMagnitude,
  });
}

class SleepStagingEngine {
  final int daytimeRestingBpmBase;

  SleepStagingEngine({required this.daytimeRestingBpmBase});

  /// MASTER SLEEP STAGING FUNCTION (10-Minute Window & Sensor-Fusion Modeling)
  /// Evaluates heart rhythms paired with raw 3-Axis movement forces.
  SleepStageSnapshot calculateCurrentSleepStage({
    required int currentLiveBpm,
    required double hrvRmssd,
    required double accelX, 
    required double accelY, 
    required double accelZ,
    required int totalWristMovementsIn10Mins, // Tracked via your 10-minute smoothing window
  }) {
    
    // 1. CALCULATE TRUE KINETIC ENERGY MAGNITUDE (Raw Accelerometer Vector)
    double motionVector = sqrt((accelX * accelX) + (accelY * accelY) + (accelZ * accelZ));

    // =================================================================
    // THE 10-MINUTE MOTION SMOOTHING RULE
    // =================================================================
    // If they move their arm 1 time or less over a 10-minute block,
    // the system ignores it as a normal, healthy adjustment and keeps rest valid.
    bool isConsideredRestfulAndStill = totalWristMovementsIn10Mins <= 1 && motionVector < 0.25;
    bool isHeavyThrashing = totalWristMovementsIn10Mins > 6 || motionVector > 3.5;

    // Calculate pulse acceleration above daytime baseline
    int pulseElevation = currentLiveBpm - daytimeRestingBpmBase;

    CalculatedSleepStage calculatedStage = CalculatedSleepStage.light;
    String label = "Light Sleep 🌛";

    // -----------------------------------------------------------------
    // CONDITION 1: AWAKE STATE
    // -----------------------------------------------------------------
    if (isHeavyThrashing || pulseElevation > 15) {
      calculatedStage = CalculatedSleepStage.awake;
      label = "Awake 🌅";
    } 
    // -----------------------------------------------------------------
    // CONDITION 2: DEEP SLEEP (The Restful Core Window)
    // -----------------------------------------------------------------
    // Requires physical stillness, heart rate settling at its lowest,
    // and rigid, flat heartbeat intervals (Compressed overnight HRV).
    else if (isConsideredRestfulAndStill && pulseElevation <= 2 && hrvRmssd < 22.0) {
      calculatedStage = CalculatedSleepStage.deep;
      label = "Deep Sleep 💤";
    } 
    // -----------------------------------------------------------------
    // CONDITION 3: REM SLEEP (Active Dream Cycle)
    // -----------------------------------------------------------------
    // Characterized by complete sleep muscle paralysis (Zero motion) 
    // combined with a highly active brain, jumping heart rate, and loose, erratic HRV.
    else if (isConsideredRestfulAndStill && pulseElevation > 3 && hrvRmssd > 35.0) {
      calculatedStage = CalculatedSleepStage.rem;
      label = "REM Sleep (Dreaming) 🧠";
    }

    return SleepStageSnapshot(
      stage: calculatedStage,
      stageLabel: label,
      isRestfulContinuityValid: isConsideredRestfulAndStill,
      kineticEnergyMagnitude: double.parse(motionVector.toStringAsFixed(2)),
    );
  }
}
