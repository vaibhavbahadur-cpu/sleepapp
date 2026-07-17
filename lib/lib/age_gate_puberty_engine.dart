import 'dart:math';

enum DevelopmentTrack { stableChildhood, activePubertySpurt, circadianPhaseDelay, elevatedRestlessness }

class PubertyMetricsReport {
  final DevelopmentTrack primaryTrend;
  final int calculatedRestlessnessScore; // Growth strain/aches rating (1-100)
  final int circadianShiftMinutes;       // Natural body-clock delay tracking
  final bool hasMetabolicGrowthSurge;    // True if deep-sleep pulse runs hot
  final String developmentInsight;

  PubertyMetricsReport({
    required this.primaryTrend,
    required this.calculatedRestlessnessScore,
    required this.circadianShiftMinutes,
    required this.hasMetabolicGrowthSurge,
    required this.developmentInsight,
  });
}

class AgeGatePubertyEngine {
  final int selectedAgeProfile; // Saved from your watch screen onboarding input

  AgeGatePubertyEngine({required this.selectedAgeProfile});

  /// 1. THE ONBOARDING CONFIGURATION GATE
  /// Determines if developmental indicators should unlock based on birthdate entry
  bool isTeenProfileActive() {
    // Unlocks specialized adolescent tracking strictly between ages 11 and 17
    if (selectedAgeProfile >= 11 && selectedAgeProfile <= 17) {
      print("👦 Active Adolescent Onboarding Confirmed (Age: $selectedAgeProfile). Initializing Puberty Engine.");
      return true;
    }
    print("🔒 Standard Profile Configured (Age: $selectedAgeProfile). Developmental tracking locked.");
    return false;
  }

  /// 2. ADOLESCENT PUBERTY METRICS EQUATION
  /// Processes allowed pulse-motion channels over 30 days to calculate developmental milestones
  PubertyMetricsReport evaluatePubertyMilestones({
    required int deepSleepCurrentWeekAvgBpm,
    required int deepSleepHistoricalBaseBpm,
    required int accumulatedNocturnalMovementSpikes, // Filtered via your 10-minute window
    required DateTime rollingMonthSleepOnsetClock,
    required DateTime baselineYearAgoSleepOnsetClock,
  }) {
    // Verify clearance first. If it's a standard child or adult, pass neutral markers.
    if (!isTeenProfileActive()) {
      return PubertyMetricsReport(
        primaryTrend: DevelopmentTrack.stableChildhood,
        calculatedRestlessnessScore: 0,
        circadianShiftMinutes: 0,
        hasMetabolicGrowthSurge: false,
        developmentInsight: "Metrics locked. Feature optimized strictly for adolescent profiles.",
      );
    }

    // -----------------------------------------------------------------
    // PILLAR 1: METABOLIC SURGE MATRIX (Human Growth Hormone Phase)
    // -----------------------------------------------------------------
    // During an intense bone/muscle growth spurt, resting metabolism burns hot overnight.
    // We isolate blocks of zero motion to track sustained resting pulse increases.
    bool growthSurgeActive = deepSleepCurrentWeekAvgBpm >= (deepSleepHistoricalBaseBpm + 5);

    // -----------------------------------------------------------------
    // PILLAR 2: CIRCADIAN PHASE DELAY MATRIX (Melatonin Shift)
    // -----------------------------------------------------------------
    // Puberty hormones naturally delay melatonin secretion by 30 to 60+ minutes.
    // We compute the minute shift between historical bedtime averages and current logs.
    int clockDelayMinutes = rollingMonthSleepOnsetClock.difference(baselineYearAgoSleepOnsetClock).inMinutes;
    bool hasCircadianShift = clockDelayMinutes >= 40;

    // -----------------------------------------------------------------
    // PILLAR 3: BIOLOGICAL RESTLESSNESS INDEX (Growing Pains)
    // -----------------------------------------------------------------
    // Rapid bone elongation triggers micro-aches, causing brief 5-second shifting windows.
    double motionBase = (accumulatedNocturnalMovementSpikes * 1.8).clamp(1.0, 100.0);
    int finalRestlessness = motionBase.round();
    bool hasHighRestlessness = finalRestlessness > 65;

    // -----------------------------------------------------------------
    // STEP 3: MASTER ROUTING & CLASSIFICATION SUMMARY
    // -----------------------------------------------------------------
    DevelopmentTrack primaryTrend = DevelopmentTrack.stableChildhood;
    String statusMessage = "Developmental markers completely healthy and on track.";

    if (growthSurgeActive) {
      primaryTrend = DevelopmentTrack.activePubertySpurt;
      statusMessage = "🌱 Active Metabolic Growth Phase Detected. Deep rest pulse is elevated—ensure optimal protein intake.";
    } else if (hasCircadianShift) {
      primaryTrend = DevelopmentTrack.circadianPhaseDelay;
      statusMessage = "⏰ Melatonin Phase Delay Confirmed. Shifted clock is a normal part of growing up. Try dimmer pre-bed lighting.";
    } else if (hasHighRestlessness) {
      primaryTrend = DevelopmentTrack.elevatedRestlessness;
      statusMessage = "⚠️ Elevated Restlessness Factor. Physical growing strains active. Suggest a deep leg stretch before bedtime.";
    }

    return PubertyMetricsReport(
      primaryTrend: primaryTrend,
      calculatedRestlessnessScore: finalRestlessness,
      circadianShiftMinutes: clockDelayMinutes,
      hasMetabolicGrowthSurge: growthSurgeActive,
      developmentInsight: statusMessage,
    );
  }
}
