import 'dart:async';
import 'dart:math';
import 'sensor_capability_probe.dart';

/// Struct to store the final output log for each 20-minute cycle
class BackgroundDataLog {
  final DateTime logTimestamp;
  final int loggedHeartRate;
  final int loggedSpo2;
  final double loggedSkinTemp;
  final int loggedVascularLoad;
  final int loggedBpShiftMmhg;
  final double loggedBioAge;
  final String metricSourceSummary;

  BackgroundDataLog({
    required this.logTimestamp, required this.loggedHeartRate, required this.loggedSpo2,
    required this.loggedSkinTemp, required this.loggedVascularLoad, required this.loggedBpShiftMmhg,
    required this.loggedBioAge, required this.metricSourceSummary,
  });
}

class BackgroundSleepLogger {
  final SensorCapabilityMap capabilityMap;
  final int userCalendarAge;
  final int daytimeRestingPulseBase;
  final int enteredBedtimeAcSetting; // User-entered thermostat degree setting (e.g. 68)

  BackgroundSleepLogger({
    required this.capabilityMap,
    required this.userCalendarAge,
    required this.daytimeRestingPulseBase,
    required this.enteredBedtimeAcSetting,
  });

  /// 1. THE 20-MINUTE RECURRING MASTER SCHEDULER
  void startOvernightBackgroundLoop() {
    print("🛰️ INITIALIZING OVERNIGHT BACKGROUND TIMER (20-MINUTE INTERVAL ACTIVE)");
    
    // Fires execution cycles precisely 20 minutes apart across the night
    Timer.periodic(const Duration(minutes: 20), (Timer t) async {
      BackgroundDataLog cycleResult = await processSingle20MinSnapshot();
      _saveLogToWatchMemory(cycleResult);
    });
  }

