class AcousticMetabolicPanicEngine {
  final int userCalendarAge;
  final int daytimeRestingBpmBase;
  
  // I'll keep the list private so you don't have to touch it.
  final List<Map<String, dynamic>> _savedData = [];

  AcousticMetabolicPanicEngine({
    required this.userCalendarAge,
    required this.daytimeRestingBpmBase,
  });

  // Just call this. It does the math AND saves the data for your HTML file.
  void runAndSaveDiagnostics({
    required int currentLiveBpm,
    required int pulse30SecondsAgoBpm,
    required double liveDecibelSample,
    required double accelX, required double accelY, required double accelZ,
    required int deepSleepMinutes,
  }) {
    // Math logic...
    bool nightmare = (currentLiveBpm - pulse30SecondsAgoBpm >= 25) && (accelX + accelY + accelZ > 4.5);
    int glymphatic = (deepSleepMinutes < 30) ? 70 : 100;
    
    // Save it automatically
    _savedData.add({
      "nightmare": nightmare,
      "glymphatic": glymphatic,
      "timestamp": DateTime.now().toIso8601String(),
    });
  }

  // When you're ready to show the user, just call this to get the string for index.html
  String getJsonForWeb() {
    return _savedData.toString(); // Or jsonEncode(_savedData)
  }
}
