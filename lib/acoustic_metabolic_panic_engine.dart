import 'dart:math';

enum AcousticPanicZone { peacefulRest, environmentalNoiseSpike, bodyDisruptionVerified }
enum MetabolicLoadStatus { fastingOptimal, mildDigestionStrain, heavyIngestionOverload }

class CognitiveMetabolicReport {
  final AcousticPanicZone acoustics;
  final MetabolicLoadStatus metabolism;
  final bool nightmareDetected;
  final int glymphaticCleaningScore; // Glymphatic brain-washing efficiency (1-100)
  final String safetySystemInsight;

  CognitiveMetabolicReport({
    required this.acoustics,
    required this.metabolism,
    required this.nightmareDetected,
    required this.glymphaticCleaningScore,
    required this.safetySystemInsight,
  });
}

class AcousticMetabolicPanicEngine {
  final int userCalendarAge;
  final int daytimeRestingBpmBase;

  // State Variables for the Audio 0-Gate Framework
  double calculatedNoiseFloorDb = 0.0;
  bool isAudioCalibrated = false;

  AcousticMetabolicPanicEngine({
    required this.userCalendarAge,
    required this.daytimeRestingBpmBase,
  });

  /// 1. THE 30-MINUTE SELF-CALIBRATING AUDIO 0-GATE
  /// Samples pre-sleep decibels to establish an absolute ambient zero background line.
  void executeAcousticZeroCalibration(List<double> preSleepAudioSamplesDb) {
    if (preSleepAudioSamplesDb.isEmpty) {
      calculatedNoiseFloorDb = 40.0; // Standard fallback
      return;
    }
    double totalVolume = preSleepAudioSamplesDb.reduce((a, b) => a + b);
    calculatedNoiseFloorDb = totalVolume / preSleepAudioSamplesDb.length;
    isAudioCalibrated = true;
    print("🔒 AUDIO 0-GATE: Absolute ambient zero locked at ${calculatedNoiseFloorDb.toStringAsFixed(1)} dB.");
  }

  /// 2. THE HEART-RATE PLUMMET SLEEP ONSET TRIGGER
  /// Verifies exact sleep entry by matching continuous stillness with a 12% drop in pulse.
  bool evaluateSleepOnsetHandshake({
    required int continuousStillMinutes,
    required int currentLiveBpm,
  }) {
    if (continuousStillMinutes < 25) return false;

    double pulseDropRatio = (daytimeRestingBpmBase - currentLiveBpm) / daytimeRestingBpmBase;
    bool hasHeartRatePlummeted = pulseDropRatio >= 0.12;

    if (hasHeartRatePlummeted) {
      print("🚀 SLEEP ONSET DETECTED: Heart rate plummeted cleanly by ${(pulseDropRatio * 100).round()}% under stillness.");
      return true;
    }
    return false;
  }

