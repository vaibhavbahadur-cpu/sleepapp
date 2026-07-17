import 'dart:convert';
import 'dart:math';
import 'dart:js' as js;

class AcousticMetabolicPanicEngine {
  final int userCalendarAge;
  final int daytimeRestingBpmBase;
  
  // This stores the history automatically
  final List<Map<String, dynamic>> _savedData = [];

  AcousticMetabolicPanicEngine({
    required this.userCalendarAge,
    required this.daytimeRestingBpmBase,
  });

  // Does the math AND saves the data automatically.
  void runAndSaveDiagnostics({
    required int currentLiveBpm,
    required int pulse30SecondsAgoBpm,
    required double liveDecibelSample,
    required double accelX, 
    required double accelY, 
    required double accelZ,
    required int deepSleepMinutes,
  }) {
    // Math logic
    bool nightmare = (currentLiveBpm - pulse30SecondsAgoBpm >= 25) && 
                     ((accelX * accelX + accelY * accelY + accelZ * accelZ) > 4.5);
    int glymphatic = (deepSleepMinutes < 30) ? 70 : 100;
    
    // Save it automatically
    _savedData.add({
      "timestamp": DateTime.now().toIso8601String(),
      "nightmare": nightmare,
      "glymphatic": glymphatic,
    });
  }

  /// NEW: THIS SENDS THE PANIC/DIAGNOSTIC DATA TO YOUR HTML DASHBOARD
  void sendPanicDataToDashboard() {
    String jsonString = jsonEncode(_savedData);
    // Fires the data to a JS function named 'updatePanicGraphs' in your index.html
    js.context.callMethod('updatePanicGraphs', [jsonString]);
  }

  // Get the JSON string if you need it elsewhere
  String getJsonForWeb() {
    return jsonEncode(_savedData);
  }
}
