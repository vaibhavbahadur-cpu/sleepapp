import 'package:flutter/material.dart';
import 'sleep_staging_engine.dart';

class GalaxyWatchDashboardUI extends StatelessWidget {
  const GalaxyWatchDashboardUI({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulated live readings pulled straight from your background calculation loops
    const String activeStageLabel = "Deep Sleep 💤";
    const String liveBpShift = "-8 mmHg 🟢";
    const int calculatedVascularLoad = 34;
    const int estimatedOxygen = 99;
    const double estimatedThermal = 92.4;
    const String currentPosture = "Side Comfort 🦴";
    const double finalBioAgeNumber = 13.6;
    const int acousticDisturbancesCount = 2;
    const int currentEnergyScore = 88;

    return Scaffold(
      backgroundColor: Colors.black, // Crucial: Saves AMOLED battery life on Galaxy Watch 8
      body: Center(
        child: SizedBox(
          width: 220,
          height: 220,
          // Horizontal PageView creates separate swipe cards fitting round screens perfectly
          child: PageView(
            scrollDirection: Axis.horizontal,
            children: [
              // CARD 1: RECOVERY ENGINE OVERVIEW
              _buildCircularWatchContainer(
                title: "RECOVERY CORE",
                icon: Icons.nightlight_round,
                iconColor: Colors.indigoAccent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(activeStageLabel, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.black)),
                    const SizedBox(height: 2),
                    Text("Energy Battery: $currentEnergyScore/100", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),

              // CARD 2: VASCULAR & CARDIO LOGS
              _buildCircularWatchContainer(
                title: "CARDIO LOGS",
                icon: Icons.favorite,
                iconColor: Colors.redAccent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("BP Timeline Shift:", style: TextStyle(color: Colors.white38, fontSize: 10)),
                    Text(liveBpShift, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.black)),
                    const SizedBox(height: 2),
                    Text("Vascular Load: $calculatedVascularLoad/100", style: const TextStyle(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              // CARD 3: RE-DYNAMICS PHYSICAL BIOMARKERS
              _buildCircularWatchContainer(
                title: "PHYSICAL BIO",
                icon: Icons.accessibility_new,
                iconColor: Colors.tealAccent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Blood Oxygen: $estimatedOxygen%", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                    Text("Skin Surface: $estimatedThermal°F", style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(currentPosture, style: const TextStyle(color: Colors.white60, fontSize: 10, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),

              // CARD 4: LONGEVITY & ENVIRONMENT SHIELD
              _buildCircularWatchContainer(
                title: "GROWTH SHIELD",
                icon: Icons.shield,
                iconColor: Colors.pinkAccent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Bio Age: $finalBioAgeNumber Years", style: const TextStyle(color: Colors.pinkAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text("Noise Fractures: $acousticDisturbancesCount Spikes", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    const Text("Digestion: Fasting 🥗", style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper layout builder that forces padding and safe margins inside circular borders
  Widget _buildCircularWatchContainer({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black, // Keeps background perfectly seamless
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(height: 2),
          Text(
            title, 
            style: TextStyle(color: iconColor, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.1)
          ),
          const Divider(color: Colors.white10, height: 10, indent: 30, endIndent: 30),
          const SizedBox(height: 2),
          child,
        ],
      ),
    );
  }
}
