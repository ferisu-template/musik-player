import 'package:flutter/material.dart';
import 'package:path/path.dart';

class SongListWidget extends StatelessWidget {
  final List<String> songList;
  final Function(String filePath) playAudio;
  final Function openFolder;
  final String? currentlyPlaying;
  final String? folderName; // Nama folder yang dipilih

  const SongListWidget({
    super.key,
    required this.songList,
    required this.playAudio,
    required this.openFolder,
    this.currentlyPlaying,
    required this.folderName, // Nama folder yang dipilih
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF030303),
        actions: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  folderName ??
                      'Pilih Folder', // Tampilkan nama folder yang dipilih
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.folder_open, color: Colors.yellowAccent),
                onPressed: () => openFolder(),
              ),
            ],
          ),
        ],
        // Menambahkan garis di bawah AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0), // Tinggi garis
          child: Container(
            color: Colors.white38, // Warna garis
            height: 1.0, // Ketebalan garis
          ),
        ),
      ),
      backgroundColor: const Color(0xFF030303),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: songList.length,
              itemExtent: 60, // Menetapkan tinggi setiap item
              itemBuilder: (context, index) {
                String fileName = basename(songList[index]);
                String nameWithoutExtension = fileName.endsWith('.mp3')
                    ? fileName.substring(0, fileName.length - 4)
                    : fileName;

                // Cek apakah lagu ini yang sedang diputar
                bool isPlaying = currentlyPlaying == songList[index];

                return Container(
                  decoration: BoxDecoration(
                    color: isPlaying ? const Color(0xFF212121) : Colors.black54,
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    leading: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.music_note,
                        color: Colors.blueAccent,
                        size: 30,
                      ),
                    ),
                    title: Text(
                      nameWithoutExtension,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onTap: () => playAudio(songList[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
