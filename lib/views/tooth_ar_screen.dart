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
import 'package:easy_localization/easy_localization.dart';

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
  String _debugStatus = "";
  
  // 🎮 Gamification: Track discovered cases
  Set<int> _discoveredCases = {};

  // 🎯 Tutorial: Show gesture tutorial only
  bool _showGestureTutorial = true; // Shows first when object is placed
  
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
  // Translation keys are used - actual content loaded via context.tr()
  final List<Map<String, String>> dentalCases = [
    {"label": "1", "titleKey": "case1Title", "descKey": "case1Desc"},
    {"label": "2", "titleKey": "case2Title", "descKey": "case2Desc"},
    {"label": "3", "titleKey": "case3Title", "descKey": "case3Desc"},
    {"label": "4", "titleKey": "case4Title", "descKey": "case4Desc"},
    {"label": "5", "titleKey": "case5Title", "descKey": "case5Desc"},
    {"label": "6", "titleKey": "case6Title", "descKey": "case6Desc"},
    {"label": "7", "titleKey": "case7Title", "descKey": "case7Desc"},
    {"label": "8", "titleKey": "case8Title", "descKey": "case8Desc"},
    {"label": "9", "titleKey": "case9Title", "descKey": "case9Desc"},
    {"label": "10", "titleKey": "case10Title", "descKey": "case10Desc"},
  ];

  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    // 💓 Setup Pulse Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Initialize after the first frame to avoid context issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _prepareLocalModel();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload content if locale changed
    final locale = context.locale;
    if (_currentLocale != locale) {
      _currentLocale = locale;
      // Update TTS language
      _initTts();
      // Force a rebuild to update translated text
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _initTts() async {
    final String locale = context.locale.languageCode;
    if (locale == 'ms') {
      await _flutterTts.setLanguage('ms-MY');
    } else {
      await _flutterTts.setLanguage('en-US');
    }
    await _flutterTts.setPitch(1.1); // Slightly higher pitch for a friendly tone
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speakInstructions() async {
    await _flutterTts.stop();
    if (_isObjectPlaced) {
      await _flutterTts.speak('walkAroundInstructions'.tr());
    } else {
      await _flutterTts.speak('welcomeARInstructions'.tr());
    }
  }

  Future<void> _prepareLocalModel() async {
    setState(() => _debugStatus = 'loadingModel'.tr());

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
        _debugStatus = 'pointCameraFlat'.tr();
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
        SnackBar(
          content: Text('waitModelNotLoaded'.tr()),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
        )
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
          _debugStatus = 'walkAroundTooth'.tr();
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
      _showGestureTutorial = true; // Reset to show gesture tutorial
      _debugStatus = 'pointCameraFlat'.tr();
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
            Text(
              'dentalAR'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _debugStatus.isEmpty ? 'initializingAR'.tr() : _debugStatus,
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
            tooltip: 'replayInstructions'.tr(),
          ),
          IconButton(
            onPressed: onRemoveEverything,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'resetAR'.tr(),
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
                        child: Column(
                          children: [
                            const Icon(Icons.touch_app, color: Colors.amber, size: 50),
                            const SizedBox(height: 10),
                            Text(
                              'tapOnDotsToPlace'.tr(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
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
                    Text(
                      'movePhoneGently'.tr(),
                      style: const TextStyle(
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

          // 🔥 Gesture tutorial overlay (shows first)
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
                          Expanded(
                            child: Text(
                              'howToControl'.tr(),
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildGestureHint(Icons.pan_tool, 'move'.tr(), 'dragOneFinger'.tr()),
                      const SizedBox(height: 8),
                      _buildGestureHint(Icons.directions_walk, 'walkAround'.tr(), 'goAroundTooth'.tr()),
                      const SizedBox(height: 16),
                      Text(
                        'tapToDismiss'.tr(),
                        style: const TextStyle(
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
                                'discovered'.tr(namedArgs: {'count': '${_discoveredCases.length}'}),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_discoveredCases.length == 10)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text(
                                    'complete'.tr(),
                                    style: const TextStyle(
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
                                      Text(
                                        'howToPlayAR'.tr(),
                                        style: const TextStyle(
                                          color: Colors.amber,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          children: [
                                            TextSpan(text: 'lookAtNumbers'.tr()),
                                            TextSpan(
                                              text: 'tapButtonsBelow'.tr(),
                                              style: const TextStyle(
                                                color: Colors.amber,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const TextSpan(text: "!"),
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
                                            dentalCases[index]['titleKey']!.tr().split(' ')[0],
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
                        'case'.tr(namedArgs: {'number': data['label']!}),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['titleKey']!.tr(),
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
                    await _flutterTts.speak("${data['titleKey']!.tr()}. ${data['descKey']!.tr()}");
                  },
                  icon: const Icon(Icons.volume_up_rounded, color: Colors.blue, size: 32),
                  tooltip: 'readAloud'.tr(),
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
                data['descKey']!.tr(),
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
                child: Text(
                  'close'.tr(),
                  style: const TextStyle(
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