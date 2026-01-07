import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  // We keep a static instance so we don't create a new player every time
  static final AudioPlayer _player = AudioPlayer();

  /// Plays the "pop" sound effect
  static Future<void> playPop() async {
    try {
      // Stop previous sound to allow rapid clicking
      await _player.stop(); 
      // Play the new sound
      await _player.play(AssetSource('audio/pop.mp3'));
    } catch (e) {
      // If sound fails, the app shouldn't crash. Just ignore.
      print("Error playing sound: $e");
    }
  }
}