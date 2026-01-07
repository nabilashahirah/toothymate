// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:path_provider/path_provider.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ToothARScreen extends StatefulWidget {
  const ToothARScreen({super.key});

  @override
  State<ToothARScreen> createState() => _ToothARScreenState();
}

class _ToothARScreenState extends State<ToothARScreen> with SingleTickerProviderStateMixin {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  late ARAnchorManager arAnchorManager;

  List<ARNode> nodes = [];
  List<ARAnchor> anchors = [];

  bool _isModelReady = false;
  bool _isObjectPlaced = false;
  String _debugStatus = "Initializing AR...";
  
  // 🎮 Gamification: Track discovered cases
  Set<int> _discoveredCases = {};
  
  // 🎯 Tutorial: Show pulsing arrow pointing to buttons
  bool _showTutorial = true;
  bool _showGestureTutorial = true; // 🔥 NEW: Show gesture hints
  
  // 🎉 Confetti controller
  late ConfettiController _confettiController;
  
  // 🔊 Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // 🗣️ Text-to-Speech
  final FlutterTts _flutterTts = FlutterTts();

  //  Animation for "Tap" instruction
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Dental case information with labels matching the 3D model
  final List<Map<String, String>> dentalCases = [
    {
      "label": "1",
      "title": "Traditional Bridge",
      "desc": "Like a bridge over a river! We put a fake tooth in the empty space and hold it up using the strong teeth next to it."
    },
    {
      "label": "2",
      "title": "Implant-Supported Bridge",
      "desc": "A super strong bridge! Instead of holding onto other teeth, it stands on special metal roots hidden in the gums."
    },
    {
      "label": "3",
      "title": "Maryland Bridge",
      "desc": "A bridge with wings! It has tiny wings that stick to the back of your other teeth to hold the new tooth in place."
    },
    {
      "label": "4",
      "title": "Dental Implant",
      "desc": "A robot root! It's a tiny metal screw that acts like a real tooth root, so we can put a brand new tooth on top."
    },
    {
      "label": "5",
      "title": "Gingival Recession",
      "desc": "When gums get shy and pull back! This happens if we brush too hard. We need to be gentle to keep gums happy."
    },
    {
      "label": "6",
      "title": "Root Canal Treatment (RCT)",
      "desc": "Cleaning the inside of a tooth! If a tooth gets a tummy ache deep inside, the dentist cleans it out to make it feel better."
    },
    {
      "label": "7",
      "title": "Decayed Tooth",
      "desc": "A tooth with a sugar bug hole! Germs made a tiny hole here. The dentist needs to clean it and patch it up."
    },
    {
      "label": "8",
      "title": "Impacted Wisdom Tooth",
      "desc": "A sleeping tooth that's stuck! This big back tooth is trying to come out but got stuck against its neighbor."
    },
    {
      "label": "9",
      "title": "Wisdom Tooth",
      "desc": "The grown-up teeth! These are the very last teeth to grow in the back of your mouth when you are much older."
    },
    {
      "label": "10",
      "title": "Class II Cavity Preparation",
      "desc": "A hidden hole between teeth! Sugar bugs hid in the tight space between two teeth, so the dentist is fixing it."
    },
  ];

  @override
  void initState() {
    super.initState();
    _prepareLocalModel();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    // 💓 Setup Pulse Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.1); // Slightly higher pitch for a friendly tone
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speakInstructions() async {
    await _flutterTts.stop();
    if (_isObjectPlaced) {
      await _flutterTts.speak("Walk around the tooth to find numbers, then tap the buttons below to learn!");
    } else {
      await _flutterTts.speak("Welcome to Dr. Karthi's Magic Dental AR! Point your camera at a flat surface and tap the dots to place the tooth.");
    }
  }

  Future<void> _prepareLocalModel() async {
    setState(() => _debugStatus = "Loading 3D model...");
    
    // 1. Initialize Voice Settings first
    await _initTts();
   
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/tooth.glb';
      final file = File(path);

      final byteData = await rootBundle.load('assets/models/tooth.glb');
      await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

      if (!mounted) return; // 🛡️ Safety Check: Stop if user left the screen

      setState(() {
        _isModelReady = true;
        _debugStatus = "Point camera at flat surface and tap to place";
      });
      
      // 2. Speak ONLY when model is ready and spinner is gone
      _speakInstructions();

    } catch (e) {
      setState(() {
        _debugStatus = "❌ ERROR: $e";
      });
      debugPrint("Error: $e");
    }
  }

