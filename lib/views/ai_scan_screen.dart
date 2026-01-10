import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/ai_scan_provider.dart';
import '../services/feedback_service.dart';
import '../services/advice_service.dart';
import 'elearning_screen.dart';

class ToothScanScreen extends StatefulWidget {
  const ToothScanScreen({super.key});

  @override
  State<ToothScanScreen> createState() => _ToothScanScreenState();
}

class _ToothScanScreenState extends State<ToothScanScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final FlutterTts tts = FlutterTts(); 
  bool _hasGreeted = false; // Prevents the greeting from repeating

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _initTts();
  }

  void _initTts() async {
    // Set language based on saved preference
    final prefs = await SharedPreferences.getInstance();
    final locale = prefs.getString('app_locale') ?? 'en';

    if (locale == 'ms') {
      await tts.setLanguage("ms-MY"); // Malay (Malaysia)
    } else {
      await tts.setLanguage("en-US"); // English (US)
    }

    await tts.setPitch(1.3);
    await tts.setSpeechRate(0.5);

    // Greet the user as soon as the TTS engine is ready
    if (!_hasGreeted) {
      _speakMascot('scanGreeting'.tr());
      setState(() => _hasGreeted = true);
    }
  }

  void _speakMascot(String text) async {
    await tts.stop();
    await tts.speak(text);
  }

  // Helper to translate feedback keys separated by pipe
  String _translateFeedback(String feedbackKeys) {
    if (!feedbackKeys.contains('|')) {
      return feedbackKeys.tr();
    }
    final keys = feedbackKeys.split('|');
    return keys.map((key) => key.tr()).join(' ');
  }

  @override
  void dispose() {
    _animationController.dispose();
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AiScanProvider(),
      child: Consumer<AiScanProvider>(
        builder: (context, provider, child) {
          // Trigger speech when results first appear
          if (provider.results != null && !provider.isProcessing) {
            Future.delayed(const Duration(milliseconds: 500), () {
              String feedbackKey = FeedbackService.getFeedback(provider.results);
              String feedback = _translateFeedback(feedbackKey);
              final advice = AdviceService.getAdviceList(provider.results!);
              String adviceText = advice.isNotEmpty ? "${'myAdviceIs'.tr()}: ${advice[0]['adviceKey']!.tr()}" : "";
              _speakMascot("$feedback. $adviceText");
            });
          }

          return Scaffold(
            backgroundColor: const Color(0xFFF0F4F8),
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.white),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF33D4FF), Color(0xFF0F82EB)]),
                ),
              ),
              title: Text('toothyScanAI'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              actions: [
                if (provider.selectedImage != null || provider.results != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      tts.stop();
                      provider.resetScan();
                      _speakMascot('tryAgainMessage'.tr());
                    },
                  )
              ],
            ),
            body: !provider.isReady
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF33D4FF)))
                : Column(
                    children: [
                      // --- CAMERA SECTION ---
                      Expanded(
                        flex: 2,
                        child: Container(
                          color: Colors.black,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              _buildCameraPreview(provider),
                              if (provider.selectedImage == null)
                                Positioned(
                                  top: 15,
                                  right: 15,
                                  child: FloatingActionButton.small(
                                    backgroundColor: Colors.black45,
                                    child: const Icon(Icons.flip_camera_ios, color: Colors.white),
                                    onPressed: provider.switchCamera,
                                  ),
                                ),
                              if (provider.selectedImage == null) _buildScannerOverlay(),
                              if (provider.isProcessing) _buildProcessingOverlay(),
                            ],
                          ),
                        ),
                      ),

                      // --- RESULTS SECTION ---
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                          ),
                          child: provider.isProcessing
                              ? const Center(child: CircularProgressIndicator())
                              : provider.errorMessage != null
                                  ? _buildErrorView(context, provider)
                                  : provider.results != null
                                      ? _buildAnalysisView(context, provider)
                                      : _buildIdleView(),
                        ),
                      ),
                      _buildBottomButtons(provider),
                    ],
                  ),
          );
        },
      ),
    );
  }

  // Same build methods as before...
  Widget _buildCameraPreview(AiScanProvider provider) {
    if (provider.selectedImage != null) {
      return Image.file(provider.selectedImage!, fit: BoxFit.cover);
    }
    final controller = provider.cameraService.controller;
    if (controller == null || !controller.value.isInitialized) return const SizedBox();

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize!.height,
          height: controller.value.previewSize!.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Scanning frame
          Container(
            width: 250, height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white54, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tooth shape outline
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30, width: 3),
                  ),
                  child: const Center(
                    child: Text(
                      '🦷',
                      style: TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Instruction text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'alignToothHere'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // Animated scanning line
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, (_animationController.value * 250) - 125),
                child: Container(
                  width: 250, height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF33D4FF),
                    boxShadow: [BoxShadow(color: const Color(0xFF33D4FF).withOpacity(0.5), blurRadius: 10)],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisView(BuildContext context, AiScanProvider provider) {
    final adviceItems = AdviceService.getAdviceList(provider.results!);
    String? target;
    if (provider.results!.containsKey('Caries') && provider.results!['Caries']! > 20) target = "Cavities";
    else if (provider.results!.containsKey('Calculus') && provider.results!['Calculus']! > 20) target = "Plaque";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('analysisReport'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F82EB))),
              IconButton(
                icon: const Icon(Icons.volume_up, color: Color(0xFF33D4FF)),
                onPressed: () {
                  String feedbackKey = FeedbackService.getFeedback(provider.results);
                  String feedback = _translateFeedback(feedbackKey);
                  _speakMascot(feedback);
                },
              )
            ],
          ),
          const SizedBox(height: 10),

          if (target != null)
            _buildLearnMoreCard(context, target),

          Text(_translateFeedback(FeedbackService.getFeedback(provider.results)), style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 15),

          ...provider.results!.entries.map((e) => _buildBar(e.key, e.value)),

          const Divider(height: 30),
          Text('herosAdvice'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F82EB))),
          const SizedBox(height: 10),
          ...adviceItems.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(item['adviceKey']!.tr(), style: const TextStyle(fontSize: 13))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildLearnMoreCard(BuildContext context, String lessonName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.school, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(child: Text("${'newLesson'.tr()}: $lessonName!", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () {
              tts.stop();
              Navigator.push(context, MaterialPageRoute(builder: (context) => ElearningScreen(initialSearch: lessonName)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('study'.tr(), style: const TextStyle(color: Colors.white, fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, AiScanProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 20),
            Text(
              provider.errorMessage!.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                provider.resetScan();
              },
              icon: const Icon(Icons.refresh),
              label: Text('tryAgain'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F82EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdleView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('takeClearPhoto'.tr(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'aiScanDisclaimer'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double val) {
    if (val < 5 || label == 'no_teeth_detected') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: const TextStyle(fontSize: 12))),
          Expanded(flex: 4, child: LinearProgressIndicator(value: val/100, color: FeedbackService.getConditionColor(label), backgroundColor: Colors.grey[200], minHeight: 6, borderRadius: BorderRadius.circular(10))),
          const SizedBox(width: 10),
          Text("${val.toStringAsFixed(0)}%", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(AiScanProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F82EB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: provider.capturePhoto,
              icon: const Icon(Icons.camera_alt), label: Text('captureScan'.tr()),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(onPressed: provider.pickImage, icon: const Icon(Icons.photo_library, color: Color(0xFF33D4FF))),
        ],
      ),
    );
  }

  Widget _buildProcessingOverlay() => Container(
    color: Colors.black54,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 15),
          Text('aiCheckingTeeth'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
        ]
      )
    )
  );
}