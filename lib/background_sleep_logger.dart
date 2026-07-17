import 'dart:async';
import 'dart:math';
import 'sensor_capability_probe.dart';

class BackgroundSleepLogger {
  final SensorCapabilityMap capabilityMap;
  final int userCalendarAge;
  final int daytimeRestingPulseBase;
  final int enteredBedtimeAcSetting;

  BackgroundSleepLogger({
    required this.capabilityMap,
    required this.userCalendarAge,
    required this.daytimeRestingPulseBase,
    required this.enteredBedtimeAcSetting,
  });

  Future<BackgroundDataLog> processSingle20MinSnapshot() async {
    DateTime now = DateTime.now();
    
    int currentLiveBpm = await _readAllowedHeartRateHardwareChannel();
    List<double> rawPhysicsForces = await _readRawMotionHardwareChannels();
    
    double motionVector = sqrt((rawPhysicsForces[0] * rawPhysicsForces[0]) + 
                               (rawPhysicsForces[1] * rawPhysicsForces[1]) + 
                               (rawPhysicsForces[2] * rawPhysicsForces[2]));
    bool isStill = motionVector < 0.2;

    // Feature A: SpO2
    int finalSpo2;
    String spo2Source;
    if (capabilityMap.spo2Route == ProcessingRoute.directPhysicalSensor) {
      finalSpo2 = await _pullPhysicalInfraredSensorData();
      spo2Source = "Hardware";
    } else {
      int pulseElevation = currentLiveBpm - daytimeRestingPulseBase;
      finalSpo2 = (pulseElevation > 12 && !isStill) ? 96 : 99;
      spo2Source = "Math Formula";
    }

    // Feature B: Skin Temp
    double finalSkinTemp;
    String tempSource;
    if (capabilityMap.skinTempRoute == ProcessingRoute.directPhysicalSensor) {
      finalSkinTemp = await _pullPhysicalThermalCoreData();
      tempSource = "Hardware";
    } else {
      double startingBase = (enteredBedtimeAcSetting < 70) ? 89.6 : 91.4;
      double deepRestBonus = (enteredBedtimeAcSetting < 70) ? 2.4 : 1.2;
      finalSkinTemp = isStill ? (startingBase + deepRestBonus) : (startingBase + 0.3);
      tempSource = "Math Formula (AC Calibrated)";
    }

    // Feature C: Vascular Load (Fixed variable declaration)
    int finalVascularLoad;
    String vascularSource;
    if (capabilityMap.vascularLoadRoute == ProcessingRoute.directPhysicalSensor) {
      finalVascularLoad = await _pullPhysicalPpgWaveData();
      vascularSource = "Hardware";
    } else {
      int pulseTransitTimeMs = isStill ? 190 : 110;
      finalVascularLoad = (pulseTransitTimeMs < 120) ? 75 : 30;
      vascularSource = "Math Formula";
    }

    // Feature D: BP
    int finalBpShiftMmhg;
    String bpSource;
    if (capabilityMap.bloodPressureRoute == ProcessingRoute.directPhysicalSensor) {
      finalBpShiftMmhg = await _pullPhysicalCuffCalibrationData();
      bpSource = "Hardware";
    } else {
      double pulseFactor = (currentLiveBpm - daytimeRestingPulseBase) * 0.5;
      double kineticFactor = motionVector * 3.0;
      finalBpShiftMmhg = (pulseFactor + kineticFactor).round();
      bpSource = "Math Formula";
    }

    // Feature E: Bio Age
    double maturityPoints = 50.0;
    if (currentLiveBpm < 65) maturityPoints += 20.0;
    double ageOffsetYears = (maturityPoints - 50.0) / 25.0;
    double finalBioAge = userCalendarAge + ageOffsetYears;

    return BackgroundDataLog(
      logTimestamp: now,
      loggedHeartRate: currentLiveBpm,
      loggedSpo2: finalSpo2,
      loggedSkinTemp: double.parse(finalSkinTemp.toStringAsFixed(1)),
      loggedVascularLoad: finalVascularLoad,
      loggedBpShiftMmhg: finalBpShiftMmhg,
      loggedBioAge: double.parse(finalBioAge.toStringAsFixed(1)),
      metricSourceSummary: "Pulse: Hardware | SpO₂: $spo2Source | Temp: $tempSource | Vascular: $vascularSource | BP: $bpSource",
    );
  }

  // ... (Keep your hardware accessors and loop methods here)
}
