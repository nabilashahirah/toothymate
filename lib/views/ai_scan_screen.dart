import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart'; 
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
    await tts.setLanguage("en-US");
    await tts.setPitch(1.3); 
    await tts.setSpeechRate(0.5);
    
    // Greet the user as soon as the TTS engine is ready
    if (!_hasGreeted) {
      _speakMascot("Hi there, Hero! I'm ready to scan your smile. Please align your teeth in the box!");
      setState(() => _hasGreeted = true);
    }
  }

  void _speakMascot(String text) async {
    await tts.stop();
    await tts.speak(text);
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
              String feedback = FeedbackService.getFeedback(provider.results);
              final advice = AdviceService.getAdviceList(provider.results!);
              String adviceText = advice.isNotEmpty ? "My advice is: ${advice[0]['advice']}" : "";
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
              title: const Text('ToothyScan AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              actions: [
                if (provider.selectedImage != null || provider.results != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      tts.stop();
                      provider.resetScan();
                      _speakMascot("Let's try again! Ready when you are.");
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
          Container(
            width: 250, height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white54, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text("Align Tooth Here", style: TextStyle(color: Colors.white70))),
          ),
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
              const Text("Analysis Report", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F82EB))),
              IconButton(
                icon: const Icon(Icons.volume_up, color: Color(0xFF33D4FF)),
                onPressed: () {
                  String feedback = FeedbackService.getFeedback(provider.results);
                  _speakMascot(feedback);
                },
              )
            ],
          ),
          const SizedBox(height: 10),

          if (target != null)
            _buildLearnMoreCard(context, target),

          Text(FeedbackService.getFeedback(provider.results), style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 15),

          ...provider.results!.entries.map((e) => _buildBar(e.key, e.value)),

          const Divider(height: 30),
          const Text("Hero's Advice:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F82EB))),
          const SizedBox(height: 10),
          ...adviceItems.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(item['advice']!, style: const TextStyle(fontSize: 13))),
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
          Expanded(child: Text("New Lesson: $lessonName!", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () {
              tts.stop();
              Navigator.push(context, MaterialPageRoute(builder: (context) => ElearningScreen(initialSearch: lessonName)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Study", style: TextStyle(color: Colors.white, fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildIdleView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text("Take a clear photo of your teeth.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "This AI scan checks for plaque, stains, cavities, and healthy teeth for awareness purposes only.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
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
              icon: const Icon(Icons.camera_alt), label: const Text("Capture Scan"),
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
    child: const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          CircularProgressIndicator(color: Colors.white), 
          SizedBox(height: 15), 
          Text("AI is checking your teeth...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
        ]
      )
    )
  );
}