  @override
  void dispose() {
    arSessionManager.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    _flutterTts.stop();
    _pulseController.dispose();
    super.dispose();
  }

  void onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;
    arAnchorManager = anchorManager;

    arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      customPlaneTexturePath: "Images/triangle.png",
      showWorldOrigin: false,
      handlePans: true,        // ✅ Already enabled - allows moving the model
      handleRotation: true,    // ✅ Already enabled - allows rotating with 2 fingers
    );
    arObjectManager.onInitialize();
    arSessionManager.onPlaneOrPointTap = onPlaneOrPointTapped;
  }

  Future<void> onPlaneOrPointTapped(List<ARHitTestResult> hitTestResults) async {
    if (!_isModelReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wait! Model not loaded yet."))
      );
      return;
    }

    // Prevent placing multiple models if one is already active
    if (_isObjectPlaced) {
      return;
    }

    // Safely find a plane hit. If we tapped a point (not a plane), ignore it.
    final planeHits = hitTestResults.where((hit) => hit.type == ARHitTestResultType.plane);
    if (planeHits.isEmpty) return;

    var singleHitTestResult = planeHits.first;
    var newAnchor = ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
    bool? didAddAnchor = await arAnchorManager.addAnchor(newAnchor);

    if (didAddAnchor == true) {
      anchors.add(newAnchor);

      var newNode = ARNode(
        type: NodeType.fileSystemAppFolderGLB,
        uri: "tooth.glb",
        scale: Vector3(15.0, 15.0, 15.0),
        position: Vector3(0.0, 0.0, 0.0),
        rotation: Vector4(1.0, 0.0, 0.0, 0.0),
      );

      bool? didAddNode = await arObjectManager.addNode(newNode, planeAnchor: newAnchor);
      if (didAddNode == true) {
        nodes.add(newNode);
        
        // 🔊 Play sound & Haptic feedback on success
        _audioPlayer.play(AssetSource('audio/pop.mp3'), mode: PlayerMode.lowLatency);
        HapticFeedback.heavyImpact();

        setState(() {
          _isObjectPlaced = true;
          _debugStatus = "Walk around the tooth to find numbers!";
        });

        // 🗣️ Auto-speak next step immediately after placement
        _speakInstructions();
      } else {
        setState(() => _debugStatus = "⚠️ Failed to place object");
      }
    }
  }

  Future<void> onRemoveEverything() async {
    for (var anchor in anchors) {
      arAnchorManager.removeAnchor(anchor);
    }
    anchors = [];
    nodes = [];
    setState(() {
      _isObjectPlaced = false;
      _discoveredCases.clear();
      _debugStatus = "Point camera at flat surface and tap to place";
    });

    // 🗣️ Auto-speak welcome instructions again after reset
    _speakInstructions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "3D Dental AR",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _debugStatus,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _speakInstructions,
            icon: const Icon(Icons.volume_up, color: Colors.white),
            tooltip: "Replay Instructions",
          ),
          IconButton(
            onPressed: onRemoveEverything,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Reset AR",
          )
        ],
      ),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),

          // ⏳ Loading Indicator (Center of screen)
          if (!_isModelReady)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.amber,
              ),
            ),

          // 🟢 NEW: Big instruction to tap dots (Only shows before placement)
          if (_isModelReady && !_isObjectPlaced)
            Align(
              alignment: Alignment.center,
              child: IgnorePointer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 💓 Animated Pulse Effect
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber, width: 3),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.touch_app, color: Colors.amber, size: 50),
                            SizedBox(height: 10),
                            Text(
                              "TAP ON DOTS\nTO PLACE TOOTH!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Move phone gently to find dots...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 🎉 Confetti overlay (plays when all 10 discovered)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.amber,
              ],
              numberOfParticles: 30,
              gravity: 0.3,
            ),
          ),

          // 🔥 Gesture tutorial overlay
          if (_isObjectPlaced && _showGestureTutorial)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showGestureTutorial = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.touch_app, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "How to Control the Model",
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildGestureHint(Icons.pan_tool, "Move", "Drag with 1 finger to reposition"),
                      const SizedBox(height: 8),
                      _buildGestureHint(Icons.directions_walk, "Walk Around", "Go around the tooth to find numbers!"),
                      const SizedBox(height: 16),
                      const Text(
                        "Tap anywhere to dismiss",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Dental cases menu (shown after object is placed)
          if (_isObjectPlaced)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.95),
                      Colors.black.withOpacity(0.85),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 15),
                    // Progress tracker banner
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade600, Colors.blue.shade800],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Progress counter
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                "Discovered: ${_discoveredCases.length}/10",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_discoveredCases.length == 10)
                                const Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Text(
                                    "🎉 Complete!",
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // 🎯 Enhanced instruction with emphasis
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber, width: 2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.amber,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "HOW TO PLAY",
                                        style: TextStyle(
                                          color: Colors.amber,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      RichText(
                                        textAlign: TextAlign.center,
                                        text: const TextSpan(
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          children: [
                                            TextSpan(text: "Look at numbers on teeth, then "),
                                            TextSpan(
                                              text: "TAP BUTTONS BELOW",
                                              style: TextStyle(
                                                color: Colors.amber,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            TextSpan(text: "!"),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.touch_app,
                                  color: Colors.amber,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: dentalCases.length,
                            itemBuilder: (context, index) {
                          final isDiscovered = _discoveredCases.contains(index);
                          
                          return GestureDetector(
                            onTap: () async {
                              // 🔊 Play pop sound
                              _audioPlayer.stop().then((_) => 
                                _audioPlayer.play(AssetSource('audio/pop.mp3'), mode: PlayerMode.lowLatency));
                              
                              // Haptic feedback
                              HapticFeedback.mediumImpact();
                              
                              // Hide tutorial after first tap
                              if (_showTutorial) {
                                setState(() {
                                  _showTutorial = false;
                                });
                              }
                              
                              // Mark as discovered
                              final wasNew = !_discoveredCases.contains(index);
                              setState(() {
                                _discoveredCases.add(index);
                              });
                              
                              // 🎉 If all discovered, play yahoo and confetti!
                              if (_discoveredCases.length == 10 && wasNew) {
                                _confettiController.play();
                                await _audioPlayer.play(AssetSource('audio/yahoo.mp3'));
                              }
                              
                              _showDetails(dentalCases[index]);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDiscovered 
                                    ? [Colors.green.shade400, Colors.green.shade700]
                                    : [Colors.blue.shade400, Colors.blue.shade700],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDiscovered ? Colors.green : Colors.blue).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Main content - centered properly
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            dentalCases[index]['label']!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            dentalCases[index]['title']!.split(' ')[0],
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Star badge for discovered items
                                  if (isDiscovered)
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: const BoxDecoration(
                                          color: Colors.amber,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.star,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showDetails(Map<String, String> data) {
    showModalBottomSheet(
      context: context,
      // Stop speaking when the sheet is closed (swiped down or tapped outside)
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue.shade400, Colors.blue.shade700],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      data['label']!,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Case ${data['label']}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['title']!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                // 🗣️ Read Aloud Button
                IconButton(
                  onPressed: () async {
                    await _flutterTts.stop();
                    // Speak Title then Description
                    await _flutterTts.speak("${data['title']}. ${data['desc']}");
                  },
                  icon: const Icon(Icons.volume_up_rounded, color: Colors.blue, size: 32),
                  tooltip: "Read Aloud",
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Text(
                data['desc']!,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _flutterTts.stop(); // Stop voice when closing manually
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  "Close",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
          ],
        ),
      ),
    ).whenComplete(() => _flutterTts.stop()); // Ensure voice stops if sheet is dismissed
  }

  Widget _buildGestureHint(IconData icon, String title, String description) {
    return Row(
      children: [
        Icon(icon, color: Colors.amber, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}