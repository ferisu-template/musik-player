import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerWidget extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final PlayerState playerState;
  final String? currentFilePath;
  final Function(String filePath) playAudio;
  final Function pauseAudio;
  final Function stopAudio;
  final Function nextAudio; // Function for next song
  final Function previousAudio; // Function for previous song

  const AudioPlayerWidget({
    super.key,
    required this.audioPlayer,
    required this.playerState,
    this.currentFilePath,
    required this.playAudio,
    required this.pauseAudio,
    required this.stopAudio,
    required this.nextAudio, // Receive nextAudio
    required this.previousAudio, // Receive previousAudio
  });

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();

    // Listener untuk update posisi saat audio diputar
    widget.audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        _currentPosition = position;
      });
    });

    // Listener untuk mendapatkan durasi total audio
    widget.audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _totalDuration = duration;
      });
    });

    // Listener untuk otomatis next ketika audio selesai
    widget.audioPlayer.onPlayerComplete.listen((event) {
      widget.nextAudio(); // Memanggil fungsi nextAudio
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF030303),
        title: const Text(
          'Play Music',
          style: TextStyle(color: Colors.white),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0), // Tinggi garis
          child: Container(
            color: Colors.white38, // Warna garis
            height: 1.0, // Ketebalan garis
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Konten yang akan berada di atas gradient
          Column(
            mainAxisAlignment:
                MainAxisAlignment.end, // Elemen-elemen di bagian bawah
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.currentFilePath != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Now playing: ${widget.currentFilePath!.split('/').last}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: _buildProgressBar(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildDurationText(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous,
                        size: 48, color: Colors.white),
                    onPressed: () => widget.previousAudio(),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: IconButton(
                      key: ValueKey<bool>(
                          widget.playerState == PlayerState.playing),
                      icon: Icon(
                        widget.playerState == PlayerState.playing
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill,
                        size: 48,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (widget.playerState == PlayerState.playing) {
                          widget.pauseAudio();
                        } else {
                          if (widget.currentFilePath != null) {
                            widget.playAudio(widget.currentFilePath!);
                          }
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next,
                        size: 48, color: Colors.white),
                    onPressed: () => widget.nextAudio(),
                  ),
                ],
              ),
              const SizedBox(height: 32), // Ruang ekstra di bagian bawah layar
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    double progress = _totalDuration.inMilliseconds > 0
        ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
        : 0.0;

    return Container(
      height: 6,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(5),
      ),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.white.withOpacity(0.3),
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _buildDurationText() {
    String formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      return "$minutes:$seconds";
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(formatDuration(_currentPosition),
              style: const TextStyle(color: Colors.white)),
          Text(formatDuration(_totalDuration),
              style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
