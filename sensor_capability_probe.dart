/// ----------------------------------------------------------------------------
/// 🌌 SMARTER SLEEP ENGINE - FIRST STARTUP SENSOR CAPABILITY PROBE
/// ----------------------------------------------------------------------------

enum ProcessingRoute { directPhysicalSensor, fallbackCalculationEngine }

class SensorCapabilityMap {
  final ProcessingRoute spo2Route;
  final ProcessingRoute bloodPressureRoute;
  final ProcessingRoute vascularLoadRoute;
  final ProcessingRoute skinTempRoute;
  final ProcessingRoute motionCoordinatesRoute;
  final ProcessingRoute acousticNoiseRoute;

  SensorCapabilityMap({
    required this.spo2Route,
    required this.bloodPressureRoute,
    required this.vascularLoadRoute,
    required this.skinTempRoute,
    required this.motionCoordinatesRoute,
    required this.acousticNoiseRoute,
  });
}

class InitialHardwareProber {
  
  /// SYSTEMATICALLY TESTS EVERY SENOR DOOR INDIVIDUALLY 
  /// Maxes out raw hardware where open, and flags calculation engines where blocked.
  Future<SensorCapabilityMap> executeStartupDeviceCheck() async {
    print("🚀 INITIALIZING WATCH HARDWARE CAPABILITY PROBE...");

    // 1. Probe the restricted Infrared LED Array (Blood Oxygen Tracking)
    ProcessingRoute spo2Result = await _probeIndividualHardwareChannel(
      permissionString: "android.permission.health.READ_BLOOD_OXYGEN",
      sensorName: "Infrared SpO2 LED Matrix",
    );

    // 2. Probe the physical Visible Green PPG LED Array (Vascular Wave / Pulse Timing)
    ProcessingRoute vascularResult = await _probeIndividualHardwareChannel(
      permissionString: "android.permission.BODY_SENSORS",
      sensorName: "Visible Green PPG Sensor Grid",
    );

    // 3. Probe the high-frequency 3-Axis Physics Coordinates (Raw Accelerometer & Gyro)
    ProcessingRoute motionResult = await _probeIndividualHardwareChannel(
      permissionString: "android.permission.HIGH_SAMPLING_RATE_SENSORS",
      sensorName: "3-Axis Kinetic Inertial Unit",
    );

    // 4. Probe the physical Infrared Thermal Sensor (Skin Temperature Tracking)
    ProcessingRoute tempResult = await _probeIndividualHardwareChannel(
      permissionString: "android.permission.health.READ_SKIN_TEMPERATURE",
      sensorName: "Infrared Thermal Core Sensor",
    );

    // 5. Probe the background Microphone Soundwave Pipeline
    ProcessingRoute acousticResult = await _probeIndividualHardwareChannel(
      permissionString: "android.permission.RECORD_AUDIO",
      sensorName: "Acoustic Audio Input Stream",
    );

    // Blood Pressure estimation links automatically to your PPG and Motion capabilities
    ProcessingRoute bpResult = (vascularResult == ProcessingRoute.directPhysicalSensor && 
                                motionResult == ProcessingRoute.directPhysicalSensor)
        ? ProcessingRoute.directPhysicalSensor
        : ProcessingRoute.fallbackCalculationEngine;

    print("📊 INITIAL WATCH HARDWARE MAPPING COMPLETE.");
    
    return SensorCapabilityMap(
      spo2Route: spo2Result,
      bloodPressureRoute: bpResult,
      vascularLoadRoute: vascularResult, // Vascular load pulls direct PPG waves if allowed
      skinTempRoute: tempResult,
      motionCoordinatesRoute: motionResult,
      acousticNoiseRoute: acousticResult,
    );
  }

  /// Low-level test loop: Assumes a go first, then safely traps the OS response
  Future<ProcessingRoute> _probeIndividualHardwareChannel({
    required String permissionString,
    required String sensorName,
  }) async {
    try {
      print("Probing path: [$permissionString] for $sensorName...");
      
      // In production, this attempts to request authorization keys from Wear OS.
      // If running under a managed child profile, restricted keys immediately 
      // trigger a hard system security exception.
      bool isSensorAllowedBySamsung = await _mockSystemHardwareLink(permissionString);
      
      if (isSensorAllowedBySamsung) {
        print(" -> ✅ Samsung says YES. Initialized Direct Sensor Channel for $sensorName.");
        return ProcessingRoute.directPhysicalSensor;
      }
    } catch (parentalControlBlock) {
      // Gracefully catch the Child Mode lock. DO NOT CRASH.
      print(" -> ⚠️ Samsung says NO due to Child Profile. Activating Software Calculation Engine fallback.");
    }

    return ProcessingRoute.fallbackCalculationEngine;
  }

  /// Simulates a direct system permission call to test managed child locks
  Future<bool> _mockSystemHardwareLink(String path) async {
    // If testing child account restrictions, force specific medical lines to fail
    if (path.contains("READ_BLOOD_OXYGEN") || path.contains("READ_SKIN_TEMPERATURE")) {
      throw Exception("WearOS Security Exception: Child profile restriction enforced.");
    }
    return true; // Accelerometer, Gyroscope, and Microphone are allowed on child profiles
  }
}
