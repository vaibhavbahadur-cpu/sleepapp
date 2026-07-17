import 'dart:convert';
import 'dart:js' as js; 

class AgeGatePubertyEngine {
  final int selectedAgeProfile;
  
  // This stores the history automatically
  final List<Map<String, dynamic>> _savedReports = [];

  AgeGatePubertyEngine({required this.selectedAgeProfile});

  bool isTeenProfileActive() {
    return (selectedAgeProfile >= 11 && selectedAgeProfile <= 17);
  }

  // Calculates the trend and saves it automatically.
  void evaluateAndSaveMilestones({
    required int currentBpm,
    required int baseBpm,
    required int moveSpikes,
    required int clockDelay,
  }) {
    if (!isTeenProfileActive()) return;

    // Logic
    bool growthSurge = currentBpm >= (baseBpm + 5);
    bool circadianShift = clockDelay >= 40;
    int restlessness = (moveSpikes * 1.8).clamp(1, 100).toInt();

    // Determine the trend for the label
    String trend = "Stable";
    if (growthSurge) trend = "Active Puberty Spurt";
    else if (circadianShift) trend = "Circadian Phase Delay";
    else if (restlessness > 65) trend = "Elevated Restlessness";

    // Auto-save the data
    _savedReports.add({
      "timestamp": DateTime.now().toIso8601String(),
      "trend": trend,
      "restlessness": restlessness,
      "circadianDelay": clockDelay,
      "growthSurge": growthSurge,
    });
  }

  /// NEW: THIS SENDS THE PUBERTY DATA TO YOUR HTML DASHBOARD
  void sendPubertyDataToDashboard() {
    String jsonString = jsonEncode(_savedReports);
    // Fires the data to a JS function named 'updatePubertyGraphs' in your index.html
    js.context.callMethod('updatePubertyGraphs', [jsonString]);
  }

  // Call this if you just need the JSON string for other logic
  String getJsonForWeb() {
    return jsonEncode(_savedReports);
  }
}
