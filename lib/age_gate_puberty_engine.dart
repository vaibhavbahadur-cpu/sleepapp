import 'dart:convert';

class AgeGatePubertyEngine {
  final int selectedAgeProfile;
  
  // This stores the history automatically
  final List<Map<String, dynamic>> _savedReports = [];

  AgeGatePubertyEngine({required this.selectedAgeProfile});

  bool isTeenProfileActive() {
    return (selectedAgeProfile >= 11 && selectedAgeProfile <= 17);
  }

  // I've simplified the inputs. It calculates the trend AND saves it.
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

  // Call this to get the JSON string for your index.html
  String getJsonForWeb() {
    return jsonEncode(_savedReports);
  }
}
