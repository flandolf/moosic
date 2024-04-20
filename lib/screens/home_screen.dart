// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:moosic/screens/audio_player.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> filePaths = [];

  @override
  void initState() {
    super.initState();
    getStoragePermission(context);
    setMusicFiles();
  }

  void setMusicFiles() {
    List<String> musicFiles = [];
    List<String> audioExtensions = [
      '.mp3',
      '.wav',
      '.ogg',
      '.aac',
      '.flac'
    ]; // Add more extensions if needed

    try {
      if (Directory("/sdcard/Music").existsSync()) {
        Directory musicDir = Directory("/sdcard/Music");
        List<FileSystemEntity> files = musicDir.listSync();

        for (var file in files) {
          if (file is File) {
            String extension = file.path.split('.').last.toLowerCase();
            if (audioExtensions.contains('.$extension')) {
              musicFiles.add(file.path);
            }
          }
        }

        setState(() {
          filePaths = musicFiles;
        });

        print(files);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void getStoragePermission(BuildContext context) async {
    var status = await Permission.audio.status;
    if (status.isDenied && context.mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Storage Permission Required'),
            content: const Text(
                'This app needs access to storage to function properly.'),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  await Permission.audio.request();
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Moosic!"),
          actions: [
            IconButton(
                onPressed: setMusicFiles, icon: const Icon(Icons.refresh))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: filePaths.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(filePaths[index]),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AudioPlayerScreen(filePath: filePaths[index]),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ));
  }
}
