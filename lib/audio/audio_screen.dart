import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:musicplayer/audio/audio_player_widget.dart';
import 'package:musicplayer/audio/song_lists_widget.dart';
import 'package:path/path.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<String> _songList = [];
  String? _currentFilePath;
  PlayerState _playerState = PlayerState.stopped;
  int _currentIndex = 0;
  String? _currentFolderName;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _playerState = state;
      });
    });
  }

  Future<void> _findAudioFilesInFolder(String folderPath) async {
    List<String> foundSongs = [];
    final directory = Directory(folderPath);

    try {
      if (await directory.exists()) {
        final List<FileSystemEntity> files =
            directory.listSync(recursive: true);

        for (var file in files) {
          if (file is File && file.path.endsWith('.mp3')) {
            foundSongs.add(file.path);
          }
        }
      }
    } catch (e) {
      print('Error accessing directory $folderPath: $e');
    }

    setState(() {
      _songList = foundSongs;
    });
  }

  Future<void> _pickFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      await _findAudioFilesInFolder(selectedDirectory);
      setState(() {
        _currentFolderName = basename(selectedDirectory); // Simpan nama folder
      });
    }
  }

  void _playAudio(String filePath) async {
    setState(() {
      _currentFilePath = filePath;
      _currentIndex = _songList.indexOf(filePath);
      _playerState = PlayerState.playing;
    });
    await _audioPlayer.play(DeviceFileSource(filePath));
  }

  void _pauseAudio() async {
    setState(() {
      _playerState = PlayerState.paused;
    });
    await _audioPlayer.pause();
  }

  void _stopAudio() async {
    setState(() {
      _playerState = PlayerState.stopped;
      _currentFilePath = null;
    });
    await _audioPlayer.stop();
  }

  void _playNext() {
    if (_currentIndex < _songList.length - 1) {
      _currentIndex++;
      _playAudio(_songList[_currentIndex]);
    }
  }

  void _playPrevious() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _playAudio(_songList[_currentIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Row(
        children: [
          Flexible(
            flex: 6,
            child: AudioPlayerWidget(
              audioPlayer: _audioPlayer,
              playerState: _playerState,
              currentFilePath: _currentFilePath,
              playAudio: _playAudio,
              pauseAudio: _pauseAudio,
              stopAudio: _stopAudio,
              nextAudio: _playNext,
              previousAudio: _playPrevious,
            ),
          ),
          Flexible(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SongListWidget(
                songList: _songList,
                playAudio: _playAudio,
                openFolder: _pickFolder,
                currentlyPlaying: _currentFilePath,
                folderName: _currentFolderName, // Tambahkan ini
              ),
            ),
          ),
        ],
      ),
    );
  }
}