  /// 3. CORE ADRENALINE, ACOUSTIC, AND METABOLIC MASTER CALCULATOR
  CognitiveMetabolicReport runSubsystemDiagnostics({
    required int currentLiveBpm,
    required int pulse30SecondsAgoBpm,
    required int hourOneSleepBpm,
    required int hourFourSleepBpm,
    required double overnightHrvRmssd,
    required double liveDecibelSample,
    required double accelX, required double accelY, required double accelZ,
    required int continuousUninterruptedDeepSleepMins,
  }) {
    
    // Calculate instantaneous physical movement vector (Accelerometer forces)
    double motionVector = sqrt((accelX * accelX) + (accelY * accelY) + (accelZ * accelZ));
    
    // -----------------------------------------------------------------
    // FILTERS BLOCK 1: ADRENALINE NIGHTMARE CALCULATION
    // -----------------------------------------------------------------
    // An explosive adrenaline surge (25+ BPM jump) occurring at the exact
    // millisecond as high-intensity physical thrashing verifies a sleep panic state.
    int pulseJumpDelta = currentLiveBpm - pulse30SecondsAgoBpm;
    bool hasAdrenalinePulseSpike = pulseJumpDelta >= 25;
    bool isViolentThrashing = motionVector >= 4.5;
    bool nightmareVerified = hasAdrenalinePulseSpike && isViolentThrashing;

    // -----------------------------------------------------------------
    // FILTERS BLOCK 2: ACOUSTIC 0-GATE & SOUND-BODY REACTION
    // -----------------------------------------------------------------
    AcousticPanicZone acousticResult = AcousticPanicZone.peacefulRest;
    if (isAudioCalibrated) {
      // Ignore negative decibel drops if the room becomes quieter than calibrated floor
      double relativeAudioShift = max(0.0, liveDecibelSample - calculatedNoiseFloorDb);
      
      if (relativeAudioShift >= 15.0) {
        // A room noise occurred. Check if the nervous system physically reacted to it.
        if (pulseJumpDelta >= 8 && motionVector > 1.2) {
          acousticResult = AcousticPanicZone.bodyDisruptionVerified; // Autonomic sleep fracture
        } else {
          acousticResult = AcousticPanicZone.environmentalNoiseSpike; // Brain safely filtered sound
        }
      }
    }

    // -----------------------------------------------------------------
    // FILTERS BLOCK 3: LATE-NIGHT METABOLIC INGESTION DETECTOR
    // -----------------------------------------------------------------
    // Digestion generates structural heat and high sympathetic tone overnight.
    // If pulse stays high and flat across 4 hours under complete stillness, flag late eating.
    MetabolicLoadStatus metabolicResult = MetabolicLoadStatus.fastingOptimal;
    int digestionDelta = hourFourSleepBpm - (daytimeRestingBpmBase - 10);
    bool isPulseCurveFlatAndHigh = hourFourSleepBpm >= (hourOneSleepBpm - 3);

    if (isPulseCurveFlatAndHigh && digestionDelta > 10 && overnightHrvRmssd < 28.0) {
      metabolicResult = MetabolicLoadStatus.heavyIngestionOverload;
    } else if (digestionDelta > 5 && overnightHrvRmssd < 35.0) {
      metabolicResult = MetabolicLoadStatus.mildDigestionStrain;
    }

    // -----------------------------------------------------------------
    // FILTERS BLOCK 4: GLYMPHATIC BRAIN-WASHING EFFICIENCY (Neurological Tuning)
    // -----------------------------------------------------------------
    // Glial cells shrink to clear metabolic waste channels during continuous, deep rest.
    double glymphaticBase = 100.0;
    if (continuousUninterruptedDeepSleepMins < 30) glymphaticBase -= 30.0;
    if (acousticResult == AcousticPanicZone.bodyDisruptionVerified) glymphaticBase -= 15.0;
    if (metabolicResult == MetabolicLoadStatus.heavyIngestionOverload) glymphaticBase -= 10.0;
    int finalGlymphaticScore = glymphaticBase.clamp(1.0, 100.0).round();

    // -----------------------------------------------------------------
    // SYSTEM INSIGHT SUMMARY GENERATOR
    // -----------------------------------------------------------------
    String insight = "Cognitive and digestive recovery networks tracking optimal.";
    if (nightmareVerified) {
      insight = "🚨 NIGHTMARE EVENT DETECTED: Sudden cardiac emergency surge matched kinetic muscle thrashing.";
    } else if (acousticResult == AcousticPanicZone.bodyDisruptionVerified) {
      insight = "🌪️ Autonomic Sleep Fracture: Noise spike physically startled internal cardiorespiratory rhythms.";
    } else if (metabolicResult == MetabolicLoadStatus.heavyIngestionOverload) {
      insight = "🍕 Heavy Bedtime Ingestion Strain: Late digestive metabolic overload delayed neural recovery.";
    } else if (finalGlymphaticScore < 60) {
      insight = "🧠 Neurological Clearing Deficit: Fragmented rest windows disrupted glymphatic brain-washing cycles.";
    }

    return CognitiveMetabolicReport(
      acoustics: acousticResult,
      metabolism: metabolicResult,
      nightmareDetected: nightmareVerified,
      glymphaticCleaningScore: finalGlymphaticScore,
      safetySystemInsight: insight,
    );
  }
}
