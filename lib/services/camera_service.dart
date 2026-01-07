import 'package:camera/camera.dart';

class CameraService {
  CameraController? controller;
  List<CameraDescription>? cameras;
  int currentCameraIndex = 0;

  bool get isInitialized =>
      controller != null && controller!.value.isInitialized;

  Future<void> initialize({int cameraIndex = 0}) async {
    cameras = await availableCameras();
    if (cameras == null || cameras!.isEmpty) return;

    if (cameraIndex >= cameras!.length) cameraIndex = 0;

    controller = CameraController(
      cameras![cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await controller!.initialize();
    currentCameraIndex = cameraIndex;
  }

  Future<void> switchCamera() async {
    if (cameras == null || cameras!.length < 2) return;

    final newIndex = (currentCameraIndex + 1) % cameras!.length;
    await controller?.dispose();
    await initialize(cameraIndex: newIndex);
  }

  Future<XFile?> capture() async {
    if (!isInitialized) return null;
    return await controller!.takePicture();
  }

  void dispose() {
    controller?.dispose();
  }
}
