import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> files = [];

  @override
  void initState() {
    super.initState();
    getStoragePermission(context);
    files = listMusicFiles();
  }

  List<String> listMusicFiles() {
    List<String> musicFiles = [];
    try {
      print(Directory("/sdcard/Music").statSync());
      if (Directory("/sdcard/Music").existsSync()) {
        Directory musicDir = Directory("/sdcard/Music");
        List files = musicDir.listSync();
        print(files);
      }
    } catch (e) {
      print('Error: $e');
    }
    return musicFiles;
  }

  void getStoragePermission(BuildContext context) async {
    var status = await Permission.storage.status;
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
                  await Permission.storage.request();
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
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 40),
      child: Column(
        children: [
          FilledButton(onPressed: () {
            files = listMusicFiles();
          }, child: Text("Refresh (DEV)")),
          Expanded(
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(files[index]),
                );
              },
            ),
          )
        ],
      ),
    ));
  }
}