  /// 2. CORE SNAPSHOT EVALUATOR
  /// Routes every single feature seamlessly through hardware vs math math equations
  Future<BackgroundDataLog> processSingle20MinSnapshot() async {
    DateTime now = DateTime.now();
    
    // Fetch base allowed child data channels (Always unblocked on watch hardware)
    int currentLiveBpm = await _readAllowedHeartRateHardwareChannel();
    List<double> rawPhysicsForces = await _readRawMotionHardwareChannels();
    
    // Calculate the Kinetic Movement Vector Magnitude from 3-Axis Accel data
    double motionVector = sqrt((rawPhysicsForces[0] * rawPhysicsForces[0]) + 
                               (rawPhysicsForces[1] * rawPhysicsForces[1]) + 
                               (rawPhysicsForces[2] * rawPhysicsForces[2]));
    bool isStill = motionVector < 0.2;

    // -----------------------------------------------------------------
    // FEATURE A: BLOOD OXYGEN (SpO2) PIPELINE
    // -----------------------------------------------------------------
    int finalSpo2;
    String spo2Source;
    if (capabilityMap.spo2Route == ProcessingRoute.directPhysicalSensor) {
      finalSpo2 = await _pullPhysicalInfraredSensorData();
      spo2Source = "Hardware";
    } else {
      // CHILD-MODE MATH EQUATION FALLBACK
      int pulseElevation = currentLiveBpm - daytimeRestingPulseBase;
      finalSpo2 = (pulseElevation > 12 && !isStill) ? 96 : 99; // Points deduction model
      spo2Source = "Math Formula";
    }

    // -----------------------------------------------------------------
    // FEATURE B: SKIN TEMPERATURE PIPELINE (AC USER-INPUT CALIBRATION)
    // -----------------------------------------------------------------
    double finalSkinTemp;
    String tempSource;
    if (capabilityMap.skinTempRoute == ProcessingRoute.directPhysicalSensor) {
      finalSkinTemp = await _pullPhysicalThermalCoreData();
      tempSource = "Hardware";
    } else {
      // CHILD-MODE MATH EQUATION FALLBACK (Thermostat Calibration)
      double startingBase = (enteredBedtimeAcSetting < 70) ? 89.6 : 91.4;
      double deepRestBonus = (enteredBedtimeAcSetting < 70) ? 2.4 : 1.2;
      finalSkinTemp = isStill ? (startingBase + deepRestBonus) : (startingBase + 0.3);
      tempSource = "Math Formula (AC Calibrated)";
    }

    // -----------------------------------------------------------------
    // FEATURE C: VASCULAR LOAD PIPELINE (Pulse Transit Timing Shortcut)
    // -----------------------------------------------------------------
    int finalVascularLoad;
    String vascularSource;
    if (capabilityMap.vascularLoadRoute == ProcessingRoute.directPhysicalSensor) {
      finalVascularLoad = await _pullPhysicalPpgWaveData();
      vascularSource = "Hardware";
    } else {
      // CHILD-MODE MATH EQUATION FALLBACK (Pulse Transit shortcut via Gyro micro-bounce)
      int pulseTransitTimeMs = isStill ? 190 : 110; // Simulating wave latency arrival values
      vascularLoad = (pulseTransitTimeMs < 120) ? 75 : 30; 
      vascularSource = "Math Formula";
    }

    // -----------------------------------------------------------------
    // FEATURE D: BLOOD PRESSURE PIPELINE (mmHg Dynamic Variation Shifts)
    // -----------------------------------------------------------------
    int finalBpShiftMmhg;
    String bpSource;
    if (capabilityMap.bloodPressureRoute == ProcessingRoute.directPhysicalSensor) {
      finalBpShiftMmhg = await _pullPhysicalCuffCalibrationData();
      bpSource = "Hardware";
    } else {
      // CHILD-MODE MATH EQUATION FALLBACK (Pulse-Motion Elasticity)
      double pulseFactor = (currentLiveBpm - daytimeRestingPulseBase) * 0.5;
      double kineticFactor = motionVector * 3.0;
      finalBpShiftMmhg = (pulseFactor + kineticFactor).round();
      bpSource = "Math Formula";
    }

    // -----------------------------------------------------------------
    // FEATURE E: CHRONOLOGICAL-CIRCADIAN BIOLOGICAL AGE PIPELINE
    // -----------------------------------------------------------------
    // Generates slow rolling developmental milestone numbers completely via safe software math
    double maturityPoints = 50.0;
    if (currentLiveBpm < 65) maturityPoints += 20.0; // Early cardiovascular growth shift
    double ageOffsetYears = (maturityPoints - 50.0) / 25.0;
    double finalBioAge = userCalendarAge + ageOffsetYears;

    return BackgroundDataLog(
      logTimestamp: now,
      loggedHeartRate: currentLiveBpm,
      loggedSpo2: finalSpo2,
      loggedSkinTemp: double.parse(finalSkinTemp.toStringAsFixed(1)),
      loggedVascularLoad: vascularLoad,
      loggedBpShiftMmhg: finalBpShiftMmhg,
      loggedBioAge: double.parse(finalBioAge.toStringAsFixed(1)),
      metricSourceSummary: "Pulse: Hardware | SpO₂: $spo2Source | Temp: $tempSource | Vascular: $vascularSource | BP: $bpSource",
    );
  }

  // ---------------------------------------------------------------------
  // HARDWARE DATA HOOK ACCESSORS (MOCKED PERMITTED VS RESTRICTED GATES)
  // ---------------------------------------------------------------------
  Future<int> _readAllowedHeartRateHardwareChannel() async => 64; // Permitted pulse saves
  Future<List<double>> _readRawMotionHardwareChannels() async => [0.1, 0.0, 0.1]; // Permitted Accel X, Y, Z forces

  Future<int> _pullPhysicalInfraredSensorData() async => 98;
  Future<double> _pullPhysicalThermalCoreData() async => 92.4;
  Future<int> _pullPhysicalPpgWaveData() async => 35;
  Future<int> _pullPhysicalCuffCalibrationData() async => -6;

  void _saveLogToWatchMemory(BackgroundDataLog log) {
    print("💾 LOG PRESERVED [${log.logTimestamp.toIso8601String()}]:");
    print(" -> Heart Rate: ${log.loggedHeartRate} BPM | SpO₂: ${log.loggedSpo2}%");
    print(" -> Skin Temp: ${log.loggedSkinTemp}°F | Vascular Load: ${log.loggedVascularLoad}/100");
    print(" -> BP Dynamic Shift: ${log.loggedBpShiftMmhg} mmHg | Estimated Bio Age: ${log.loggedBioAge}");
    print(" -> Engine Profile: ${log.metricSourceSummary}\n");
  }
}
