import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:js' as js; 
import 'sensor_capability_probe.dart';

// Struct to store the final output log for each 20-minute cycle
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
  final int enteredBedtimeAcSetting;

  // This list holds everything needed for the morning graph
  final List<Map<String, dynamic>> _allNightLogs = [];

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
    int finalSpo2 = (capabilityMap.spo2Route == ProcessingRoute.directPhysicalSensor) 
        ? await _pullPhysicalInfraredSensorData() 
        : ((currentLiveBpm - daytimeRestingPulseBase) > 12 && !isStill) ? 96 : 99;

    // Feature B: Skin Temp
    double startingBase = (enteredBedtimeAcSetting < 70) ? 89.6 : 91.4;
    double deepRestBonus = (enteredBedtimeAcSetting < 70) ? 2.4 : 1.2;
    double finalSkinTemp = isStill ? (startingBase + deepRestBonus) : (startingBase + 0.3);

    // Feature C: Vascular Load
    int finalVascularLoad = (capabilityMap.vascularLoadRoute == ProcessingRoute.directPhysicalSensor)
        ? await _pullPhysicalPpgWaveData()
        : (isStill ? 75 : 30);

    // Feature D: BP
    int finalBpShiftMmhg = (capabilityMap.bloodPressureRoute == ProcessingRoute.directPhysicalSensor)
        ? await _pullPhysicalCuffCalibrationData()
        : ((currentLiveBpm - daytimeRestingPulseBase) * 0.5 + (motionVector * 3.0)).round();

    // Feature E: Bio Age
    double finalBioAge = userCalendarAge + ((currentLiveBpm < 65 ? 20.0 : 0.0) / 25.0);

    // Build the log
    BackgroundDataLog log = BackgroundDataLog(
      logTimestamp: now,
      loggedHeartRate: currentLiveBpm,
      loggedSpo2: finalSpo2,
      loggedSkinTemp: double.parse(finalSkinTemp.toStringAsFixed(1)),
      loggedVascularLoad: finalVascularLoad,
      loggedBpShiftMmhg: finalBpShiftMmhg,
      loggedBioAge: double.parse(finalBioAge.toStringAsFixed(1)),
      metricSourceSummary: "Source: Auto-Routed",
    );

    // Save to the internal list for the morning graph
    _allNightLogs.add({
      "time": now.toIso8601String(),
      "skinTemp": log.loggedSkinTemp,
      "heartRate": log.loggedHeartRate
    });

    return log;
  }

  // CALL THIS WHEN THE USER WAKES UP
  void sendDataToDashboard() {
    String jsonString = jsonEncode(_allNightLogs);
    js.context.callMethod('updateGraphs', [jsonString]);
  }

  // --- HARDWARE ACCESSORS ---
  Future<int> _readAllowedHeartRateHardwareChannel() async => 64;
  Future<List<double>> _readRawMotionHardwareChannels() async => [0.1, 0.0, 0.1];
  Future<int> _pullPhysicalInfraredSensorData() async => 98;
  Future<double> _pullPhysicalThermalCoreData() async => 92.4;
  Future<int> _pullPhysicalPpgWaveData() async => 35;
  Future<int> _pullPhysicalCuffCalibrationData() async => -6;
}
